# Fixing Relative Links After Bulk Rename

After renaming files/dirs in `raw/`, internal cross-references using **relative paths** (`../../`) are still broken because they were expressed as relative paths in the source markdown — not as wiki-root-absolute paths. Simple string replacement (which catches `raw/some-export/old-name.md`) misses these entirely.

## The Problem

Renamed: `安全/Linux Access Control List (ACL)` → `安全/linux-access-control-list-(acl)`

A reference like:
```markdown
[ACL](<../../../安全/Linux Access Control List (ACL)/Linux Access Control List (ACL).md> "Linux Access Control List (ACL)")
```

Contains **zero** occurrences of `raw/operating-system-export/安全/Linux Access Control List (ACL)/...` — the string `raw/` never appears. So direct string replacement does nothing.

## The 3-Pass Approach

In practice, a single pass is never enough. Use these three passes in sequence:

### Pass 1: Direct string replacement

Replace old wiki-root-relative paths with new ones across ALL `.md` files. Catches `[text](raw/some-export/oldname.md)` style references.

```python
sorted_paths = sorted(rename_map.items(), key=lambda x: len(x[0]), reverse=True)
for old_rel, new_rel in sorted_paths:
    if old_rel in content:
        content = content.replace(old_rel, new_rel)
```

### Pass 2: Robust relative-link parser

For each `.md` file in `raw/`, parse every markdown link `](path)` with a character-by-character state machine that handles:

- **Angle brackets** `<path>` — markdown allows these to wrap paths containing parentheses
- **Quoted titles** `path "title"` — the title after the path must be stripped before resolving
- **Nested parentheses** — track parenthesis depth to find the correct closing `)`

```python
def extract_link_path(raw_text):
    """Extract the actual file path from raw link text, stripping title etc."""
    text = raw_text.strip()
    text = text.replace('<', '').replace('>', '').strip()
    if ' "' in text:
        text = text[:text.index(' "')]
    if " '" in text:
        text = text[:text.index(" '")]
    return text.strip()
```

The char-by-char parser tracks `angle_bracket`, `in_quotes`, and `paren_depth` to correctly find the link boundary. See the `update-wiki-links.py` script for the full implementation.

### Pass 3: Aggressive target resolution

For each broken link, try multiple strategies to find the correct target:

| Strategy | Description |
|----------|-------------|
| 1. Sanitize from `/` | Apply sanitize_path() to the absolute path from root |
| 2. Sanitize basename | Only lowercase the filename component |
| 3. Sanitize from `raw/` | Compute relative to raw_dir, sanitize each component |
| 4. Walk-and-search | Search the file's export directory by sanitized basename |

```python
def find_correct_target_aggressive(abs_path):
    # Strategy 1
    rel_root = os.path.relpath(abs_path, '/')
    cand1 = os.path.join('/', sanitize_path(rel_root))
    if os.path.exists(cand1): return cand1
    
    # Strategy 2
    parent = os.path.dirname(abs_path)
    new_base = sanitize_component(os.path.basename(abs_path))
    cand2 = os.path.join(parent, new_base)
    if os.path.exists(cand2): return cand2
    
    # Strategy 3
    rel_raw = os.path.relpath(abs_path, raw_dir)
    if not rel_raw.startswith('..'):
        cand3 = os.path.join(raw_dir, sanitize_path(rel_raw))
        if os.path.exists(cand3): return cand3
    
    # Strategy 4
    base = sanitize_component(os.path.basename(abs_path))
    export_dir = os.path.basename(os.path.dirname(os.path.dirname(abs_path)))
    export_path = os.path.join(raw_dir, export_dir)
    for root, dirs, files in os.walk(export_path):
        for f in files:
            if sanitize_component(f) == base:
                return os.path.join(root, f)
    
    return None
```

## Collateral Damage Risk

**The parser can corrupt links when link text contains parentheses.** Example:
```markdown
[Linux Access Control List (ACL)](<../../../安全/...>)
```
The `](` pattern appears inside the `[link text]` portion, causing the parser to think the link text `... (ACL)` is the link target. This can truncate or mangle the subsequent link path.

**How to detect:** After running the fix, scan the modified files for any that shrank significantly (>20% size reduction) or lost section headers.

**How to restore:** Keep a backup of the raw/ directory before running the fix, or restore individual files from git if versioned. The fix for `文件系统相关.md` in this session required a full manual restore of 5 sections (chattr, getfattr, ln, file managers, entr).

## Verification

After all passes, run this check:

```python
for root, dirs, files in os.walk(raw_dir):
    for f in files:
        if not f.endswith('.md'): continue
        fp = os.path.join(root, f)
        # Find all markdown links
        for m in re.finditer(r'\]\(([^)]+)\)', open(fp).read()):
            link = m.group(1).strip()
            if link.startswith(('http://','https://','#','wiki:','ftp:','mailto:')):
                continue
            clean = link.replace('<','').replace('>','').strip()
            if ' "' in clean: clean = clean[:clean.index(' "')]
            if " '" in clean: clean = clean[:clean.index(" '")]
            resolved = os.path.normpath(os.path.join(os.path.dirname(fp), clean))
            if not os.path.exists(resolved):
                print(f"STILL BROKEN: {os.path.relpath(fp, wiki)} -> {clean}")
```

Only protocol-stripped web URLs (`//upload-images.jianshu.io/...`, `/hackernoon/...`) are expected to survive as genuinely unresolvable.
