---
name: sync-export-to-wolai
description: "Update a raw export markdown file AND its corresponding Wolai page simultaneously, keeping both in sync. Covers: locating the Wolai page ID via mapping files, editing both sides, and git commit/push."
version: 1.2.0
author: Hermes Agent
---

# Sync Raw Export ↔ Wolai Page

## When This Skill Activates

This skill activates when you need to keep wiki content in sync between its three layers — **concept/entity pages**, **raw export files**, and **Wolai pages**. This happens when:

- The user discovers missing context in a raw export and wants it fixed in both places
- A wiki concept page was improved and the raw source should reflect the changes
- A raw article (`raw/articles/`) was ingested into a concept/entity page and the result should be synced back to the appropriate raw export and Wolai page
- The user explicitly asks to "update the export page and the corresponding Wolai note"

**Two workflow directions:**

| Direction | Trigger | Flow |
|-----------|---------|------|
| **A — Export→Wolai** | Raw export content changed | `raw/<export>/...` → Wolai page (standard sync) |
| **B — Concept→Export→Wolai** | Concept/entity page improved; no raw export changed yet | `concepts/...` or `entities/...` → `raw/<export>/...` → Wolai page |

## Workflow

### Step 1: Determine the Raw Export Path

The raw export is always under `$WIKI/raw/<export-name>/`. For example:

- `raw/cloud-computing-export/容器/工具/开发/开发.md`
- `raw/network-export/...`
- `raw/database-export/...`

### Step 2: Find the Wolai Page ID

There are two complementary approaches. Try both in parallel:

**Approach A — Mapping files (faster, prefer this):**

Look in `raw/tasks/mapping/` for the mapping file matching the export name (e.g., `cloud-computing-export.md`). Parse the tree structure to find the page ID. The mapping uses `[page_id]` brackets:

```
├── 容器 [qHTqkY7TZxaZ7wEDyCKM4X] ★
│   └── 工具 [da1HJJCHb79SwumtaTvihp] (15 children)
```

If the mapping only says "(N children)" without listing individual subpages, use Approach B.

**Approach B — Wolai search (fallback):**

Use `mcp_wolai_search_pages(query=<title>)` to find the page. The title may include a leading space (e.g., `" 开发"`). Search may return multiple results with similar names (e.g., "authelia" and "Authelia") — you'll need to verify each.

After finding a candidate, verify its parent chain:

```python
page = mcp_wolai_get_page(page_id="<candidate_id>")
# The response has these relevant fields:
#   id:         the page's own ID (matches what you queried)
#   parent_id:  the immediate parent block/page ID
#   page_id:    the TOP-LEVEL L1 ancestor page ID (*not* the page's own ID)
#   parent_type: "page" or "header"

# Case 1 — Direct child of a page (parent_type="page"):
#   page.parent_id should == expected_parent_id from mapping

# Case 2 — Nested under a heading block (parent_type="header"):
#   page.parent_id will be a heading block's ID, NOT the mapping page.
#   In this case, query the heading block to find the real parent:
heading = mcp_wolai_get_block(page.parent_id)
# heading.parent_id should == expected_parent_id from mapping
```

**Case 2** is common when many subpages exist under one section — Wolai organizes them under headings rather than direct page children. The `page_id` field in the response is always the **top-level L1 ancestor**, not the immediate parent — do not use it for parent verification.

### Step 3.5 — Direction B: Concept/Entity → Raw Export

If the sync originated from a **concept or entity page** improvement (not a raw export change), you need to first create or update the raw export file before syncing to Wolai. Two sub-scenarios: the concept page may be **export-derived** (has `sources:`) or **wiki-native** (no `sources:`).

#### Sub-scenario B1: Concept is Export-Derived (has `sources:`)

1. **Find the raw export path** — using the `sources:` field in the concept page's frontmatter. Look for an existing raw export at `raw/<export-name>/...`.

2. **Read the raw export file** and the Wolai page blocks. Identify where existing content ends.

3. **Create or update the raw export** — if it exists, patch it; if it doesn't, create it with the correct path matching the Wolai page's location in the export tree.

4. **Update the concept/entity page frontmatter** — ensure the `sources:` field already covers the raw export path.

5. **Ensure provenance markers are added** — see SCHEMA.md for the `^[raw/<path>.md]` format.

**Read the raw export file:**
```
read_file(path="raw/<export>/.../<file>.md")
```

