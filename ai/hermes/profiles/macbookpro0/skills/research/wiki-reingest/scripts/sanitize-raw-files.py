#!/usr/bin/env python3
"""
Reusable file/dir name sanitizer for wiki raw/ exports.

Call from agent-tool or inline via execute_code.

Usage:
    python3 sanitize-raw-files.py /path/to/wiki/raw/some-export

What it does:
    - Lowercases all file/directory names
    - Replaces spaces with hyphens
    - Strips trailing whitespace/dots
    - Preserves Chinese characters, &, (), and all other Unicode
    - Renames files FIRST, then directories bottom-up
    - Returns a JSON mapping of old->new paths for reference updates

Author: Generated from Hermes Agent session (user: yusiwen)
"""

import os, re, sys, json
from collections import defaultdict


def fix_name(name):
    """Only: lowercase, spaces->hyphens, trim trailing whitespace/dots."""
    name = name.strip()
    name = name.lower()
    name = re.sub(r' +', '-', name)
    name = name.rstrip('.')
    return name


def fix_filename(fname):
    """Fix a filename, preserving extension case."""
    dot = fname.rfind('.')
    if dot > 0:
        return fix_name(fname[:dot]) + fname[dot:].lower()
    return fix_name(fname)


def main(raw_dir):
    if not os.path.isdir(raw_dir):
        print(f"Not a directory: {raw_dir}", file=sys.stderr)
        return 1

    # Build rename plan: all entries, bottom-up order
    entries = []  # (is_dir, old_path, new_path)
    for root, dirs, files in os.walk(raw_dir):
        for f in files:
            if f.lower() in ('.gitkeep',):
                continue
            new_name = fix_filename(f)
            if new_name != f:
                entries.append((False, os.path.join(root, f), os.path.join(root, new_name)))
        for d in dirs:
            new_name = fix_name(d)
            if new_name != d:
                entries.append((True, os.path.join(root, d), os.path.join(root, new_name)))

    # Sort by depth DESCENDING so children are processed before parents
    entries.sort(key=lambda x: -len(x[1]))

    # Execute renames, building mapping
    path_map = {}
    for is_dir, old, new in entries:
        try:
            if os.path.exists(new):
                if is_dir:
                    # Target dir exists — move children individually, then remove old
                    for item in os.listdir(old):
                        src_item = os.path.join(old, item)
                        dst_item = os.path.join(new, item)
                        if os.path.exists(dst_item):
                            if os.path.isdir(src_item) and os.path.isdir(dst_item):
                                for sub in os.listdir(src_item):
                                    shutil.move(os.path.join(src_item, sub), os.path.join(dst_item, sub))
                                try:
                                    os.rmdir(src_item)
                                except OSError:
                                    pass
                            else:
                                os.remove(dst_item)
                                shutil.move(src_item, dst_item)
                        else:
                            shutil.move(src_item, dst_item)
                    try:
                        os.rmdir(old)
                    except OSError:
                        pass  # may still have protected entries
                else:
                    # File collision — shouldn't happen if same parent, but handle
                    os.remove(new)
                    os.rename(old, new)
            else:
                os.rename(old, new)

            # Record mapping
            rel_old = os.path.relpath(old, os.path.join(raw_dir, '..', '..'))
            rel_new = os.path.relpath(new, os.path.join(raw_dir, '..', '..'))
            path_map[rel_old] = rel_new

        except OSError as e:
            print(f"  SKIP: {e}", file=sys.stderr)

    print(json.dumps(path_map, indent=2, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <raw-export-dir>", file=sys.stderr)
        sys.exit(1)
    sys.exit(main(sys.argv[1]))
