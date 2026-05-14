---
name: sync-export-to-wolai
description: "Update a raw export markdown file AND its corresponding Wolai page simultaneously, keeping both in sync. Covers: locating the Wolai page ID via mapping files, editing both sides, and git commit/push."
version: 1.0.0
author: Hermes Agent
---

# Sync Raw Export ↔ Wolai Page

## When This Skill Activates

This skill activates when the user asks you to update content in a **raw export file** (under `raw/<export-name>/...`) and you need to also update the corresponding **Wolai page** via MCP. This happens when:

- The user discovers missing context in a raw export and wants it fixed in both places
- A wiki concept page was improved and the raw source should reflect the changes
- The user explicitly asks to "update the export page and the corresponding Wolai note"

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

### Step 3: Understand Both Structures

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
| Insert blocks after a specific block | `mcp_wolai_insert_blocks_relative(anchor_block_id, placement="after", blocks=...)` | Best for appending between existing text and bookmark links |
| Insert under a heading | `mcp_wolai_insert_under_heading(page_id, target_section_id, placement="append_inside", blocks=...)` | Good if you want new content at top or bottom of a section |
| Replace a section entirely | `mcp_wolai_rewrite_section(page_id, section_id, blocks=...)` | Use only when replacing all content under a heading |

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

### Step 6: Git Commit and Push

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
