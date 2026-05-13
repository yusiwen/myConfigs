---
name: wiki-reingest
description: "Re-ingest updated zip exports into the wiki: detect new/updated/deleted notes, update raw sources and wiki pages accordingly."
version: 1.1.0
author: Hermes Agent
platforms: [linux, macos]
metadata:
  hermes:
    tags: [wiki, reingest, sync, update]
    category: research
    related_skills: [llm-wiki]
---

# Wiki Re-Ingest Workflow

When the user exports an updated zip file (e.g., `Network.zip`) from their note-taking app, use this workflow to sync the wiki with the changes.

## Orientation: Always Check SCHEMA.md First

Before ANY ingest or re-ingest operation, read the wiki's SCHEMA.md (at wiki root):
- It contains the **canonical** filename convention rules
- It defines the tag taxonomy, frontmatter structure, and placement rules
- Memory can become stale — SCHEMA.md is the source of truth

```bash
read_file "$WIKI/SCHEMA.md"
```

Do NOT rely on cached memory for conventions that may have been updated.

## Principles

- **raw/ is the source of truth** — what's on disk is what the wiki pages reference
- **Match by content, not filename** — original filenames in the zip are unsanitized (uppercase, spaces), but on disk they're sanitized (lowercase, hyphens). Use sha256 of file contents for matching.
- **Wiki pages are derived** — don't auto-delete wiki pages; ask the user about deletions
- **Stale pages need human judgment** — flag updated sources for review, don't auto-rewrite

## Workflow Steps

### ① Extract and Map

Use Python's `zipfile.ZipFile` to extract, not `unzip` — zip filenames may contain `&` or other shell meta-characters that break the terminal tool.

```python
import os, hashlib, shutil, tempfile, zipfile

wiki = "/home/yusiwen/git/mine/wiki"        # resolve from config or env
export_name = "network-export"              # matches raw/<export-name>
zip_path = os.path.expanduser("~/Network.zip")

# Extract via zipfile module (safe with any filename characters)
tmp = tempfile.mkdtemp()
with zipfile.ZipFile(zip_path) as zf:
    zf.extractall(tmp)

# Find the notebook root (the random-ID dir inside the zip)
notebook_root = None
for item in os.listdir(tmp):
    if os.path.isdir(os.path.join(tmp, item)) and item != '__MACOSX':
        notebook_root = os.path.join(tmp, item)
        break
```

### ② Build Content Index (old vs new)

```python
def sha256_file(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()

# Index existing raw files by content hash
# Values are lists because content could appear under multiple paths (unlikely but safe)
existing = {}  # sha256 -> [list of relative paths in raw/]
raw_base = os.path.join(wiki, "raw", export_name)
if os.path.exists(raw_base):
    for root, dirs, files in os.walk(raw_base):
        for f in files:
            fp = os.path.join(root, f)
            h = sha256_file(fp)
            rel = os.path.relpath(fp, raw_base)
            existing.setdefault(h, []).append(rel)

# Index new files from zip by content hash
incoming = {}  # sha256 -> path in zip (single path, content is unique per file)
for root, dirs, files in os.walk(notebook_root):
    for f in files:
        fp = os.path.join(root, f)
        h = sha256_file(fp)
        incoming[h] = fp
```

### ③ Classify Every File

```python
from collections import defaultdict

existing_hashes = set(existing.keys())
incoming_hashes = set(incoming.keys())

new_files = []               # hash only in incoming
updated = []                 # hash in both, but content-different (actually same sha = same content)
renamed = []                 # hash in both, but path differs (source was renamed on disk)
unchanged = []               # hash in both, path same
deleted = []                 # hash only in existing

for h in incoming_hashes:
    new_path = incoming[h]
    if h not in existing_hashes:
        new_files.append(new_path)
    else:
        # Content unchanged — check if path matches
        old_paths = existing[h]
        old_rel_filenames = {os.path.basename(p) for p in old_paths}
        new_basename = os.path.basename(new_path)
        if new_basename not in old_rel_filenames:
            renamed.append((old_paths, new_path))
        else:
            unchanged.append(new_path)

for h in existing_hashes:
    if h not in incoming_hashes:
        for rel_path in existing[h]:
            deleted.append(os.path.join(raw_base, rel_path))
```

