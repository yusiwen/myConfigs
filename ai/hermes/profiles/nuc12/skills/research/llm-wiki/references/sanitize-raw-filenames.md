# Sanitizing Raw Filenames for Windows Compatibility

When importing ZIP exports from note-taking apps, raw filenames often contain
spaces, uppercase, and trailing whitespace that break Windows compatibility
and cause tooling issues. This reference captures the exact, proven workflow.

## The Golden Rule

**Only do three things:**
1. Convert to lowercase
2. Replace spaces (one or more) with a single hyphen
3. Strip trailing whitespace and trailing dots

**Do NOT touch:**
- Chinese characters (UTF-8 works fine on modern Windows and Linux)
- Parentheses `()`, ampersands `&`, brackets `[]`, or any other printable UTF-8
- Emoji, accents, or any other non-ASCII Unicode (keep them all)

Hashing Chinese names to `chinese-xxxxx` is destructive and wrong — it makes
source files untraceable.

## Renaming Strategy

File renames MUST happen BEFORE directory renames, because:

```
Files first:  /old-dir/UPPERCASE-FILE.md → /old-dir/uppercase-file.md  (parent still exists)
Dirs second:  /old-dir → /new-dir  (renames entire container, carrying renamed files)
```

If dirs are renamed first, all pre-computed old file paths become invalid.

## Working Script (Python)

This is the exact script that worked on a 2,147-item rename with zero errors:

```python
import os, re, shutil

WIKI_ROOT = "/home/yusiwen/git/mine/wiki"
RAW_DIR = os.path.join(WIKI_ROOT, "raw")

def fix_name(name):
    """lowercase, spaces->hyphens, strip trailing space/dot."""
    name = name.strip()
    name = name.lower()
    name = re.sub(r' +', '-', name)
    name = name.rstrip('.')
    return name

def fix_filename(fname):
    dot = fname.rfind('.')
    if dot > 0:
        return fix_name(fname[:dot]) + fname[dot:].lower()
    return fix_name(fname)

# Build list: (is_dir, old_path, new_path)
all_items = []
for root, dirs, files in os.walk(RAW_DIR):
    for f in files:
        if f.lower() in ('.gitkeep',): continue
        new_name = fix_filename(f)
        if new_name != f:
            all_items.append((False, os.path.join(root, f), os.path.join(root, new_name)))
    for d in dirs:
        new_name = fix_name(d)
        if new_name != d:
            all_items.append((True, os.path.join(root, d), os.path.join(root, new_name)))

# Sort by depth DESCENDING (deepest path first)
all_items.sort(key=lambda x: -len(x[1]))

path_map = {}
for is_dir, old, new in all_items:
    try:
        if os.path.exists(new):
            if is_dir:
                # Move contents of old into existing new, then remove old
                for item in os.listdir(old):
                    s, d = os.path.join(old, item), os.path.join(new, item)
                    if os.path.exists(d):
                        if os.path.isdir(s) and os.path.isdir(d):
                            for sub in os.listdir(s):
                                shutil.move(os.path.join(s, sub), os.path.join(d, sub))
                            try: os.rmdir(s)
                            except: pass
                        else:
                            os.remove(d); shutil.move(s, d)
                    else:
                        shutil.move(s, d)
                try: os.rmdir(old)
                except: pass
            else:
                os.remove(new); os.rename(old, new)
        else:
            os.rename(old, new)
        old_rel = os.path.relpath(old, WIKI_ROOT).replace(os.sep, '/')
        new_rel = os.path.relpath(new, WIKI_ROOT).replace(os.sep, '/')
        if old_rel != new_rel:
            path_map[old_rel] = new_rel
    except OSError as e:
        print(f"  ERR: {e}")
```

## Updating Provenance References

After renaming, scan all wiki pages and update their `sources:` frontmatter
and `^[raw/...]` provenance markers:

