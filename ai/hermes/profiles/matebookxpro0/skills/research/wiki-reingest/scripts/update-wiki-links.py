#!/usr/bin/env python3
"""
Update wiki internal references after a bulk rename in raw/.

After running sanitize-raw-files.py (especially with --full-sweep), all
wiki pages that reference renamed files/dirs need their links updated.

Usage:
    python3 update-wiki-links.py /path/to/wiki        # uses .rename_map.json
    python3 update-wiki-links.py /path/to/wiki <map.json>

What it does:
    - Loads the rename map (old_rel -> new_rel paths, relative to wiki root)
    - Scans ALL .md files under the wiki root (excluding .git)
    - Replaces occurrences of old paths with new paths
    - Reports how many files were modified and how many replacements were made
    - Saves a list of modified files to .link_updates.log

Author: Generated from Hermes Agent session (user: yusiwen)
"""

import os, sys, json, re


def load_rename_map(wiki_dir, map_path=None):
    """Load the rename map from .rename_map.json or a provided path."""
    if map_path is None:
        map_path = os.path.join(wiki_dir, ".rename_map.json")
    if not os.path.exists(map_path):
        print(f"Rename map not found: {map_path}", file=sys.stderr)
        print("Run sanitize-raw-files.py --full-sweep <wiki-dir> first.", file=sys.stderr)
        sys.exit(1)
    with open(map_path, 'r', encoding='utf-8') as f:
        return json.load(f)


def find_md_files(wiki_dir):
    """Find all .md files under wiki_dir, excluding .git."""
    md_files = []
    for root, dirs, files in os.walk(wiki_dir):
        dirs[:] = [d for d in dirs if d != '.git']
        for f in files:
            if f.endswith('.md'):
                md_files.append(os.path.join(root, f))
    return md_files


def sanitize_component(name):
    """Lowercase, spaces-to-hyphens, strip trailing spaces."""
    new = name.rstrip(' ')
    new = new.replace(' ', '-')
    new = new.lower()
    return new


def sanitize_path(path):
    """Sanitize all components of a path, preserving ../ patterns."""
    parts = path.replace('\\\\', '/').split('/')
    new_parts = []
    for p in parts:
        if p in ('', '.', '..'):
            new_parts.append(p)
        else:
            new_parts.append(sanitize_component(p))
    return '/'.join(new_parts)


def find_correct_target_aggressive(abs_path, raw_dir):
    \"\"\"
    Try multiple strategies to find the correct file after sanitization.

    Strategies:
    1. Sanitize all components from root (/)
    2. Sanitize just the basename
    3. Sanitize all components from raw_dir
    4. Walk-by-basename within the export directory
    \"\"\"
    # Strategy 1: Sanitize from root
    rel_root = os.path.relpath(abs_path, '/')
    cand1 = os.path.join('/', sanitize_path(rel_root))
    if os.path.exists(cand1):
        return cand1

    # Strategy 2: Sanitize basename only
    parent = os.path.dirname(abs_path)
    base = os.path.basename(abs_path)
    new_base = sanitize_component(base)
    if new_base != base:
        cand2 = os.path.join(parent, new_base)
        if os.path.exists(cand2):
            return cand2

    # Strategy 3: Sanitize from raw_dir
    try:
        rel_raw = os.path.relpath(abs_path, raw_dir)
        if not rel_raw.startswith('..'):
            cand3 = os.path.join(raw_dir, sanitize_path(rel_raw))
            if os.path.exists(cand3):
                return cand3
    except ValueError:
        pass

    # Strategy 4: Walk the export directory by sanitized basename
    base = sanitize_component(os.path.basename(abs_path))
    # Determine which export dir this file lives in
    try:
        rel_to_raw = os.path.relpath(abs_path, raw_dir)
        export_dir = rel_to_raw.split(os.sep)[0]
        export_path = os.path.join(raw_dir, export_dir)
        if os.path.isdir(export_path):
            for root, dirs, files in os.walk(export_path):
                for f in files:
                    if sanitize_component(f) == base:
                        return os.path.join(root, f)
    except ValueError:
        pass

    return None


