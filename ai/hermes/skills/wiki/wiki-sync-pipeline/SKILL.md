---
name: wiki-sync-pipeline
description: "Ongoing Wolai to Wiki sync cycle: detect changes, sync export files, and re-ingest derived wiki pages. Use instead of wolai-export-mapping when user asks to check for changes, sync, refresh, or run change detection."
trigger: "User asks to check for drift or changes between Wolai and local exports, sync/update/refresh the wiki, run detect-changes.py, or asks about the wiki sync pipeline."
---

# Wiki Sync Pipeline

Use for the ongoing Wolai-to-Wiki sync cycle. If baseline mapping is incomplete, run `wolai-export-mapping` first.

## Architecture

```
Wolai.app         detect-changes.py + agent        Local disk
  |                      |                            |
  +- Phase 1: ----------> build snapshot <----------- mapping files
  |                       (zero MCP calls)             (14 export .md)
  |
  +- Phase 2: ----------> scan MCP edited_at <------- snapshot
  |   (agent batches of 4 per turn)
  |
  +- Phase 3: ----------> detect changes -> preview    (human review)
  |
  +- Phase 4: ----------> sync_export.py ----------> update .md files
  |   (agent batches of 2 per turn)
  |
  +- Phase 5: ----------> check derived pages ------> patch wiki pages
  |                                                (comparisons/concepts)
  |
  +- Phase 6: ----------> git commit + push --------> update snapshot
```

## Phase 1: Build Snapshot

```bash
cd ~/git/mine/wiki
python3 raw/tasks/mapping/detect-changes.py --build-snapshot
```

Extracts page IDs from 14 mapping files (zero MCP calls). Creates `_snapshot.json` with `{page_id: {title, local_path, export, edited_at}}`. First build: all `edited_at` null.

4 parsers: table format, DS-style (with subpage column), bracket tree, catch-all.

## Phase 2: Scan MCP (Agent Loop)

Two modes:

| Mode | Pages scanned | Use case |
|------|---------------|----------|
| `--quick` | ~200 L1 pages | Weekly check |
| `--full` | ~683 all pages | First run, post-major-edit |

Prepare plan:
```bash
python3 detect-changes.py --dry-run        # plain text
python3 detect-changes.py --scan-list      # JSON
```

Iterate in parallel batches of 4:

```python
for batch in chunks(scan_ids, 4):
    results = [
        mcp_wolai_get_page_blocks(batch[0]),
        mcp_wolai_get_page_blocks(batch[1]),
        mcp_wolai_get_page_blocks(batch[2]),
        mcp_wolai_get_page_blocks(batch[3]),
    ]
    for page_id, result in zip(batch, results):
        if "not exist" in str(result) or result.get("error"):
            snap["pages"][page_id]["edited_at"] = "NOT_FOUND"; continue
        import json
        outer = json.loads(result["result"]) if isinstance(result, dict) else json.loads(json.loads(result)["result"])
        root = next(b for b in outer["data"]["data"] if b.get("type") == "page")
        ts = root.get("edited_at")
        if ts != snap["pages"][page_id].get("edited_at"):
            changed.append((page_id, snap["pages"][page_id], ts))
        snap["pages"][page_id]["edited_at"] = ts
```

For large responses (>50KB, saved to `/tmp/hermes-results/`):
```python
outer = json.loads(open(path).read())
inner = json.loads(outer["result"])
blocks = inner["data"]["data"]
```

Save progress after each batch:
```python
Path("raw/tasks/mapping/_snapshot.json").write_text(json.dumps(snap))
```

## Phase 3: Report + Confirm

Types: EDITED (timestamp changed), NEW (in Wolai, not in snapshot), DELETED (404 from MCP).

Present per-export table, then ask user: "Apply these changes?"

## Phase 4: Sync

On confirm, iterate changed pages in batches of 2:

```python
from pathlib import Path
sys.path.insert(0, str(Path("~/git/mine/wiki/raw/tasks/mapping").expanduser()))
from sync_export import extract_blocks_from_mcp_response, write_export_file

for batch in chunks(changed_ids, 2):
    r1 = mcp_wolai_get_page_blocks(batch[0])
    r2 = mcp_wolai_get_page_blocks(batch[1])
    for pid, r in zip(batch, [r1, r2]):
        info = snap["pages"][pid]
        local = Path.home() / "git/mine/wiki" / info["local_path"]
        title, _, blocks = extract_blocks_from_mcp_response(r)
        write_export_file(str(local), title, blocks)
        info["edited_at"] = new_ts
```

