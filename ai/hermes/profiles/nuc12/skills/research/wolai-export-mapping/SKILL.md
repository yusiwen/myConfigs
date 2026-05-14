---
name: wolai-export-mapping
description: Cross-reference local Wolai markdown exports with cloud page IDs using MCP. Maps export directories to their remote tree, finds drifts, and saves structured mapping files. For ongoing change-detection and sync, see wiki-sync-pipeline.
trigger: User asks to map, audit, cross-reference, verify, or survey a Wolai export directory against the cloud. User asks to find page IDs for local export files, or inspect deviations between Wolai and local.
---

# Wolai Export Mapping

> **Related skills:**
> - `wiki-sync-pipeline` — Ongoing change detection and sync (use this for periodic Wolai→wiki sync)
> - `wiki-content-audit` — Auditing raw export directories before mapping (surveying, multi-pass content search, inventory)
> - `wolai-export-schema` — Reverse-engineered Wolai markdown export format

Map a local Wolai markdown export directory to its remote cloud pages using the MCP `get_page_blocks` tool. Produces a human-readable mapping file.

## Prerequisites

- MCP server configured with Wolai connection (tool: `mcp_wolai_get_page_blocks`)
- Export directory under `raw/<export-name>/` with a root `.md` file
- Existing L1-L2 mapping (often in `raw/tasks/mapping/<export>.md`)

## Workflow (BFS, 2 calls per turn)

### 1. Assess Local Files

```shell
cd raw/<export-name>
# Count files per L1 subdirectory
find . -name '*.md' -not -path '*/image/*' -not -path '*/file/*' | cut -d/ -f2 | sort | uniq -c | sort -rn
# Check max depth
find . -name '*.md' -not -path '*/image/*' -not -path '*/file/*' | awk -F/ 'max < NF {max = NF} END {print max-1}'
```

### 2. Verify L1 Page IDs

Call `mcp_wolai_get_page_blocks(page_id)` on the root page to get all direct children. Note: not all children are subpages — filter for `type === "page"`.

### 3. Crawl Largest Subtrees First

Always prioritize:
- The largest local subdirectory (most files)
- Any page previously marked "NOT FOUND"
- Pages with heading containers that might hold subpages

**Pattern — 2 parallel calls per turn:**
```
mcp_wolai_get_page_blocks(page_id="<large-subtree>")
mcp_wolai_get_page_blocks(page_id="<potential-fix>")
```

### 4. Handle Large MCP Responses

When MCP returns >50KB (saved to `/tmp/hermes-results/...`):
```python
python3 -c "
import json
data = json.loads(open('/tmp/hermes-results/call_XXX.txt').read())
result = json.loads(data['result'])
blocks = result['data']['data']
pages = [b for b in blocks if b['type'] == 'page' and b['id'] != '<parent-id>']
for p in pages:
    title = p['content'][0]['title'] if p['content'] else '?'
    c = len(p.get('children', {}).get('ids', []))
    print(f'{p[\"id\"]} | {title} | children: {c}')
"
```

### 5. Detect and Fix NOT FOUND Entries

When a previous mapping has `NOT FOUND`:
- Try the page_id directly with `mcp_wolai_get_page_blocks` — it may exist but was queried wrong before.
- Check the local directory name for clues (e.g. `系统用户界面---编程界面` -> title is `系统用户界面 / 编程界面`).
- Some pages live under heading containers on the root, not as direct subpages.

### 6. Write Mapping File

Save to `raw/tasks/mapping/<export>.md` with structure:
- **Header**: root Wolai URL, export dir, total files, MCP calls
- **Full Page Tree**: indented with page IDs, depth indicators
- **Local File Distribution**: table of subdir -> file counts
- **Namespace Fixes**: any corrected NOT FOUND entries
- **Notable Observations**: largest subtrees, structural quirks, drift data
- **Stats**: L1 pages, subpages, max depth, MCP calls

## Efficient L1 Discovery (Root-Page Scan)

**Problem:** The old approach crawled each L1 page individually, costing 10-30+ MCP calls to confirm all L1 page IDs in an export.

**Fix:** A single `mcp_wolai_get_page_blocks(root_page_id)` call on the root page returns ALL direct children with their page IDs, titles, and types. This discovers every L1 page in one shot.

**Procedure:**
1. Call `mcp_wolai_get_page_blocks(root_id)` — 1 call
2. Extract all children where `type === "page"` — these are the L1 subpages
3. Record their `id` -> `title` mapping immediately
4. For each L1, check `children.ids` array length to decide if leaf or has subpages
5. Fill previously-missing L1 IDs instantly

## Resolving Need-Block-ID Entries

When a mapping file has entries marked `need block ID`, this is a targeted gap-fill:

### Step 0: Identify Missing Entries

Read the mapping file. Collect the row number, title, parent page ID, and local path of each missing entry.

### Step 1: Crawl Each Parent Page (2 parallel calls per turn)

For each unique parent page ID, call `mcp_wolai_get_page_blocks(parent_id)`.

**Fallback when `get_page_blocks` fails:** If `mcp_wolai_get_page_blocks(page_id)` returns "page not found" for a known-valid page ID, try `mcp_wolai_get_page(page_id, include_blocks=true)`.

### Step 2: Extract Page Blocks

Filter for `type === "page"`:

