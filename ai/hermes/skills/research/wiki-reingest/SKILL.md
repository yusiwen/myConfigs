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

```python
import os, hashlib, shutil, tempfile
from pathlib import Path

wiki = "/home/yusiwen/git/mine/wiki"
export_name = "network-export"  # e.g., corresponds to raw/network-export/
zip_path = os.path.expanduser("~/Network.zip")

# Extract to temp dir
tmp = tempfile.mkdtemp()
os.system(f"unzip -o {zip_path} -d {tmp}")

# Find the notebook root (the random-ID dir inside the zip)
notebook_root = None
for item in os.listdir(tmp):
    if os.path.isdir(os.path.join(tmp, item)):
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
incoming = {}  # sha256 -> path in zip
md_files = []
for root, dirs, files in os.walk(notebook_root):
    for f in files:
        if f.endswith('.md'):
            fp = os.path.join(root, f)
            h = sha256_file(fp)
            incoming[h] = fp
            md_files.append(fp)
```

### ③ Classify Every File

```python
new_files = []      # hash not in existing
updated_files = []  # hash in existing, but old name/path differs
unchanged_files = []  # hash matches exactly
deleted_files = []  # in existing but not in incoming

existing_hashes = set(existing.keys())
incoming_hashes = set(incoming.keys())

for h in incoming_hashes:
    if h not in existing_hashes:
        new_files.append(incoming[h])
    else:
        unchanged_files.append(incoming[h])
        # Check if the path has changed (renamed source)
        old_paths = existing[h]
        for op in old_paths:
            # Compare normalized paths
            pass  # log if path differs

for h in existing_hashes:
    if h not in incoming_hashes:
        for rel_path in existing[h]:
            deleted_files.append(os.path.join(raw_base, rel_path))
```

### ④ Report to User

Print a clear summary:

```
📥 Network.zip Re-Ingest Report
  ✅ Unchanged: 142 files
  🆕 New: 5 files
  📝 Updated: 8 files
  🗑️ Deleted from source: 3 files
```

Then ask:

- **For new files:** "Create corresponding wiki pages?" (default: yes)
- **For updated files:** "Update raw sources and flag wiki pages for review?" (default: yes)
- **For deleted files:** "What should I do with the 3 wiki pages whose sources were deleted? Archive? Keep? Remove references?"

### ⑤ Execute

- **New files:** Copy to `raw/network-export/` with sanitized path, then run the ingest workflow from `llm-wiki` skill to create wiki pages.
- **Updated files:** Overwrite raw files with new content. For each affected wiki page, append a note to the wiki page body or add to log.md: `## [YYYY-MM-DD] flag | Source updated — verify content still accurate`.
- **Deleted files:** Follow user's decision.

## Pitfalls

- **Don't match by filename** — the zip has original names (`TCP.md`), on disk they're sanitized (`tcp.md`). Always match by sha256 content hash.
- **Don't auto-delete wiki pages** — a source file being removed from the export doesn't mean the wiki page is wrong. The page may synthesize multiple sources.
- **Don't re-ingest everything** — re-running the full auto-ingest would create duplicate pages. Only process truly new/updated files.
- **SHA256 changes for formatting-only edits** — if the user just re-formatted a note, the hash changes but the semantic content is the same. Flag as "updated" but note this caveat.
- **Raw files may have been sanitized** — filenames on disk differ from zip names (lowercase, hyphens). When copying new files, apply the same sanitization: `fix_name()` from the rename workflow.
