# Change Detection: Wolai → Local Sync Pipeline

## Overview

After the baseline MCP↔local mapping is established, this pipeline detects edits on Wolai, syncs them to local snapshots, and re-ingests into the wiki.

## Architecture

```
                       ┌─────────────────────┐
                       │   _snapshot.json     │
                       │  683 pages (all 14   │
                       │  exports)            │
                       └──────────┬──────────┘
                                  │
     ┌────────────────────────────┼────────────────────────────┐
     │                            │                            │
     ▼                            ▼                            ▼
┌──────────────┐     ┌──────────────────────┐     ┌───────────────────┐
│  detect-     │     │  Agent: iterate      │     │  Preview + Sync   │
│  changes.py  │     │  pages, call MCP,    │     │  (on confirm)     │
│  (scan plan) │     │  compare edited_at   │     │                   │
└──────────────┘     └──────────────────────┘     └───────────────────┘
```

## Data Flow

1. **Build snapshot** from mapping files (zero MCP calls) — extract all page IDs
2. **Scan** — call `mcp_wolai_get_page_blocks` for each page, extract `edited_at` from root block
3. **Detect** — compare `edited_at` against snapshot: EDITED, NEW, or DELETED
4. **Preview** — formatted table grouped by export
5. **Execute** — on confirm: sync `.md` content, re-ingest into wiki pages
6. **Save** — update snapshot with new `edited_at` values

## Script: `detect-changes.py`

**Location:** `raw/tasks/mapping/detect-changes.py`

### Modes

| Flag | Behavior | MCP Calls |
|------|----------|-----------|
| `--build-snapshot` | Extract page IDs from mapping files | 0 |
| `--dry-run` | Show scan plan without executing | 0 |
| `--quick` (default) | L1s + unknown pages only | ~200 |
| `--full` | All 683 pages | ~683 |
| `--preview-only` | Detect + show report, no sync | N |
| `--scan-list` | Output page IDs as JSON for piping | 0 |

### Workflow Commands

```bash
# Initial build (first run)
python3 detect-changes.py --build-snapshot

# See what would be scanned
python3 detect-changes.py --dry-run

# Preview scan plan by export
python3 detect-changes.py --full --dry-run

# Run detection (agent executes MCP loop)
# Agent iterates page IDs, calls mcp_wolai_get_page_blocks,
# extracts edited_at from first (root) block,
# compares against snapshot
```

## Scan Strategies

### Quick Mode (default)
- Scans only L1 pages + pages with null `edited_at`
- After baseline established: ~200 pages per run
- Detects structural changes (children changed → L1 timestamp changes)

### Full Mode
- Scans every page regardless
- ~683 pages, ~170 batches of 4
- Thorough but expensive

## Mapping File Format Parsing

The script must handle 4 distinct mapping file formats under `raw/tasks/mapping/*.md`:

| Format | Pattern | Examples |
|--------|---------|----------|
| Standard table | `\| N \| \`id\` \| Title \| \`path\` \| depth \| status \|` | database, AI, big-data, web, misc, algorithms |
| Extended table (7 col) | Same + subpage IDs in column 7 | distributed-systems |
| Bracket tree | `Title [id] ★ (N children)` | cloud-computing, network, OS, programming-languages |
| Parenthetical tree | `Title (id) ← path.md [leaf]` | compilers-linkers, web-export |
| Mini-tables | `\| Block ID \| Title \| Local Path \|` | thoughts-export (per-heading) |

**Order of attempts:** Standard → Extended → Bracket → Paren → Catch-all

The catch-all extracts any `\`id\`` or `(id)` or `[id]` pattern — ensures no page is missed even in unusual formatting.

## Snapshot Format

```json
{
  "version": 1,
  "created_at": "ISO timestamp",
  "updated_at": "ISO timestamp",
  "pages": {
    "PAGE_ID": {
      "title": "Page Title",
      "local_path": "raw/export-name/path/file.md",
      "export": "export-name",
      "edited_at": 1700000000000
    }
  }
}
```

## Batch Size

Tested with batch size 4 — all parallel MCP calls succeed without rate limiting. No errors observed across 30+ calls. Conservative default is 2, but 4 is safe for this Wolai MCP API.

## First Run vs. Subsequent Runs

| Run | What happens | Report |
|-----|-------------|--------|
| **First** (all null) | Every page shows as NEW/CHANGED | 683 changed — expected, establishes baseline |
| **Second** (quick) | Only L1s checked | ~0 changed unless Wolai was edited |
| **Second** (full) | All pages checked | ~0 changed unless Wolai was edited |
| **After Wolai edit** | Changed pages detected | N changed pages, specific per-export breakdown |

## Architecture Notes

- The script is a **plan generator** — it outputs scan lists but does NOT call MCP directly. MCP calls are executed by the agent in the conversation loop.
- `execute_code` blocks process the results and update the snapshot between agent turns.
- The snapshot is committed to git alongside the mapping files.