```python
import json
data = json.loads(open(path).read())
result = json.loads(data['result'])
blocks = result['data']['data']
for b in blocks:
    if b.get('type') == 'page' and b['id'] != parent_id:
        title = b['content'][0]['title'] if b.get('content') else '?'
        print(f"{b['id']} | {title}")
```

**Double-nested JSON:** When responses >50KB, the outer JSON has `{"result": "<escaped-string>"}`. Parse as:
```python
outer = json.loads(open(path).read())
inner = json.loads(outer['result'])
blocks = inner['data']['data']
```

### Step 3: Match Titles to Local Paths

Match MCP page titles to missing entries. Use fuzzy matching — the local path is the ground truth.

### Step 4: Patch the Mapping File

Use `patch()` to:
1. Update tree section: replace `(need block ID)` with `(actual_page_id)`
2. Update mapping table: replace `---` and `need block ID` with actual ID and status
3. Update stats: decrement the missing block IDs count

## Page ID Typos in Mapping Files

**Problem:** An existing mapping may contain a page ID with a typo (character substitution: `1` -> `T`, `0` -> `O`, `l` -> `1`). Calling `get_page_blocks` on a typo'd ID returns "page not found".

**Fix:** When you get "page not found", search by title:
1. Call `mcp_wolai_search_pages(query=<title>)`
2. Pick the closest match
3. Verify the correct ID with `get_page_blocks`
4. Update the mapping

## Filling Gaps in Incomplete Mappings

### Step 1: Root-Page Scan
One call to discover all L1 page IDs.

### Step 2: Compare Against `list_pages`
Run `mcp_wolai_list_pages()` to find completely unmapped root pages.

### Step 3-4: Deep-Crawl Subpages
Call `get_page_blocks` on each L1, extract child pages, build structured ID tables.

### Step 5: Convert Prose to Tables
Replace prose descriptions of subpages with structured tables.

## Complete Workspace Inventory

The full wolai workspace has **18 top-level pages**:

| # | ID | Title | Has Export? |
|---|-----|-------|-------------|
| 1 | `t3cQz3B65ykiRioor4D3zd` | Code Snippets | utility page |
| 2 | `ii547eNBoaFppfCjpq6hnd` | Transfer between devices | utility page |
| 3 | `hYfSappafo6pGXdRsVrEZu` | Quick Notes | scratch notes |
| 4 | `eRABbBQazaAMvuTHiaQoty` | My Workbench | personal dashboard |
| 5 | `mq6paqnZCpaEjUe8FSbFjR` | Cloud Computing | yes |
| 6 | `d8LAJCgYXe7SMLAoF6dXjo` | Network | yes |
| 7 | `iEW5q6vke2uSz7t6Pw2y5y` | Web | yes |
| 8 | `qtGYp9QJiTDqEDH3kFDGWv` | Programming Languages | yes |
| 9 | `5fLMsZjdDeaJKPZTfFMLAb` | Compilers & Linkers | yes |
| 10 | `caMj2NtdxSegXqQrmrAYQD` | Algorithms & Data Structures | yes |
| 11 | `fpC8RMw4emb3cnGMuXPCjv` | Artificial Intelligence | yes |
| 12 | `4ZH53VJxcG9o8NQaTLvLuE` | Operating System | yes |
| 13 | `fsj4h8Cjq94JYpNwxsHZKa` | Database | yes |
| 14 | `7aMnz4uD7h3Gj9X131P4VZ` | Big Data & Data Science | yes |
| 15 | `u6PrE5mJpn53D5WjD3U2Rw` | Distributed Systems | yes |
| 16 | `t8k5aogy1cd8DQLHNR7tuq` | Tools | yes |
| 17 | `kT2KBvhdjMzZfkEujmuRC2` | Thoughts | yes |
| 18 | `e8YH8H9vJ46rCDvReah9hX` | Miscellaneous | yes |

## Pitfalls

- **NOT FOUND is often wrong.** Always verify the ID directly. Some pages live inside heading blocks, not as direct subpages.
- **Not all children are pages.** Filter by `type === "page"` to find actual subpages.
- **Export directory name encoding.** The export tool replaces ` / ` with `---` in directory names.
- **Nested duplicates.** Subpages may appear as `a-aaaa/a-aaaa/a-aaaa.md` — export artifacts, not separate pages.
- **Large exports take multiple sessions.** Save cache JSON for resume support.
- **Mapping files with 0-5 MCP calls are likely incomplete.** Run the root-page scan (1 call) to bulk-fill L1 IDs.
- **Leading pipe in patch old_string.** When patching Markdown table rows, the old_string MUST include the leading `|` pipe character.
- **Prose descriptions are not structured data.** Replace with structured tables using `get_page_blocks` data.
- **Local path construction follows export tool conventions.** ASCII spaces -> hyphens, Chinese kept, `/` in title -> `---`, `&` -> `-&-`, parentheses kept.
- **Crawl only until every local file has a page ID at the directory level.** You don't need every leaf block ID.

## References

- `wolai-export-schema` — Export format details (how Wolai transforms pages to markdown)
- `references/workspace-inventory.md` — Full workspace page inventory with subpage counts
- `references/thoughts-export-crawl.md` — Deep-crawl results of the Thoughts export
- `wiki-sync-pipeline` — Ongoing change detection and sync (for periodic use after baseline is complete)
