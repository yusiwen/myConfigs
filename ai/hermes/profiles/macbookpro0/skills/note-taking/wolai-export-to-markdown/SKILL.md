---
name: wolai-export-to-markdown
description: "Use when exporting Wolai (我来) notes/pages via MCP server to markdown files, organized in the same recursive folder structure as wolai.app's manual export feature."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [wolai, mcp, export, markdown, note-taking]
    related_skills: []
---

# Wolai MCP → Markdown Export

## Overview

Wolai (我来) MCP server provides block-level API access to pages. This skill documents how to recursively export a Wolai page tree to markdown files, matching the same folder structure as wolai.app's manual "export as markdown" feature (`PageName/PageName.md`).

The export supports: heading (3 levels), text with rich inline styling, code blocks, bookmarks, callouts, bullet/enum/todo lists, images, quotes, toggle lists, block equations, simple tables, and dividers.

## When to Use

- User wants to migrate/backup Wolai notes to a local markdown wiki
- User has an existing `raw/<category>-export/` folder structure and wants to add a new export
- User wants to programmatically export Wolai pages without using the desktop app
- User asks about converting MCP block data to markdown

**Don't use for:**
- Editing Wolai pages (use `mcp_wolai_update_block` etc.)
- One-time simple text extraction (use `get_page_outline` instead)

## Prerequisites

1. MCP server `wolai` must be enabled and running:
   ```
   hermes mcp list
   # → wolai    https://api.wolai.com/v1/mcp   all   ✓ enabled
   ```
2. You have access to the pages (MCP tools return them)

## Block Data Model

### MCP `get_page_blocks` returns a flat depth-first array:

```json
[
  {"id": "...", "type": "page", "content": [{"title": "Page Title", "type": "text"}],
   "parent_id": "...", "page_id": "...", "children": {"ids": ["child1", "child2", ...]}},
  {"id": "child1", "type": "heading", "content": [...], "level": 1,
   "children": {"ids": ["grandchild1", ...]}},
  {"id": "grandchild1", "type": "text", "content": [...]},
  ...
]
```

### Key fields:

| Field | Description |
|-------|-------------|
| `id` | Block ID |
| `type` | Block type: `page`, `heading`, `text`, `code`, `bookmark`, `callout`, `bull_list`, `enum_list`, `todo_list`, `image`, `quote`, `divider`, `toggle_list`, `block_equation`, `simple_table` |
| `content` | Array of rich text elements, each with `title`, `type`, and optional style fields (`bold`, `italic`, `underline`, `strikethrough`, `inline_code`, `link`, `front_color`, `back_color`) |
| `children.ids` | Ordered list of child block IDs |
| `level` | For heading blocks: 1, 2, or 3 |
| `parent_type` | Nesting level: `page`, `header`, `midHeader`, `subHeader`, etc. |
| `language` | For code blocks |
| `bookmark_source` | URL for bookmark blocks |
| `bookmark_info` | Title, description, hostname for bookmarks |
| `media.download_url` | Image URL |
| `checked` | For todo_list blocks |
| `table_content` | 2D array for simple_table |

### Content Element Types (within `content` array):

| Type | Markdown |
|------|----------|
| `text` | Plain text + styles |
| `bi_link` | Internal page reference → `[Title](wiki:ref_id)` |
| `equation` | `$LaTeX$` |

### Inline styles (`type: "text"`):

| Field | Markdown |
|-------|----------|
| `bold: true` | `**text**` |
| `italic: true` | `*text*` |
| `underline: true` | `<u>text</u>` |
| `strikethrough: true` | `~~text~~` |
| `inline_code: true` | `` `text` `` |
| `link: "url"` | `[text](url)` |

## Block → Markdown Mapping

| Wolai Type | Markdown Output | Notes |
|-----------|----------------|-------|
| `page` | `# Title` (H1) | Root page block, content used as title |
| `heading` (level=1) | `# Title` | Same H1 as page title (matching wolai.app export) |
| `heading` (level=2) | `## Title` | |
| `heading` (level=3) | `### Title` | |
| `text` (plain) | Inline rendered text | Merges content array with styles |
| `text` (with link) | `[Title](url "Title")` | Single-element link text |
| `text` (bi_link) | `[Title](wiki:ref_id)` | Internal page ref |
| `code` | ````language\ncode\n```` | Uses block's `language` field |
| `bookmark` | `> [Title](url)\n> Description` | Extended info style |
| `callout` | `> 💡 icon content` | |
| `bull_list` | `- content` | |
| `enum_list` | `1. content` | |
| `todo_list` | `- [x] content` or `- [ ] content` | Based on `checked` field |
| `image` | `![image](url)` | Uses `media.download_url` |
| `quote` | `> content` | |
| `divider` | `---` | |
| `toggle_list` | `<details><summary>title</summary>\n</details>` | |
| `block_equation` | `$$LaTeX$$` | |
| `simple_table` | Standard markdown table | Uses `table_content` 2D array |
| `page` (nested) | Separate .md file in subfolder | See Recursive Nesting section |

## Export File Structure Convention

Matches wolai.app's export format:

```
raw/<category>-export/
├── PageName.md                     ← Root page
├── SubPage/
│   ├── SubPage.md                  ← Sub-page
│   ├── GrandChild/
│   │   └── GrandChild.md           ← Deeper nesting
│   └── AnotherSub/
│       └── AnotherSub.md
└── OtherPage/
    └── OtherPage.md
```