Block conversion (via `sync_export.py`):
| Wolai Block | Markdown |
|---|---|
| `text` | Paragraph |
| `heading` | `#`/`##`/`###` |
| `code` | ``` fence + language |
| `bull_list`/`enum_list` | `-` / `1.` list |
| `todo_list` | `- [ ]` / `- [x]` |
| `block_equation` | `$$` LaTeX |
| `image`/`video` | `![caption](url)` |
| `bookmark` | `[title](url)` |
| `simple_table` | Markdown table |
| `divider` | `---` |
| `quote`/`callout` | `>` blockquote |
| `page` | `[[wikilink]]` |

Plus inline formatting (bold, italic, code, links, equations), `ingested` date + `sha256` frontmatter.

## Phase 5: Re-ingest

After sync:
1. Find derived wiki pages: `grep -rl "raw/<export>" comparisons/ concepts/ entities/`
2. Agent reviews. Significant content changes -> update pages. Minor edits -> skip.

## Phase 6: Git Commit

```bash
cd ~/git/mine/wiki
git pull --rebase origin master
git add -A && git commit -m "sync: updated N pages from Wolai" && git push origin master
```

## Phase 7: Reverse Sync (Wiki → Raw Export → Wolai)

The sync pipeline normally flows **Wolai → raw export → wiki pages** (downstream). Sometimes, however, you create or enhance a wiki concept page with fresh research (architecture, evidence, analysis) that wasn't in the original Wolai source. In that case, **push the improvement back upstream**:

```
wiki concept page (new/enhanced) → raw export update → Wolai MCP update
```

### When to do this

- You created a new wiki concept page from raw export content + supplemental research
- You discovered architectural relationships or evidence not captured in the original Wolai note
- You added structured content (comparison tables, architecture diagrams, evidence citations) that would be useful in the original source

### Workflow

#### ① Update the raw export file

The raw export is the local mirror of the Wolai page. Insert your new content at the appropriate location within the existing section — preserving all original content and just adding the missing context.

Key rules:
- **Don't replace or remove** original content — the raw export is a mirror, not a rewrite
- Use a **blockquote or callout** to highlight the new insight (e.g., `> **Note about X:** ...`)
- Add explicit **evidence citations** with links when possible

#### ② Find the Wolai page ID

Use the mapping files under `raw/tasks/mapping/`:

```bash
grep "工具" raw/tasks/mapping/cloud-computing-export.md
```

The mapping tree format is:
```
├── Parent [page_id] ★ (N subpages)
```

For deeply nested pages, search by title with MCP then verify `parent_id`:

```python
mcp_wolai_search_pages("page title")
mcp_wolai_get_page(page_id)  # check parent_id matches expected
```

#### ③ Inspect the Wolai page structure

```python
mcp_wolai_get_page_blocks(page_id)
```

Identify the anchor block (e.g., last text block before bookmark links at the bottom). Note each block's `id`, `type`, `parent_id`, and `children`.

#### ④ Insert new blocks via MCP

```python
mcp_wolai_insert_blocks_relative(
    anchor_block_id="<last text block id>",
    placement="after",
    blocks=[
        {"type": "callout", "content": [...]},
        {"type": "text", "content": [...]},
        {"type": "bull_list", "content": [...]},
        {"type": "enum_list", "content": [...]},
    ]
)
```

**Rich text format (each inline element is an object):**
```python
{"title": "bold text", "type": "text", "bold": True}
{"title": "code snippet", "type": "text", "inline_code": True}
{"title": "link text", "type": "text", "link": "https://..."}
```

#### ⑤ Verify

```python
mcp_wolai_get_page_outline(page_id)  # confirm insertion
```

#### ⑥ Git commit the raw export update

```bash
cd ~/git/mine/wiki
git add -A && git commit -m "docs: update raw export with ..." && git push
```

### Example — gVisor/netstack

After creating `concepts/container/gvisor.md` with netstack's standalone usage:
1. **Raw export**: Inserted a note block, architecture description, and 3-source evidence list after the original warning paragraph (before bookmark links)
2. **Wolai page**: Added 10 blocks (callout + architecture + bullet list + evidence enumeration) after the last text block in the gVisor section
3. **Evidence**: Official gVisor docs quote, `google/netstack` repo, Cloudflare `slirpnetstack`

### Pitfalls

- **Wolai block IDs are opaque** — use `get_page_blocks` to find the anchor; never guess
- **Don't touch original blocks** — insert new ones; editing existing blocks breaks local-remote correspondence
- **Rich text is verbose** — each inline style is a separate object; plan carefully
- **Search title with exact spacing** — Wolai titles may have leading/trailing spaces

## Pitfalls

1. **Large MCP responses** (>50KB) double-nested JSON, parse via `json.loads(outer["result"])`.
2. **First run costly**: 683 pages. Subsequent `--quick`: ~200 pages, ~3 min.
3. **edited_at granularity**: 1-char edit or full rewrite both change the timestamp. Review before re-ingesting.
4. **No content diff**: agent compares old vs new manually.
5. **Catch-all false positives**: non-page IDs fail MCP lookup harmlessly.
6. **Empty text blocks**: auto-skipped by `sync_export.py`.
7. **Page ID typos**: MCP returns 404 -> try `mcp_wolai_search_pages(title)`.
8. **Git pull before write**: always `git pull --rebase` first.
9. **Sync != original export**: equivalent content, not byte-identical (TOC/spacing differ).

## Related Skills

- `wolai-export-mapping` -- Baseline establishment (mapping export dirs to page IDs)
- `wolai-export-schema` -- Wolai export format details
- `wiki-git-pull-push` -- Git workflow for multi-machine sync