**Get the Wolai page structure:**
```
mcp_wolai_get_page_blocks(page_id="<found_id>")
```
This returns the full block tree. Identify where existing content ends and where to insert new blocks (the anchor block).

#### Sub-scenario B2: Concept is Wiki-Native (no `sources:`) → Create New Wolai Page

**⚠️ Hybrid edge case:** The concept page may have `sources:` pointing to *related* existing exports (e.g., reference material in other pages that mention the concept), but still need a *new* raw export created for itself. The key test: does the `sources:` path point to an existing file that IS the concept's own content, or to different pages that merely reference it? If no existing raw export IS the concept itself, you're in B2 — proceed as if no `sources:` exist for the new page, then add the new raw export path to `sources:` at step 5.

When the user explicitly asks to push a wiki-native concept to Wolai (e.g., "add a new page about X" or "sync this back to Wolai"), follow this order:

**1. Choose a Wolai parent page** — examine the concept page's content for domain clues:
   - Tags in the frontmatter (e.g., `tags: [model, architecture, inference]` → likely NLP → Transformer in AI export)
   - Section headings and cross-references (e.g., mentions RAG, recommender systems)
   - Compare against existing Wolai page trees in mapping files at `raw/tasks/mapping/`
   - When multiple fits exist, prefer the parent where the content is most actionable (e.g., recommender system ranking tools over general AI theory)

**2. Create the Wolai page first** — use `mcp_wolai_create_page(parent_id=<parent_page_id>, title="<title>")`. This gives you the new page ID (e.g., `kac25tvUDHoENTG5NB3DNK`).

**3. Create the raw export file** at matching path:
   ```
   raw/<export-name>/<parent-1>/.../<page-title>/<page-title>.md
   ```
   Use lowercase with hyphens for English titles. Create the directory first with `mkdir -p`.

**4. Populate both sides:**
   - Write raw export content using `write_file()` (see Step 4 for markdown format)
   - Populate Wolai page blocks via `mcp_wolai_create_block(parent_id=<new_page_id>, blocks=[...])` — max 20 blocks per call
   - Empty code blocks need separate `mcp_wolai_update_block()` calls to fill with code content

**5. Update the concept page's frontmatter** — add `sources:` pointing to the new raw export:
   ```yaml
   sources:
     - raw/<export-name>/<parent-chain>/<page-title>/<page-title>.md
   ```

**6. Update the mapping file** — add a new row AND update the tree structure:
   - Add mapping row: `| N | <page_id> | <title> | <local_path> | <depth> | ✅ leaf |`
   - Bump the "Total" count in Stats section
   - Add the page to the Full Page Tree section under its parent using `└──` or `├──` tree-prefix convention
   - Bump the "Last updated" date in the mapping file's header

### Step 4: Update the Raw Export File

Edit the markdown file using `patch()`. The raw export format uses Wolai's markdown conventions:

- Bookmark links: `[ description link_text ](url "description link_text")`
- Bold: `**text**`
- Inline code: `` `text` ``
- Images are inline links
- Headings are `#` prefixed

**Always follow the wiki git workflow:** pull before edit, commit + push after.

### Step 5: Update the Wolai Page via MCP

Choose the right insertion strategy:

| Situation | Tool | Notes |
|-----------|------|-------|
| Insert blocks after a specific block | `mcp_wolai_insert_blocks_relative(anchor_block_id, placement="after", blocks=...)` | Best for appending between existing text and bookmark links. **Max 20 blocks per call** — split into multiple calls if needed. |
| Insert blocks BEFORE a specific block | `mcp_wolai_insert_blocks_relative(anchor_block_id, placement="before", blocks=...)` | Use for prepending content at the top of a page — pass the first content block's ID as `anchor_block_id` with `placement="before"`. Also useful for inserting content between specific blocks (e.g., before a bookmark). |
| Insert under a heading | `mcp_wolai_insert_under_heading(page_id, target_section_id, placement="append_inside", blocks=...)` | Good if you want new content at top or bottom of a section |
| Replace a section entirely | `mcp_wolai_rewrite_section(page_id, section_id, heading=..., blocks=...)` | **Pitfall:** the heading updates reliably, but body blocks may silently fail to persist even when the response reports `inserted_root_block_count: N`. Always verify with `mcp_wolai_get_page_outline()` or `mcp_wolai_get_page_blocks()` after rewriting. If no blocks appear under the heading, use `mcp_wolai_create_block(parent_id=<heading_block_id>, blocks=...)` to add them. |
| Replace one block with new blocks | `mcp_wolai_replace_block(block_id, replacement_blocks=[...])` | Best for swapping out a single block in-place (e.g., updating a comparison table by adding a new row, or replacing a text block with a callout). The new blocks take the original block's position. Use `preserve_children=true` if the old block has children you want to keep under the replacement. |
| Add blocks to a heading's children | `mcp_wolai_create_block(parent_id=<heading_block_id>, blocks=...)` | Workaround when `rewrite_section` didn't persist body blocks. Pass the heading block's ID as `parent_id`. Max 20 blocks per call. |