def scan_and_replace(md_files, rename_map, wiki_dir, raw_dir=None):
    """
    For each .md file, replace old paths with new paths.

    Phase 1 — Direct string replacement (wiki-root-relative paths):
        Replaces old_rel strings wherever they appear in the content.
        Covers links like: [text](raw/some-export/oldname.md)

    Phase 2 — Relative link resolution (raw/ internal cross-references):
        For files inside raw/, scan markdown link targets, resolve them
        relative to the file's directory, and check if the resolved path
        matches any old_rel in the rename map. If so, replace the link
        target with the new relative path.

        Covers links like: [text](../../../安全/Old Name/Old Name.md)
        These contain NONE of the substring 'raw/...' and are completely
        missed by Phase 1.
    """
    # Sort entries by path length (longest first) to avoid partial replacements
    sorted_paths = sorted(rename_map.items(), key=lambda x: len(x[0]), reverse=True)

    modified_files = []
    total_replacements = 0

    for md_file in md_files:
        try:
            with open(md_file, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f'  ERROR reading {md_file}: {e}', file=sys.stderr)
            continue

        modified = False
        md_dir = os.path.dirname(md_file)

        # --- Phase 1: Direct string replacement ---
        for old_rel, new_rel in sorted_paths:
            if old_rel in content:
                content = content.replace(old_rel, new_rel)
                modified = True

        # --- Phase 2: Resolve relative links within raw/ files ---
        # The regex approach is unreliable for paths containing parentheses,
        # angle brackets, or quoted titles. Use a char-by-char parser instead.
        if raw_dir is not None and md_file.startswith(raw_dir):
            search_pos = 0
            while True:
                start = content.find('](', search_pos)
                if start == -1:
                    break

                link_start = start + 2
                angle_bracket = False
                in_quotes = False
                quote_char = None
                link_end = -1
                paren_depth = 0

                for j in range(link_start, len(content)):
                    c = content[j]
                    if in_quotes:
                        if c == quote_char:
                            in_quotes = False
                        continue
                    if c in ('"', "'"):
                        in_quotes = True
                        quote_char = c
                        continue
                    if c == '<' and not angle_bracket:
                        angle_bracket = True
                        continue
                    if c == '>' and angle_bracket:
                        angle_bracket = False
                        continue
                    if not angle_bracket:
                        if c == '(':
                            paren_depth += 1
                        elif c == ')':
                            if paren_depth > 0:
                                paren_depth -= 1
                            else:
                                link_end = j
                                break

                if link_end == -1:
                    search_pos = start + 2
                    continue

                search_pos = link_end + 1
                raw_link_text = content[link_start:link_end]

                # Extract clean link path (strip brackets, title text)
                clean = raw_link_text.strip()
                clean = clean.replace('<', '').replace('>', '').strip()
                if ' "' in clean:
                    clean = clean[:clean.index(' "')]
                if " '" in clean:
                    clean = clean[:clean.index(" '")]
                clean = clean.strip()

                # Skip non-file references
                if (not clean or clean.startswith(('http://', 'https://', '#', 'wiki:', 'ftp:', 'mailto:'))):
                    continue

                old_text = content[link_start:link_end]
                # Resolve relative to the file's directory
                resolved = os.path.normpath(os.path.join(md_dir, clean))
                rel_resolved = os.path.relpath(resolved, wiki_dir)

                if rel_resolved in rename_map:
                    new_rel_resolved = rename_map[rel_resolved]
                    new_link = os.path.relpath(
                        os.path.join(wiki_dir, new_rel_resolved),
                        md_dir
                    )
                    # Preserve angle-bracket wrapping if original had it
                    if raw_link_text.startswith('<') and raw_link_text.endswith('>'):
                        replacement = f"<{new_link}>"
                    else:
                        replacement = new_link
                    content = content.replace(f"]({old_text}", f"]({replacement}", 1)
                    modified = True
                    total_replacements += 1
                else:
                    # Link target not in rename map — might be broken but not renamed.
                    # Try aggressive resolution: the target may have been renamed
                    # as part of the sweep but not tracked in the map.
                    correct = find_correct_target_aggressive(resolved, raw_dir)
                    if correct:
                        new_rel = os.path.relpath(correct, md_dir)
                        if raw_link_text.startswith('<') and raw_link_text.endswith('>'):
                            replacement = f"<{new_rel}>"
                        else:
                            replacement = new_rel
                        content = content.replace(f"]({old_text}", f"]({replacement}", 1)
                        modified = True
                        total_replacements += 1

        if modified:
            with open(md_file, 'w', encoding='utf-8') as f:
                f.write(content)
            modified_files.append(md_file)

    return modified_files, total_replacements


def main(wiki_dir, map_path=None):
    wiki_dir = os.path.abspath(wiki_dir)
    if not os.path.isdir(wiki_dir):
        print(f"Not a directory: {wiki_dir}", file=sys.stderr)
        return 1

    rename_map = load_rename_map(wiki_dir, map_path)
    print(f"Rename map entries: {len(rename_map)}", file=sys.stderr)

    md_files = find_md_files(wiki_dir)
    print(f".md files to scan: {len(md_files)}", file=sys.stderr)

    # raw_dir is needed for Phase 2 relative-link resolution
    raw_dir = os.path.join(wiki_dir, "raw")
    if not os.path.isdir(raw_dir):
        raw_dir = None
        print("  Note: no raw/ dir found — skipping relative-link resolution", file=sys.stderr)

    modified_files, total_replacements = scan_and_replace(md_files, rename_map, wiki_dir, raw_dir=raw_dir)

    # Save log
    log_path = os.path.join(wiki_dir, ".link_updates.log")
    with open(log_path, 'w', encoding='utf-8') as f:
        for mf in modified_files:
            rel = os.path.relpath(mf, wiki_dir)
            f.write(rel + '\n')
            print(rel)

    summary = {
        "wiki_dir": wiki_dir,
        "files_scanned": len(md_files),
        "files_modified": len(modified_files),
        "total_replacements": total_replacements,
    }
    print(file=sys.stderr)
    print(json.dumps(summary, indent=2), file=sys.stderr)
    return 0 if total_replacements > 0 else 0  # non-zero only on error


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage:", file=sys.stderr)
        print(f"  {sys.argv[0]} <wiki-dir>                 # loads .rename_map.json", file=sys.stderr)
        print(f"  {sys.argv[0]} <wiki-dir> <map.json>      # explicit map file", file=sys.stderr)
        sys.exit(1)

    map_path = sys.argv[2] if len(sys.argv) > 2 else None
    sys.exit(main(sys.argv[1], map_path))
