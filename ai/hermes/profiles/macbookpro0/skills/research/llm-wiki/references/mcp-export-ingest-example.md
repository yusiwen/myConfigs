# Worked Example: Ingesting MCP-Exported Wolai Notes (37 files, 65 pages)

Session from 2026-05-11. User had Wolai "Web" notes exported to `raw/web-export/` (37 files across 12 topic folders). This example documents the ingest workflow.

## Source Structure

```
raw/web-export/
├── Web.md                          # Root index
├── CDN/, Cookie/, DNS/, ...        # 11 topic subdirectories
├── 安全/                           # Security (deep, 14 sections)
│   ├── HTTPS/Let's-Encrypt/        # 3 levels deep
└── 前端开发/                        # Frontend (deep, 7 sub-pages)
    ├── Frameworks/React/Next.js/   # 4 levels deep
    └── ...
```

## Step 1: Add Frontmatter to Raw Files

Before any ingest, every raw `.md` needs a `sha256` frontmatter for drift detection:

```python
import hashlib, os, glob
from datetime import date
export_dir = f"{WIKI}/raw/web-export"
today = str(date.today())
for fp in glob.glob(f"{export_dir}/**/*.md", recursive=True):
    with open(fp, 'r') as f: content = f.read()
    if content.startswith('---'): continue
    sha = hashlib.sha256(content.encode()).hexdigest()
    fm = f"""---
source_export: wolai-web
ingested: {today}
sha256: {sha}
---

"""
    with open(fp, 'w') as f: f.write(fm + content)
```

**Result:** 37 files frontmattered.

## Step 2: Read Orientation Files

```bash
read_file "$WIKI/SCHEMA.md"
read_file "$WIKI/index.md"
read_file "$WIKI/log.md" offset=<last 30>
```

Existing wiki: 390 pages. Already had http, dns, tls-ssl, security, react pages.

## Step 3: Divide Into Logical Sections

The export naturally splits into 4 sections:

| Section | Raw Directories | Est. Pages |
|---------|----------------|------------|
| Web Security | 安全/ (HTTPS, Let's Encrypt, CORS, CSP, HSTS, CSRF, etc.) | 15 |
| Network Protocols | CDN, SSE, WebSocket, XHR, MIME, Webhook, Cookie, DNS | 8 |
| Frontend Development | 前端开发/ (Vue, Nuxt, React, Next.js, Vite, Webpack, etc.) | 25 |
| WebAssembly | WebAssembly/ (WasmEdge, WebContainer, Emscripten, Deno) | 7 |

## Step 4: Delegate in Batches (max 3 concurrent)

```python
# First batch: 3 agents
delegate_task(tasks=[
    {"context": "...security section...", "goal": "Ingest 安全/ files"},
    {"context": "...network section...", "goal": "Ingest CDN, SSE, WebSocket, ..."},
    {"context": "...frontend section...", "goal": "Ingest 前端开发/ files"},
])

# Each agent's context MUST include:
# - WIKI path
# - Raw source paths for its section
# - SCHEMA conventions (frontmatter, wikilinks, tags, sources)
# - EXplicit instruction: "Do NOT modify index.md or log.md"
```

## Step 5: Second Batch for Remaining Sections

```python
# Fourth section after first 3 finish
delegate_task(tasks=[
    {"context": "...wasm section...", "goal": "Ingest WebAssembly/ files"},
])
```

## Step 6: Parent Reconcilies Index + Log

After all subagents complete:

```bash
# Count new pages
count=$(find $WIKI/concepts $WIKI/entities -name "*.md" -newer $WIKI/raw/web-export/Web.md | wc -l)
# Update index.md total
patch "Total pages: $OLD" → "Total pages: $(($OLD + $count))" in index.md
# Append consolidated log entry
```

## Results

- **37 raw files → 65 wiki pages** (22 concepts + 27 entities + 12 updates + 4 subagent patch remnants)
- **Wiki grew from 390 → 445 pages**
- **No duplicates or broken wikilinks**
- **Log entry:** one consolidated line, not 4 scattered entries

## Pitfalls Encountered

1. **Subagents patched index.md independently despite instructions.** This caused "Total pages" and sections to increment 3 different ways. Fix: the parent's final patch corrected the total, but the section entries from subagents 2+3 were missing. The parent had to re-read the full index and re-add them.
2. **delegate_task default max_concurrent_children=3.** Had to split into 3+1 instead of 4 at once. The error message tells you this — read it and adjust.
3. **Frontmatter was added AFTER assessment** — should be first thing. The `sha256` hash used for drift detection only makes sense if it's set before any other modification.
4. **subagent file modifications trigger "sibling modified" warnings** when the parent later reads those files. These warnings are harmless if the parent plans to re-read and correct — but if the parent assumes its own earlier read is still current, it will silently overwrite changes. Always re-read after subagents finish.