```python
import os
ref_dirs = [os.path.join(WIKI_ROOT, d) for d in ['concepts', 'entities', 'comparisons']]
path_items = sorted(path_map.items(), key=lambda x: -len(x[0]))

for rd in ref_dirs:
    if not os.path.isdir(rd): continue
    for root, dirs, files in os.walk(rd):
        for f in files:
            if not f.endswith('.md'): continue
            fp = os.path.join(root, f)
            with open(fp, 'r') as fh: content = fh.read()
            new_content = content; changed = False
            for old_rel, new_rel in path_items:
                if old_rel in new_content:
                    new_content = new_content.replace(old_rel, new_rel)
                    changed = True
            if changed:
                with open(fp, 'w') as fh: fh.write(new_content)
```

**Important:** Sort path items by length descending (`-len(x[0])`) so longer
paths (e.g., `raw/.../deep/path/file.md`) are replaced BEFORE shorter ones
(e.g., `raw/.../deep/path/`). Otherwise partial matches corrupt paths.

### Companion Scripts for Full-Sweep + Link Update

For production use, use the packaged scripts under the `wiki-reingest` skill instead.
**⚠ Run all three steps in order — each one catches what the previous missed:**

```bash
# Step 1: Sanitize ALL export dirs under raw/ at once
python3 ~/.hermes/profiles/matebookxpro0/skills/research/wiki-reingest/scripts/sanitize-raw-files.py \
    --full-sweep /home/yusiwen/git/mine/wiki

# Step 2: Update wiki-root-relative [[links]] across the wiki
python3 ~/.hermes/profiles/matebookxpro0/skills/research/wiki-reingest/scripts/update-wiki-links.py \
    /home/yusiwen/git/mine/wiki

# Step 3: Fix relative cross-references within raw/ files (../../ paths)
# REQUIRED — Phase 2 misses these entirely
python3 ~/.hermes/profiles/matebookxpro0/skills/research/wiki-reingest/scripts/fix-relative-links.py \
    /home/yusiwen/git/mine/wiki
```

**Why three passes?** Phase 2 only replaces strings that contain `raw/...` (wiki-root-relative). But raw/ files link to each other with relative paths like `../../../安全/Linux Access Control List/...` — these contain zero occurrences of `raw/...` and are completely missed by a simple string-replace. Phase 3 resolves every markdown link `](path)` character-by-character, checks if the target exists on disk, and tries multiple strategies to find the correct sanitized target.
```

The `sanitize-raw-files.py` script:
- Supports both single-export (`raw/export-name`) and `--full-sweep` modes
- Checks for collisions before renaming
- Renames deepest-first (children before parents)
- Saves `.rename_map.json` for the link-update phase
- Reports success/error counts

The `update-wiki-links.py` script:
- Reads `.rename_map.json` (produced by step 1)
- Scans ALL `.md` files under the wiki root
- Replaces old paths with new paths
- Saves `.link_updates.log` with all modified files

## Pitfalls

- **Shell meta-characters in filenames (especially `&`):** The terminal tool
  interprets `&` as a background operator even inside quotes. Always use
  Python/`execute_code` for operations on these files — copy, rename, etc.
- **Chinese-only names:** When a file contains ONLY Chinese characters (e.g.,
  `问题.md`), `fix_name` produces an empty string. Handle this by checking
  `if not name:` and leaving those names unchanged rather than hashing them.
- **Unbalanced parentheses in original names:** Some notebook exports produce
  directory names like `Open Container Initiative (OCI` (no closing paren).
  These survive the rename with `(oci` as-is. When crafting reference updates,
  match the actual on-disk name exactly — the reference file might have a
  closing paren that doesn't exist.
- **Line-wrapped paths in markdown files:** Long `sources:` lists can wrap
  across multiple lines in the markdown source. A simple substring replace
  may not catch split references. Use `read_file` to verify.
- **Concurrent subagent edits to `index.md` / `log.md`:** Never let 2+
  subagents patch the same file. The parent should collect results and do a
  single update pass.