**For rich text content**, use the inline styling format:

```json
{"title": "normal text", "type": "text"},
{"title": "bold text", "bold": true, "type": "text"},
{"title": "inline code", "inline_code": true, "type": "text"},
{"title": "linked text", "link": "https://...", "type": "text"}
```

**Available block types for insertion:**
- `text` — plain paragraph
- `callout` — callout/quote box (with optional `icon`)
- `bull_list` — bullet list item
- `enum_list` — numbered list item
- `heading` — heading (with `level: 1|2|3`)
- `quote` — blockquote
- `bookmark` — link bookmark (use `link` field)

**After insertion, verify the block count increased:**
```
mcp_wolai_get_page_outline(page_id)  # check content_block_count
```

### Step 6: Check if Mapping File Needs Updating

After syncing content, verify whether the **mapping file** (`raw/tasks/mapping/<export-name>.md`) needs updating.

**Conditions that require a mapping update:**

| Condition | What to do | Example |
|-----------|-----------|---------|
| **New page created on Wolai** (e.g., you added a new section as a standalone subpage via MCP) | Add a new row to the mapping table with `page_id`, `title`, `local_path`, `depth`, and `status: ✅ confirmed` | Creating a new child page under 分布式数据库 |
| **Page deleted** from Wolai and the raw export is removed | Mark as removed or delete the mapping row | Deprecated page no longer exported |
| **Page path changed** (raw export file renamed/moved) | Update the `local_path` column | `foo.md` → `bar/foo.md` |
| **A ⚠️ heading-only entry now confirmed** (you verified it IS a real Wolai subpage) | Change status from `⚠️ heading only` to `✅ confirmed` | The sync proves the page exists |
| **A previously unmapped entry found** (your sync hit a mapping with only `(N children)` and you discovered a new child page) | Add the new child to the mapping table with its confirmed `page_id` | New subpage under 容器 → 工具 that wasn't in the tree |

**How to update the mapping file:**

```bash
# Read the current mapping file
# Find the relevant section in the tree structure and mapping table
# Use patch() to add/update the entry
```

The mapping table format (from `wolai-export-schema` skill):

```
| # | Page ID | Title | Local Path | Depth | Status |
|---|---------|-------|-----------|-------|--------|
| N | `<page_id>` | `<title>` | `<path>` | `<depth>` | ✅ confirmed |
```

The tree section format:

```
├── <title> [<page_id>] (N children)
│   └── <child-title> [<child-page_id>] (M children)
```

**When NOT to update mapping:**
- You only updated content (blocks/text) on an existing page — the `page_id ↔ local_path` relationship hasn't changed
- The page already has a `✅ confirmed` status and nothing structural changed
- This is the common case; most content syncs do NOT need a mapping update

**After updating mapping:**
- Bump the "Last updated" date in the mapping file's frontmatter/header
- Run `git add raw/tasks/mapping/<export-name>.md` alongside other changed files

**⚡ Also update `_snapshot.json`:**
After modifying any mapping file, regenerate `_snapshot.json` so it stays in sync with the canonical `.md` mapping files:

```bash
cd $WIKI
python3 raw/tasks/mapping/detect-changes.py --build-snapshot
```

This rebuilds `_snapshot.json` from all `.md` mapping files. The snapshot is the machine-readable cache used by `detect-changes.py` for change detection — it must reflect all page additions, deletions, and path changes.

**Why this matters:** Forgetting to regenerate `_snapshot.json` means the cache becomes stale. Future change-detection runs (`detect-changes.py` without `--build-snapshot`) will use the old cache and may miss or misreport changes for newly created pages. Regenerating after every mapping update ensures the cache always matches the canonical `.md` files.

