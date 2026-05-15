---
name: sync-export-to-wolai
description: "Update a raw export markdown file AND its corresponding Wolai page simultaneously, keeping both in sync. Covers: locating the Wolai page ID via mapping files, editing both sides, and git commit/push."
version: 1.0.0
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

Use `mcp_wolai_search_pages(query=<title>)` to find the page. The title may include a leading space (e.g., `" 开发"`). After finding a candidate, verify it:

```python
# Check that the parent_id matches the parent in the mapping tree
mcp_wolai_get_page(page_id="<candidate_id>")
# Verify: page.parent_id == expected_parent_id from mapping
```

### Step 3.5 — Direction B: Concept/Entity → Raw Export

If the sync originated from a **concept or entity page** improvement (not a raw export change), you need to first create or update the raw export file before syncing to Wolai:

1. **Find the raw export path** — using the `sources:` field in the concept page's frontmatter. If the concept page was created from a raw article (`raw/articles/...`), look for an existing raw export at `raw/<export-name>/...` that corresponds to the same topic. If none exists, the content is wiki-native (no raw export to maintain).

2. **Determine if a raw export should exist** — check the Wolai workspace using `mcp_wolai_search_pages(query=...)` and mapping files in `raw/tasks/mapping/`. If a corresponding Wolai page exists, it should have a raw export counterpart at `raw/<export-name>/...`.

3. **Create or update the raw export** — if it exists, patch it; if it doesn't, create it with the correct path matching the Wolai page's location in the export tree.

4. **Add the concept/entity page as a source** — the `sources:` field in the concept page should include the raw article it came from (if any) AND the raw export it was synced to.

5. **Ensure provenance markers are added** — in the concept/entity page, add `^[raw/<path>.md]` markers at the end of paragraphs whose claims come from a specific source (see SCHEMA.md). After renaming or moving a source file, update ALL provenance markers that reference the old path — search across the entire wiki with `search_files(pattern="<old-path>", path="$WIKI")` to catch every reference.

**Read the raw export file:**
```
read_file(path="raw/<export>/.../<file>.md")
```

**Get the Wolai page structure:**
```
mcp_wolai_get_page_blocks(page_id="<found_id>")
```
This returns the full block tree. Identify where existing content ends and where to insert new blocks (the anchor block).

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
- **Raw articles in `raw/articles/` should be named after their content, not their original filename** — files exported from Google AI Mode use the prefix `google-ai-mode_<descriptive-name>.md` (e.g., `google-ai-mode_llm-inference-deep-dive.md`). See `references/raw-article-naming-conventions.md` for the full convention.