### ④ Report to User

Print a clear summary:

```
📥 Network.zip Re-Ingest Report
  ✅ Unchanged: 142 files
  🆕 New: 5 files
  📝 Renamed: 3 files
  🗑️ Deleted from source (not in new export): 3 files
```

Then ask:

- **For new files:** "Create corresponding wiki pages?" (default: yes)
- **For renamed files:** "Update source paths in wiki pages to match?" (default: yes)
- **For deleted files:** "What should I do with the 3 wiki pages whose sources were deleted? Archive? Keep? Nothing?"

**Note:** Since matching is by sha256, there is no "updated content" case — if sha256 matches, content is identical. If the user edited a note and re-exported, the sha256 will differ, so it will appear as a new file (old hash becomes "deleted", new hash becomes "new"). This is correct behavior.

### ⑤ Execute

- **New files:** Copy to `raw/<export-name>/` with sanitized path, then run the standard ingest workflow from `llm-wiki` (Importing Notebook/App Exports) to create wiki pages.
- **Renamed files:** Update the raw source at the new path, then run the provenance reference update (replace old raw path with new raw path across all wiki pages).
- **Deleted files:** Follow user's decision.
- **Clean up:** `shutil.rmtree(tmp)`.

## Bulk Rename & Sanitization (Full-Sweep)

