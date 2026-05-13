#!/usr/bin/env python3
"""
Reusable file/dir name sanitizer for wiki raw/ exports.

Call from agent-tool or inline via execute_code.

Usage:
    python3 sanitize-raw-files.py /path/to/wiki/raw/some-export    # single export dir
    python3 sanitize-raw-files.py --full-sweep /path/to/wiki       # all export dirs under raw/

What it does:
    - Lowercases all file/directory names
    - Replaces spaces with hyphens
    - Strips trailing whitespace/dots
    - Preserves Chinese characters, &, (), and all other Unicode
    - Renames children FIRST (deepest-first) so parent renames don't break child paths
    - Detects and warns about collisions before renaming
    - Returns a JSON mapping of old->new paths for reference updates

    In --full-sweep mode:
        - Sweeps ALL subdirectories of raw/ (each top-level export dir)
        - Saves the full rename map to .rename_map.json in the wiki root
        - Returns the map on stdout as usual

Author: Generated from Hermes Agent session (user: yusiwen)
"""

import os, re, sys, json


def fix_name(name):
    """Only: lowercase, spaces->hyphens, trim trailing whitespace."""
    name = name.strip()
    name = name.lower()
    name = name.replace(' ', '-')
    return name


def fix_filename(fname):
    """Fix a filename, lowercasing extension too."""
    dot = fname.rfind('.')
    if dot > 0:
        return fix_name(fname[:dot]) + fname[dot:].lower()
    return fix_name(fname)


def collect_entries(raw_dir):
    """Collect all entries needing rename, with their sanitized names."""
    entries = []  # list of (is_dir, old_path, new_path)
    for root, dirs, files in os.walk(raw_dir):
        for f in files:
            new_name = fix_filename(f)
            if new_name != f:
                entries.append((False, os.path.join(root, f), os.path.join(root, new_name)))
        for d in dirs:
            new_name = fix_name(d)
            if new_name != d:
                entries.append((True, os.path.join(root, d), os.path.join(root, new_name)))
    # Sort by path length DESCENDING so children are processed before parents
    entries.sort(key=lambda x: -len(x[1]))
    return entries


def check_collisions(entries):
    """Check for collisions where two entries would map to the same new path."""
    target_map = {}
    collisions = []
    for is_dir, old, new in entries:
        if new in target_map:
            collisions.append((target_map[new], old, new))
        else:
            target_map[new] = old
    return collisions


def build_path_map(entries, wiki_dir):
    """Build old_rel -> new_rel mapping relative to wiki_dir."""
    path_map = {}
    for is_dir, old, new in entries:
        rel_old = os.path.relpath(old, wiki_dir)
        rel_new = os.path.relpath(new, wiki_dir)
        path_map[rel_old] = rel_new
    return path_map


def execute_renames(entries):
    """Execute all renames. Returns (success_count, error_count)."""
    success = 0
    errors = 0
    for is_dir, old, new in entries:
        try:
            # Ensure parent directory exists
            new_parent = os.path.dirname(new)
            os.makedirs(new_parent, exist_ok=True)
            os.rename(old, new)
            success += 1
        except OSError as e:
            print(f"  ERROR: {e}", file=sys.stderr)
            errors += 1
    return success, errors


def main_single(raw_dir):
    """Sanitize a single export directory."""
    entries = collect_entries(raw_dir)
    if not entries:
        print("{}", file=sys.stderr)
        print("No entries to rename.")
        return 0

    collisions = check_collisions(entries)
    if collisions:
        print(f"WARNING: {len(collisions)} collision(s):", file=sys.stderr)
        for c1, c2, target in collisions:
            print(f"  {c1} and {c2} both -> {target}", file=sys.stderr)
        print("Aborting. Resolve collisions manually first.", file=sys.stderr)
        return 1

    wiki_dir = os.path.dirname(os.path.dirname(raw_dir))  # raw/../.. = wiki root
    path_map = build_path_map(entries, wiki_dir)

    success, errors = execute_renames(entries)
    print(f"Renamed: {success}, Errors: {errors}", file=sys.stderr)

    print(json.dumps(path_map, indent=2, ensure_ascii=False))
    return 0 if errors == 0 else 1


def main_full_sweep(wiki_dir):
    """Sanitize ALL export dirs under raw/."""
    raw_dir = os.path.join(wiki_dir, "raw")
    if not os.path.isdir(raw_dir):
        print(f"raw/ not found under {wiki_dir}", file=sys.stderr)
        return 1

    all_entries = []
    for item in sorted(os.listdir(raw_dir)):
        item_path = os.path.join(raw_dir, item)
        if os.path.isdir(item_path):
            entries = collect_entries(item_path)
            all_entries.extend(entries)

    if not all_entries:
        print("No entries to rename.")
        return 0

    # Check collisions across ALL export dirs combined
    collisions = check_collisions(all_entries)
    if collisions:
        print(f"WARNING: {len(collisions)} collision(s):", file=sys.stderr)
        for c1, c2, target in collisions:
            print(f"  {c1} and {c2} both -> {target}", file=sys.stderr)
        print("Aborting.", file=sys.stderr)
        return 1

    # Build path map relative to wiki root
    path_map = build_path_map(all_entries, wiki_dir)

    # Execute (already sorted deepest-first)
    success, errors = execute_renames(all_entries)
    print(f"Total entries: {len(all_entries)}", file=sys.stderr)
    print(f"Renamed: {success}, Errors: {errors}", file=sys.stderr)

    # Save full rename map for link-update phase
    map_path = os.path.join(wiki_dir, ".rename_map.json")
    with open(map_path, 'w', encoding='utf-8') as f:
        json.dump(path_map, f, ensure_ascii=False, indent=2)
    print(f"Rename map saved to {map_path}", file=sys.stderr)

    print(json.dumps(path_map, indent=2, ensure_ascii=False))
    return 0 if errors == 0 else 1


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage:", file=sys.stderr)
        print(f"  {sys.argv[0]} <raw-export-dir>       # single export", file=sys.stderr)
        print(f"  {sys.argv[0]} --full-sweep <wiki-root>  # all exports", file=sys.stderr)
        sys.exit(1)

    if sys.argv[1] == "--full-sweep":
        if len(sys.argv) < 3:
            print("--full-sweep requires the wiki root directory", file=sys.stderr)
            sys.exit(1)
        sys.exit(main_full_sweep(sys.argv[2]))
    else:
        sys.exit(main_single(sys.argv[1]))
