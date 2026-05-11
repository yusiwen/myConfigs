---
name: wiki-reingest
description: "Re-ingest updated zip exports into the wiki: detect new/updated/deleted notes, update raw sources and wiki pages accordingly."
version: 1.0.0
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

### ⑥ Post-Ingest: Sync Key Resources Links

Raw exports from wolai.app frequently have user-curated external links placed between the `## 目录` (TOC) and the first `#` heading — tutorials, official docs, and GitHub repos the user considered most important for that topic.

After re-ingesting new/updated files, run the batch fix script to sync these links to the corresponding wiki pages:

```bash
python3 scripts/fix-top-links.py          # full scan + fix
python3 scripts/fix-top-links.py --dry-run  # preview only
```

The script:
1. Scans ALL raw export directories for files with top-of-page links (between TOC and first H1)
2. Matches raw files to wiki pages via frontmatter `sources:` references
3. Inserts any missing external links as a `> 🔗 **Key Resources:**` blockquote at the top of the wiki page body
4. Skips links already present in the page (dedup by URL or title text match)

This is safe to run repeatedly — it's idempotent and won't duplicate existing links.

## Pitfalls

- **Don't match by filename** — the zip has original names (`TCP.md`), on disk they're sanitized (`tcp.md`). Always match by sha256 content hash.
- **Don't auto-delete wiki pages** — a source file being removed from the export doesn't mean the wiki page is wrong. The page may synthesize multiple sources.
- **Don't re-ingest everything** — re-running the full auto-ingest would create duplicate pages. Only process truly new/updated files.
- **SHA256 changes for formatting-only edits** — if the user just re-formatted a note, the hash changes but the semantic content is the same. Flag as "updated" but note this caveat.
- **Sanitize filenames correctly** — only lowercase, replace spaces with hyphens, strip trailing whitespace. Do NOT strip Chinese characters, `&`, `()`, or any other Unicode. UTF-8 works on modern Windows and Linux. See `scripts/sanitize-raw-files.py` for a reusable implementation.
- **Rename files BEFORE directories** — if you rename directories first, pre-computed old file paths become invalid. Always rename files first while parent directories still have their old names, then rename directories bottom-up (deepest first).
- **Use zipfile.ZipFile, not unzip shell command** — filenames with `&` or shell meta-chars break the terminal tool. Python's zipfile module handles all filename characters correctly.
- **Clean up temp dirs** — use `shutil.rmtree()` (not `rm -rf` via terminal) to avoid terminal timeout on large dirs.
