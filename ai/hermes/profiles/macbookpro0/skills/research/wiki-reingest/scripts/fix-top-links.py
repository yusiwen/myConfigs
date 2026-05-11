#!/usr/bin/env python3
"""
fix-top-links.py — Sync user-curated external links from raw exports to wiki pages.

Scans all raw export directories for user-added links placed between the
`## 目录` (Table of Contents) and the first `#` heading in each markdown file.
These links are user-curated key resources (tutorials, official docs, GitHub repos)
that the user adds at the top of every wolai.app note.

For each raw file with top links, this script finds the corresponding wiki page
(by matching the raw file's relative path against `sources:` entries in wiki page
frontmatter), then inserts any missing external links as a

    > 🔗 **Key Resources:**
    > - [Title](url)

blockquote at the top of the wiki page body.

Usage:
    python3 fix-top-links.py                          # run full scan + fix
    python3 fix-top-links.py --dry-run                 # report only, no changes

The script operates in the wiki repo at /Users/yusiwen/git/mine/wiki.
"""

import re
import os
import sys

WIKI = os.environ.get("WIKI_ROOT", "/Users/yusiwen/git/mine/wiki")
RAW = os.path.join(WIKI, "raw")

# ---------------------------------------------------------------
# Cache: raw source path -> list of wiki page paths
SOURCE_CACHE = None


def build_source_cache():
    """Build a mapping from raw source paths to wiki pages that reference them."""
    cache = {}
    for base in ("concepts", "entities"):
        root = os.path.join(WIKI, base)
        if not os.path.isdir(root):
            continue
        for dirpath, _, filenames in os.walk(root):
            for fname in filenames:
                if not fname.endswith(".md"):
                    continue
                fp = os.path.join(dirpath, fname)
                try:
                    with open(fp, "r", encoding="utf-8") as fh:
                        text = fh.read(2000)
                except (OSError, UnicodeDecodeError):
                    continue
                for m in re.finditer(
                    r"sources:\s*\n(\s+-\s+[^\n]+\n?)+", text
                ):
                    sources_text = m.group(0)
                    for sm in re.finditer(r"-\s+(.+?)(?:\n|$)", sources_text):
                        src = sm.group(1).strip().strip("\"'")
                        src = src.replace("  ", " ")
                        cache.setdefault(src, []).append(fp)
    return cache


def get_top_links(content):
    """
    Extract external links placed between `## 目录\n\n` and the next `# ` heading.

    Returns list of (title, url) tuples for http/https links only.
    Skips anchor (#), internal wiki: references, and empty links.
    """
    if content.startswith("---"):
        end = content.find("---", 3)
        if end != -1:
            content = content[end + 3 :]

    m = re.search(r"## 目录.*?\n\n(.*?)(?=\n# )", content, re.DOTALL)
    if not m:
        return []

    between = m.group(1).strip()
    if not between:
        return []

    links = []
    for match in re.finditer(r"\[([^\]]+)\]\(([^)]+)\)", between):
        title = match.group(1)
        url = match.group(2).split(" ")[0]  # strip optional title="..." suffix

        if url.startswith("#") or url.startswith("wiki:") or not url.strip():
            continue
        if not (url.startswith("http://") or url.startswith("https://")):
            continue

        clean_title = title.replace("**", "").replace("*", "").strip()
        if len(clean_title) > 100:
            clean_title = clean_title[:97] + "..."
        links.append((clean_title, url))

    return links


def add_key_resources(wiki_page, links, dry_run=False):
    """
    Add a `> 🔗 **Key Resources:**` blockquote to the wiki page for links
    not already present in the page body.
    Returns True if the page was modified.
    """
    if not links:
        return False

    with open(wiki_page, "r", encoding="utf-8") as f:
        content = f.read()

    # Filter to missing links only
    missing = []
    for title, url in links:
        if url not in content and title.lower() not in content.lower():
            missing.append((title, url))

    if not missing:
        return False

    # Locate insertion point: after frontmatter H1 line
    body_start = 0
    if content.startswith("---"):
        end = content.find("---", 3)
        if end != -1:
            body_start = end + 3

    h1_match = re.search(r"^# .+$", content[body_start:], re.MULTILINE)
    if not h1_match:
        return False

    insert_pos = body_start + h1_match.end()
    MAX_LINKS = 8

    # Check if page already has a Key Resources block
    if "> 🔗 **Key Resources:**" in content[insert_pos : insert_pos + 500]:
        lines = []
        for title, url in missing[:MAX_LINKS]:
            lines.append(f"> - [{title[:80]}]({url})")
        section_end = content.find("\n\n", insert_pos)
        if section_end == -1:
            section_end = insert_pos + 500
        insert_pos = section_end
        new_content = content[:insert_pos] + "\n" + "\n".join(lines) + content[insert_pos:]
    else:
        lines = ["> 🔗 **Key Resources:**"]
        for title, url in missing[:MAX_LINKS]:
            lines.append(f"> - [{title[:80]}]({url})")
        new_content = content[:insert_pos] + "\n".join(lines) + "\n" + content[insert_pos:]

    if dry_run:
        rel = os.path.relpath(wiki_page, WIKI)
        print(f"  would fix {rel}: +{len(missing)} links")
        return True

    with open(wiki_page, "w", encoding="utf-8") as f:
        f.write(new_content)
    return True


def main():
    dry_run = "--dry-run" in sys.argv

    print(f"{'🔍 DRY RUN —' if dry_run else '🔍'} Scanning raw exports for top-of-page links...")

    # Collect all raw files with top links
    raw_files = []
    for dirpath, _, filenames in os.walk(RAW):
        for fname in filenames:
            if not fname.endswith(".md"):
                continue
            fp = os.path.join(dirpath, fname)
            try:
                with open(fp, "r", encoding="utf-8") as fh:
                    content = fh.read()
            except (OSError, UnicodeDecodeError):
                continue
            links = get_top_links(content)
            if links:
                rel = os.path.relpath(fp, WIKI)
                raw_files.append((rel, links))

    print(f"Found {len(raw_files)} raw files with top links")

    # Build source cache
    global SOURCE_CACHE
    SOURCE_CACHE = build_source_cache()
    print(f"Wiki source references indexed: {len(SOURCE_CACHE)} entries")

    fixed = 0
    skipped = 0

    for rel, links in raw_files:
        wiki_pages = SOURCE_CACHE.get(rel, [])
        for wp in wiki_pages:
            if add_key_resources(wp, links, dry_run=dry_run):
                fixed += 1
            else:
                skipped += 1

    print(f"\n{'=' * 50}")
    print(f"{'DRY RUN — ' if dry_run else ''}Fixed: {fixed} wiki pages")
    print(f"{'DRY RUN — ' if dry_run else ''}Skipped (links already present): {skipped}")

    if not dry_run and fixed > 0:
        print("\n💡 Tip: Run `git diff --stat` to review changes before committing.")
        print("   Suggested commit message:")
        print('   git commit -m "fix: sync Key Resources links from raw exports"')


if __name__ == "__main__":
    main()