When the user reports that file/dir names in `raw/` violate naming rules (e.g., wrong agent didn't have the memory), you can run a full sweep across ALL export dirs:

### Full-Sweep Workflow

```python
# Step 1: Sanitize all names across ALL raw/ export dirs
# Uses sanitize-raw-files.py with --full-sweep
# This renames children before parents and detects collisions
```

Call `execute_code` with the following logic:

```python
import subprocess, json
script = "/home/yusiwen/.hermes/profiles/matebookxpro0/skills/research/wiki-reingest/scripts/sanitize-raw-files.py"
result = subprocess.run(
    ["python3", script, "--full-sweep", "/home/yusiwen/git/mine/wiki"],
    capture_output=True, text=True
)
print(result.stdout)
if result.returncode != 0:
    print("STDERR:", result.stderr)
```

This saves a `.rename_map.json` in the wiki root and prints the map. Then:

```python
# Step 2: Update all internal wiki links
update_script = "/home/yusiwen/.hermes/profiles/matebookxpro0/skills/research/wiki-reingest/scripts/update-wiki-links.py"
result = subprocess.run(
    ["python3", update_script, "/home/yusiwen/git/mine/wiki"],
    capture_output=True, text=True
)
print(result.stdout)
print("STDERR:", result.stderr)
```

### What Each Script Does

| Script | Purpose | Input | Output |
|--------|---------|-------|--------|
| `sanitize-raw-files.py` | Rename files/dirs to conform | `raw/some-export` or `--full-sweep <wiki>` | JSON old->new path map + `.rename_map.json` |
| `update-wiki-links.py` | Update wiki-root-relative `[[links]]` | wiki dir + `.rename_map.json` | Updates .md files, logs to `.link_updates.log` |
| `fix-relative-links.py` | Fix relative cross-references (`../../../`) inside raw/ files | `<wiki-root>` | Updates .md files in-place |

> **Order matters:** Run `sanitize-raw-files.py` → `update-wiki-links.py` → `fix-relative-links.py`. The relative-link fix must come LAST because it scans the already-sanitized filesystem to resolve broken links.

### Sanitization Rules

See the wiki's `SCHEMA.md` → **Filename Convention** section for the canonical rules. Summary:

1. **Lowercase** — all names become lowercase
2. **Spaces to hyphens** — replace ` ` with `-`
3. **Strip trailing spaces**

Preserve everything else: Chinese characters, `()`, `&`, `'`, `.`, `-`, `_`, numbers. UTF-8 works on modern Windows and Linux — no need to strip non-ASCII.

### Pitfall: Wrong agent already ingested

If a different agent (without the naming convention memory) ingested new files into `raw/`, run the full-sweep workflow immediately after ingestion to fix the names. The link-update step will correct references across the entire wiki.

**Important:** The basic `update-wiki-links.py` script only replaces wiki-root-relative paths (e.g. `raw/安全/Linux Access Control List (ACL)/...`). It does NOT handle relative cross-references within raw/ files (`../../../安全/...`). After any full-sweep rename, **always run `fix-relative-links.py` as a third pass** to catch these.

## Pitfalls

- **Don't match by filename** — the zip has original names (`TCP.md`), on disk they're sanitized (`tcp.md`). Always match by sha256 content hash.
- **Don't auto-delete wiki pages** — a source file being removed from the export doesn't mean the wiki page is wrong. The page may synthesize multiple sources.
- **Don't re-ingest everything** — re-running the full auto-ingest would create duplicate pages. Only process truly new/updated files.
- **SHA256 changes for formatting-only edits** — if the user just re-formatted a note, the hash changes but the semantic content is the same. Flag as "updated" but note this caveat.
- **Rename deepest first** — use `os.walk(topdown=False)` or sort by path length descending so files and subdirectories are renamed before their parents. Otherwise parent renames invalidate pre-computed child paths.
- **Use `os.rename`, not `shutil.move`** for same-filesystem renames — `os.rename` is atomic within a filesystem. `shutil.move` falls back to copy+delete, which is slow and non-atomic.
- **Maintain old→new path map** for the link-update phase. Save the map to `.rename_map.json` in the wiki root before starting the rename, so both the rename and link-update phases use the same canonical mapping.
- **Use zipfile.ZipFile, not unzip shell command** — filenames with `&` or shell meta-chars break the terminal tool. Python's zipfile module handles all filename characters correctly.
- **Clean up temp dirs** — use `shutil.rmtree()` (not `rm -rf` via terminal) to avoid terminal timeout on large dirs.

### Pitfall: Simple string-replacement misses relative cross-references

`update-wiki-links.py` replaces wiki-root-relative paths (e.g. `raw/安全/Linux Access Control List...`). But raw/ source files also use **relative cross-references** (`../../../安全/Linux Access Control List...`) that will NOT be caught by a simple string-replacement approach. After any full-sweep rename, always run `fix-relative-links.py` as a second pass to catch these.

### Pitfall: Markdown link parser confusion with parentheses

When fixing links programmatically, the naive `re.findall(r'\]\(([^)]+)\)', content)` regex **breaks** on links containing parentheses in their display text or title. For example:

```
[Linux Access Control List (ACL)](<path/file.md> "with (parens)")
```

The regex stops at the first `)` inside `(ACL)`. This can cause:
- Truncated links (only part of the path gets replaced)
- Corrupted file content (surrounding text gets consumed into the link text)
- Cascading failures across multiple automated passes

**Fix:** Use character-by-character parsing with bracket depth tracking (see `fix-relative-links.py` for the implementation). Never use `re.findall(r'\]\(([^)]+)\)'` on markdown files that may contain parenthesized display text.

### Pitfall: Multiple automated passes on the same file cause corruption

Running multiple independent link-fix passes on the same file (e.g., first fixing root-relative paths, then fixing relative paths) can corrupt the file if the first pass leaves partially-broken links that the second pass misinterprets. To avoid this:

1. **Run `fix-relative-links.py` as a single pass** — it handles both root-relative and relative paths in one scan
2. **Test on one file first** — run the script on a single known-broken file and verify the output before sweeping all 3,000+
3. **Save a backup** of the rename map (`.rename_map.json`) before starting any automated fix
4. **Inspect the first 5 files** the script modifies to catch corruption early