**Rules:**
- Each page gets its own folder named after the page (slugified)
- Inside the folder, the markdown file has the same name as the folder
- Child pages go in sub-folders within the parent's folder
- Links between pages use relative paths: `[Title](SubPage/SubPage.md "Title")`
- Root page's table of contents links to sub-pages
- Each sub-page's TOC links to its own sub-pages (if any)

### Slugification Rules

```python
def slugify(name):
    name = name.strip().replace(" ", "-").replace("/","-")
    name = name.replace(":","-").replace("(","").replace(")","")
    name = re.sub(r'[<>"\\|?*]', '', name)
    name = re.sub(r'-+', '-', name).strip('-')
    return name or "untitled"
```

## Export Workflow

### Step 1: Fetch page hierarchy

```
mcp_wolai_get_page_blocks(page_id="ROOT_PAGE_ID")
```

This returns all blocks on the page, including sub-page references (blocks with `type: "page"`).

### Step 2: Recursively discover sub-pages

For each block with `type: "page"` and `id != root_id`, it's a sub-page reference. Fetch its full blocks:

```
mcp_wolai_get_page_blocks(page_id="SUB_PAGE_ID")
```

Repeat recursively until all sub-pages are fetched.

### Step 3: Save block data to JSON files

Each page's block data is saved as:
```json
{"page_id": "...", "title": "...", "blocks": [...]}
```
Named `/tmp/blocks_<slug>.json` for the conversion script.

### Step 4: Build tree structure from children.ids

```python
bm = {b["id"]: b for b in blocks}
for b in blocks:
    cids = b.get("children", {}).get("ids", [])
    b["_kids"] = [bm[cid] for cid in cids if cid in bm]
```

### Step 5: Recursively export to markdown

```python
def export_recursive(blocks, output_dir):
    page_title = get_page_title(blocks)
    slug = slugify(page_title)
    os.makedirs(output_dir, exist_ok=True)
    
    # Find and recursively export sub-pages first
    subpages = find_subpages(blocks)
    subpage_links = []
    for sp in subpages:
        sp_id = sp["id"]
        if sp_id in id_map:  # id_map has all loaded block data
            sp_blocks = id_map[sp_id]
            sp_dir = os.path.join(output_dir, sp_slug)
            export_recursive(sp_blocks, sp_dir)
            subpage_links.append((sp_slug, sp_title))
    
    # Write this page with TOC linking to sub-pages
    md = page_to_md(blocks, subpage_links)
    with open(os.path.join(output_dir, f"{slug}.md"), "w") as f:
        f.write(md)
```

### Step 6: Root page TOC

Root page `Web.md` has:
```
# Web
## 目录
- [Sub1](Sub1/Sub1.md "Sub1")
- [Sub2](Sub2/Sub2.md "Sub2")
```

### Step 7: Verify

```
find raw/<category>-export -type f | wc -l
# Check for missing pages
check_missing.py  # Scans all block files for type="page" without data
```

## Total Page Count

Before starting, call `mcp_wolai_get_page_outline` on the root page to understand the structure. The outline shows all sections and their sub-section counts, giving a preview of how much content exists.

## Common Pitfalls

1. **Missing sub-page references in saved data.** When saving simplified block data (omitting deep child blocks), the recursive export won't know about them. Always include the `type: "page"` blocks in parent pages' data, and list their IDs in `children.ids`.

2. **Infinite recursion from cross-references.** Wolai allows internal `bi_link` references to any page. These appear as `type: "text"` with `type: "bi_link"` inline, NOT as `type: "page"` blocks. Only follow `type: "page"` children.

3. **Heading level confusion.** Wolai exports use `#` (H1) for both the page title AND section headings level-1. This matches the official wolai.app export format. Don't change heading levels to H2 for sections.

4. **Escaped JSON in MCP responses.** When `get_page_blocks` returns large data, the result may have double-escaped JSON (`"result": "{ \\"status\\": ...}"`). Use `json.loads(wrapper["result"])` to decode twice.

5. **Large pages timing out.** Pages with 100+ blocks (e.g., Security at 145 blocks) may need longer timeouts (60s) for `extract_blocks.py` processing.

6. **bi_link vs sub-page.** A `bi_link` in a text block is an inline cross-reference to another page (not a sub-page). Only `type: "page"` blocks with `id != root_id` are true sub-pages.

7. **Export script vs MCP tool.** The conversion script runs via Python on the filesystem, not through MCP. Save block data as JSON first, then run the converter.

## Verification Checklist

- [ ] All `type: "page"` blocks in every saved data file have corresponding `/tmp/blocks_*.json` files
- [ ] Root page `Web.md` has TOC linking to all direct sub-pages
- [ ] Each sub-page with children has a TOC linking to its sub-pages
- [ ] No "data not found" warnings in export output
- [ ] File count matches: 1 root + all recursively discovered sub-pages
- [ ] External links use `[Title](url "Title")` format
- [ ] Internal wiki links use `[Title](wiki:ref_id)` format
- [ ] Code blocks have language annotations
- [ ] Image blocks preserve their download URLs
- [ ] Folder structure matches the `Parent/Child/Child.md` convention
