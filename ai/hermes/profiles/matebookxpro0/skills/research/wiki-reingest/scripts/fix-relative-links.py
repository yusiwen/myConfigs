#!/usr/bin/env python3
"""
fix-relative-links.py — Fix relative cross-references in raw/ wiki files
after a bulk-filename sanitization sweep.

Problem: The simple `update-wiki-links.py` only replaces wiki-root-relative
paths (e.g. `raw/安全/Linux Access Control List...`). But raw/ files also
use relative cross-references (`../../../安全/Linux Access Control List...`)
that were NOT updated by the initial sweep.

This script:
1. Walks all .md files in raw/
2. Finds every markdown link `[text](path)` including angle-bracket-wrapped `<path>`
3. Resolves each relative link to an absolute path
4. If the target doesn't exist (because the rename renamed it), tries multiple
   strategies to find the correct target by applying the same sanitization rules
5. Updates the link if found

Usage:
    python3 fix-relative-links.py <wiki-root>

Example:
    python3 fix-relative-links.py /home/yusiwen/git/mine/wiki

Caveats:
    - Runs ONE pass. If you fix broken links and then rename more files,
      re-run this script.
    - Expects the rename sweep to have already happened (files on disk have
      sanitized names, relative links still have old names).
    - Some links may genuinely be unfixable (pre-existing broken links from
      the notebook export, protocol-stripped URLs).
"""

import os, re, sys

def sanitize_component(name):
    """Apply filename sanitization rules (must match SCHEMA.md)."""
    new = name.rstrip(' ')
    new = new.replace(' ', '-')
    new = new.lower()
    return new

def sanitize_path(path):
    """Sanitize every component of a path, preserving . and .."""
    parts = path.replace('\\', '/').split('/')
    new_parts = []
    for p in parts:
        if p in ('', '.', '..'):
            new_parts.append(p)
        else:
            new_parts.append(sanitize_component(p))
    return '/'.join(new_parts)

def find_correct_target(abs_path, raw_dir):
    """Try multiple strategies to find the correct file after sanitization."""
    # S1: Sanitize all components from root
    rel_root = os.path.relpath(abs_path, '/')
    c1 = os.path.join('/', sanitize_path(rel_root))
    if os.path.exists(c1):
        return c1

    # S2: Sanitize basename only
    parent, base = os.path.dirname(abs_path), os.path.basename(abs_path)
    new_base = sanitize_component(base)
    if new_base != base:
        c2 = os.path.join(parent, new_base)
        if os.path.exists(c2):
            return c2

    # S3: Sanitize from raw_dir
    try:
        rel_raw = os.path.relpath(abs_path, raw_dir)
        if not rel_raw.startswith('..'):
            c3 = os.path.join(raw_dir, sanitize_path(rel_raw))
            if os.path.exists(c3):
                return c3
    except ValueError:
        pass

    # S4: Walk up to raw_dir and check sanitized subpaths
    abs_parts = os.path.normpath(abs_path).split(os.sep)
    raw_parts = os.path.normpath(raw_dir).split(os.sep)
    for i in range(len(raw_parts), len(abs_parts)):
        sub = abs_parts[len(raw_parts):i+1]
        c4 = os.path.join(raw_dir, sanitize_path('/'.join(sub)))
        if os.path.exists(c4):
            return c4

    # S5: Search by sanitized basename within export directory
    san_base = sanitize_component(base)
    rel_wiki = os.path.relpath(abs_path, os.path.dirname(raw_dir))
    parts = rel_wiki.split(os.sep)
    if len(parts) >= 2 and parts[0] == 'raw':
        export_dir = parts[1]
        export_path = os.path.join(raw_dir, export_dir)
        for root, dirs, files in os.walk(export_path):
            for f in files:
                if sanitize_component(f) == san_base:
                    return os.path.join(root, f)

    return None

def extract_link_path(raw_text):
    """Extract the actual file path from raw link text, stripping title etc."""
    text = raw_text.strip()
    text = text.replace('<', '').replace('>', '').strip()
    if ' "' in text:
        text = text[:text.index(' "')]
    if " '" in text:
        text = text[:text.index(" '")]
    return text.strip()


def main(wiki_root):
    raw_dir = os.path.join(wiki_root, 'raw')
    if not os.path.isdir(raw_dir):
        print(f"Error: {raw_dir} does not exist")
        sys.exit(1)

    # Collect all .md files
    all_files = []
    for root, dirs, files in os.walk(raw_dir):
        for f in files:
            if f.endswith('.md'):
                all_files.append(os.path.join(root, f))

    print(f"Scanning {len(all_files)} files...")

    total_fixed = 0
    total_unfixable = 0
    total_modified = 0

    for file_path in all_files:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        original = content
        modifications = 0
        src_dir = os.path.dirname(file_path)

        # Character-by-character ]( parsing to handle nested parens and titles
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

            raw_link = content[link_start:link_end]
            clean_link = extract_link_path(raw_link)

            # Skip non-file references
            if (not clean_link or
                clean_link.startswith(('http://', 'https://', '#', 'wiki:', 'ftp://', 'mailto:'))):
                continue

            old_text = content[link_start:link_end]
            abs_target = os.path.normpath(os.path.join(src_dir, clean_link))

            if os.path.exists(abs_target):
                continue  # already valid

            correct = find_correct_target(abs_target, raw_dir)
            if correct:
                new_rel = os.path.relpath(correct, src_dir)
                if raw_link.startswith('<') and raw_link.endswith('>'):
                    new_link_text = f"<{new_rel}>"
                else:
                    new_link_text = new_rel
                content = content.replace(f"]({old_text}", f"]({new_link_text}", 1)
                modifications += 1
                total_fixed += 1
            else:
                total_unfixable += 1

        if modifications > 0:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            total_modified += 1

    print(f"\nDone. Fixed: {total_fixed}  Unfixable: {total_unfixable}  Files modified: {total_modified}")


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python3 fix-relative-links.py <wiki-root>")
        sys.exit(1)
    main(sys.argv[1])