### Step 7: Git Commit and Push

```bash
cd $WIKI
git add -A
git commit -m "docs: update <export-name> — <description of change>"
# push with 3 retries
for i in 1 2 3; do
  if git push 2>&1; then echo "PUSH SUCCEEDED"; break; fi
  sleep 2
  git pull --rebase origin master 2>&1 || break
done
```

## Pitfalls

- **Chinese directory names in raw exports** — don't guess paths. Use `search_files(target="files")` to find the file by leaf name, e.g. `search_files(path="$WIKI/raw", pattern="开发.md", target="files")`
- **Mapping may not enumerate all subpages** — the tree may say "(15 children)" without listing them. In that case, go straight to Wolai search + parent verification
- **Wolai page titles may have leading spaces** — e.g., `" 开发"` not `"开发"`. The search tool is whitespace-sensitive
- **Do NOT use `rewrite_section` when only appending** — it replaces everything under the heading. Use `insert_blocks_relative` or `insert_under_heading` to preserve existing content
- **One `insert_blocks_relative` call can add multiple blocks** — pass them all in the `blocks` array to avoid ordering issues
- **Bookmark blocks in the raw export** have a specific format: `[ description text ](url "description text")` — preserve them when editing
- **Raw export is the source of truth snapshot** — the Wolai update should mirror the raw export content, not the other way around
- **`rewrite_section` body blocks may silently fail** — even when the API returns success with `inserted_root_block_count: N`, the blocks may not actually be created on the page. Always verify the page outline afterward. If the heading has empty children, use `create_block(parent_id=<heading_block_id>, blocks=...)` as a fallback
- **`replace_block` requires the FULL replacement** — when updating a table (e.g., adding a new row to a simple_table), you must pass ALL rows in `replacement_blocks`, not just the new row. The table is replaced entirely.
- **20-block per-request limit** — `mcp_wolai_insert_blocks_relative` and `mcp_wolai_create_block` both reject requests with more than 20 blocks. Split into multiple sequential calls if your content has 21+ blocks. Ensure you use the *last* block from batch N as the `anchor_block_id` for batch N+1
- **After renaming a source file (`raw/articles/...`), update all provenance trail references** — concept pages use `^[raw/articles/<old-name>.md]` markers and frontmatter `sources:` field. Search the entire wiki for the old path after any rename: `search_files(pattern="<old-path>", path="$WIKI")`. The references are in: frontmatter sources lists, inline provenance markers, log.md history entries, and wikilinks. All must be updated in the same commit.
- **Mapping table formatting fragile with `patch()`** — the mapping file uses markdown table rows with leading `|`. When patching adjacent rows (e.g., updating the Stats section), the `patch` tool can accidentally strip the leading `|` from a row if the match boundary isnt exact. Always verify the mapping table renders correctly after patching — especially around the Stats rows (`| **Confirmed page IDs** | ... |`) and mapping table rows. Read the affected section afterward to catch dropped pipes.
- **`log.md` pipe-injection with `patch()`** — When appending entries to `log.md` using `patch()`, the tool may inject extra `|` pipe characters at the start of new lines if the surrounding context contains pipe-delimited content. After patching `log.md`, always re-read the appended section to check for spurious `|` prefixes on lines.
- **Raw articles in `raw/articles/` should be named after their content, not their original filename** — files exported from Google AI Mode use the prefix `google-ai-mode_<descriptive-name>.md` (e.g., `google-ai-mode_llm-inference-deep-dive.md`). See `references/raw-article-naming-conventions.md` for the full convention.
- **Sync verification companion workflow** — to check whether a wiki page has a Wolai counterpart and whether its content is synced, see `references/sync-verification.md`. Useful before starting a sync to assess scope: the cross-check flow (frontmatter → mapping → Wolai outline) quickly tells you if content needs syncing or if the page is wiki-native.
- **`_snapshot.json` goes stale when mapping changes** — updating the `.md` mapping file is only half the job. The `_snapshot.json` cache is NOT auto-regenerated. After any mapping update (new page, path change, deletion), run `detect-changes.py --build-snapshot` to rebuild it. Before the next `git push`, verify both files changed. This pitfall was discovered when a new bi-encoder page was added to the mapping but `_snapshot.json` wasn't regenerated — the change-detection script would have silently used the stale cache on its next run.
