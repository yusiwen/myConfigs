---
name: wolai-export
description: "Export wolai pages to Markdown via MCP. Convert all block types (heading, text, code, bookmark, callout, bull_list, enum_list, todo_list, image, bi_link) to well-formatted .md files matching wolai.app's export convention."
version: 1.0.0
tags:
  - wolai
  - mcp
  - markdown
  - export
  - notes
---

# Wolai → Markdown Export via MCP

Convert wolai pages to Markdown using the `mcp_wolai_*` tools, matching the same file structure that wolai.app produces when you export manually.

## Block Type → Markdown Mapping

### Block-Level Types

| wolai type     | Markdown output                          |
|----------------|------------------------------------------|
| `heading`      | `#`/`##`/`###` depending on `level`      |
| `text`         | Inline rendered text (see rich text)     |
| `code`         | ` ```language \n code \n ``` `           |
| `bookmark`     | `> [title](url)` + `> description`      |
| `callout`      | `> icon content`                         |
| `bull_list`    | `- content`                              |
| `enum_list`    | `1. content`                             |
| `todo_list`    | `- [x] content` or `- [ ] content`       |
| `image`        | `![image](download_url)`                 |
| `divider`      | `---`                                    |
| `block_equation`| `$$ LaTeX $$`                           |
| `simple_table`  | Standard Markdown table                 |
| `toggle_list`  | `<details><summary>title</summary></details>` |
| `quote`        | `> content`                              |
| `page`         | (handled as a separate sub-page file)    |

### Inline Rich Text

Each `content` array element can have these style flags:

| Flag           | Markdown                              |
|----------------|---------------------------------------|
| `bold: true`   | `**text**`                            |
| `italic: true` | `*text*`                              |
| `underline: true` | `<u>text</u>` (no native MD)      |
| `strikethrough: true` | `~~text~~`                    |
| `inline_code: true` | `` `text` ``                     |
| `link: "url"`  | `[text](url "title")`                 |
| `type: "bi_link"` | `[title](wiki:ref_id)`            |
| `type: "equation"` | `$ LaTeX $`                      |

### slugify function

```python
def slugify(name):
    name = name.strip().replace(" ","-").replace("/","-").replace(":","-")
    name = name.replace("(","").replace(")","")  # Strip parens!
    name = re.sub(r'[<>"\\\\|?*]','',name)
    name = re.sub(r'-+','-',name).strip('-')
    return name or "untitled"
```

Parentheses must be stripped (e.g., `Server-Sent Events (SSE)` → `Server-Sent-Events-SSE` not `Server-Sent-Events-(SSE)`).

### Block indentation

Do NOT indent child blocks under headings — the export convention uses no indentation (matching wolai.app output). Set `indent=0` for all blocks:

```python
def block_to_md(block, indent=0):
    typ = block.get("type","")
    pre = ""  # No indentation prefix
    ...
```

## Export File Structure Convention

Match the wolai.app export format exactly:

```
raw/category-export/
├── CategoryName.md                    # Root page
├── SubPage/SubPage.md                 # Sub-page (folder + .md match)
├── SubPage/GrandChild/GrandChild.md   # Deeper nesting
└── SubPage/image/image_xxx.png        # Images in parent folder
```

Rules:
- **Root page**: `RootName.md` at top level
- **Sub-page**: folder named after page, with identically-named `.md` inside: `SubName/SubName.md`
- **Deeper nesting**: same pattern recursively: `SubName/GrandChild/GrandChild.md`
- **Spaces in names**: wrap in angle brackets: `<Folder Name/Folder Name.md>`
- **Child page links**: `[Title](ChildName/ChildName.md "Title")`
- **External links**: `[title](url "title")` (title repeated as tooltip attribute)
- **Page title**: always `# Title` as H1
- **Section headings**: use H1 (`#`) for each top-level section (matching export convention — the page title and section titles both use H1)

## Recursive Nesting (Deep Sub-Pages)

Some pages have sub-pages deeper than Level 1 (e.g., SSE → SseEmitter Example, WebAssembly → WasmEdge). Handle these recursively:

### Algorithm

```python
# Load all block data files, index by page_id
id_map = {}
for jf in glob.glob("/tmp/blocks_*.json"):
    with open(jf) as f:
        data = json.load(f)
    id_map[data["page_id"]] = data["blocks"]

def find_subpages(blocks):
    """Find type='page' children that are NOT the root page block."""
    root_id = next(b["id"] for b in blocks if b.get("type") == "page")
    return [b for b in blocks if b.get("type") == "page" and b["id"] != root_id]

def export_recursive(blocks, output_dir):
    """Recursively export a page and its sub-pages."""
    page_title = get_page_title(blocks)
    slug = slugify(page_title)
    os.makedirs(output_dir, exist_ok=True)
    
    subpages = find_subpages(blocks)
    subpage_links = []
    
    for sp in subpages:
        sp_id = sp["id"]
        sp_title = get_page_title([sp])
        sp_slug = slugify(sp_title)
        
        if sp_id in id_map:  # Has full block data
            sp_blocks = id_map[sp_id]
            sp_dir = os.path.join(output_dir, sp_slug)
            export_recursive(sp_blocks, sp_dir)  # Recurse!
            subpage_links.append((sp_slug, sp_title))
    
    # Write this page's .md with TOC linking to child pages
    md = page_to_md(blocks, subpage_links if subpage_links else None)
    with open(os.path.join(output_dir, f"{slug}.md"), "w") as f:
        f.write(md)
```

### Output structure

```
CategoryName/
├── CategoryName.md              ← root, TOC links to children
├── SubPage/SubPage.md           ← Level 2
├── SubPage/GrandChild/GrandChild.md  ← Level 3 (nested folder)
└── Parent/Child/Child.md        ← works for any depth
```

### Data requirement

Each sub-page at any depth needs its own `/tmp/blocks_<slug>.json` file with the full block data. The root page's `get_page_blocks` only includes the sub-page reference markers (`type: "page"` with id/title only), NOT the sub-page's content blocks.

## Conversion Steps

### 0. Determine page hierarchy first

Before fetching, run `mcp_wolai_get_page_outline()` with `max_depth=9` to see the full tree structure and estimate how many pages you'll need to process.

### 1. Fetch page blocks

```python
# Agent call
mcp_wolai_get_page_blocks(page_id="...")
```

Returns a flat array of blocks. Each block has:
- `id` — unique ID
- `type` — block type
- `content` — rich text array
- `parent_id`, `page_id`, `parent_type` — tree structure
- `children.ids` — ordered child block IDs (used to rebuild nesting)

### 2. Save block data to JSON files

Each page (root + every sub-page at any depth) needs its own `/tmp/blocks_<slug>.json` file:

```json
{"page_id": "...", "title": "...", "blocks": [...]}
```

**CRITICAL: Include ALL type="page" reference blocks.** When saving a parent page's blocks, every sub-page reference (`type="page"` blocks that are NOT the root block) must be included. If omitted, the recursive exporter won't know deeper pages exist. See Data Flow Patterns (Pattern C) for how to patch missing references.

Also ensure the parent page block's `children.ids` array includes the sub-page block IDs.

### 3. Rebuild tree structure

The key insight: blocks are a **flat depth-first list** with `children.ids` encoding parent-child relationships.

```python
def build_tree(blocks):
    block_map = {b["id"]: b for b in blocks}
    for b in blocks:
        cids = b.get("children", {}).get("ids", [])
        b["_kids"] = []
        for cid in cids:
            if cid in block_map:
                b["_kids"].append(block_map[cid])
    return flatten(root_block)

def flatten(node, depth=0):
    result = [(node, depth)]
    for child in node.get("_kids", []):
        result.extend(flatten(child, depth + 1))
    return result
```

### 4. Organize pages

- **Root page blocks** include page-type references (`type: "page"`) for sub-pages
- Each sub-page's actual content blocks come from a separate `get_page_blocks` call
- The root page's TOC links to sub-page files

### 5. Write files

For each page (root + all sub-pages):
- Convert blocks to markdown text
- Write to the correct file path per the export convention

### 6. Iterate for deep pages

Run the recursive exporter (`scripts/export-recursive.py`) and check for `⚠ data not found` warnings. For each missing sub-page:

1. Call `mcp_wolai_get_page_blocks(page_id)` for that page
2. Save its block data to `/tmp/blocks_<slug>.json`
3. If the parent's blocks didn't include the sub-page reference (Pattern A), patch them in (Pattern C)
4. Re-run the exporter

Repeat until no more warnings (pages go 5+ levels deep in real-world notes).

## Data Pipeline: MCP to JSON to Export

Block data cannot flow directly from MCP calls to Python. The pipeline is:

### Save Script Pattern A: Compact pages

Write a save script, then run it:

```python
# Written to /tmp/save_page.py
import json
blocks = [... block data ...]
with open('/tmp/blocks_mypage.json', 'w') as f:
    json.dump({"page_id": "...", "title": "MyPage", "blocks": blocks}, f, ensure_ascii=False)
```

Then: `terminal("python3 /tmp/save_page.py")`

### Save Script Pattern B: Large pages from persisted temp files

Large MCP outputs (100+ blocks) auto-persist to `/var/folders/.../hermes-results/call_*.txt` with doubly-encoded JSON. Extract using the bundled script:

```bash
python3 <skill_dir>/scripts/extract-blocks.py <mcp_temp_file> /tmp/blocks_out.json <page_id> "Page Title"
```

### Save Script Pattern C: Patch sub-page references

If a parent page's saved data is missing type="page" sub-page marker blocks, patch them in:

```python
subpage_refs = [
    {"id":"...","type":"page","content":[{"title":"SubPage","type":"text"}],
     "parent_id":"...","page_id":"...","parent_type":"page","children":{"ids":[]}},
]
with open('/tmp/blocks_parent.json') as f: data = json.load(f)
blocks = data['blocks']
for sp in subpage_refs:
    if not any(b['id'] == sp['id'] for b in blocks):
        blocks.append(sp)
data['blocks'] = blocks
with open('/tmp/blocks_parent.json', 'w') as f: json.dump(data, f, ensure_ascii=False)
```

## Pitfalls

- **MCP data to Python**: MCP tool results go to agent context, not filesystem. Use Pattern A/B/C above.
- **Large pages** (100+ blocks, e.g., security at 144 blocks): auto-persisted to temp files. Use Pattern B (extract-blocks.py).
- **Sub-pages within sub-pages**: Some pages have type=page children deeper than Level 2. These require separate get_page_blocks calls. The recursive exporter handles this automatically if JSON data exists.
- **bi_link to external workspaces**: Pages in other workspaces appear as bi_link. Convert to [title](wiki:ref_id). They have no block data here.
- **Image URLs expire**: download_url has expires_in (usually 1800s). Download immediately or they 403.
- **Block type variant bul_list**: Some MCP responses use type=bul_list (one L) instead of bull_list. Handle both in the converter.
- **find_subpages StopIteration**: If no type=page block exists in the data, next() will crash. Use a safe fallback loop instead.
- **Sub-page references must exist**: The recursive exporter iterates type=page blocks. If a parent's saved JSON is missing the sub-page marker blocks, those sub-pages are invisible. Patch them in (Pattern C).
- **Sub-page references must be in children.ids**: Even if the sub-page marker block exists, the parent page's `children.ids` array must include the sub-page's block ID. If omitted, the tree builder won't visit it and the exporter won't recurse into it.
- **Iterate until no warnings**: Real-world note hierarchies go 5+ levels deep. Run the exporter, fix missing pages, repeat. Don't try to fetch all levels at once.
- **Hardcoded root_id in export-recursive.py**: The script has `ROOT_ID = "iEW5q6vke2uSz7t6Pw2y5y"` hardcoded for the "Web" page. For other exports, change this constant or add a CLI argument.
- **Large page batch fetching can be slow**: When doing Pattern A for many pages, each needs a separate write_file + terminal run. Prefer getting the page IDs from an outline call first to plan the work.

## Reference Files

This skill contains these reference files:

| File | Purpose |
|------|---------|
| `references/block-types.md` | Quick reference for all block types, rich text fields, and export conventions |
| `scripts/extract-blocks.py` | Extract block data from MCP's doubly-escaped JSON temp files to clean JSON |
| `scripts/export-recursive.py` | Full recursive converter: reads `/tmp/blocks_*.json` → produces export with deep nesting |

Usage pattern:
1. Call `mcp_wolai_get_page_blocks(page_id)` to fetch blocks
2. Save block data to `/tmp/blocks_<slug>.json` (format: `{"page_id", "title", "blocks"}`)
3. Run `python3 <skill_dir>/scripts/export-recursive.py` to generate the export with full nesting

For large pages persisted as temp files by the agent:
```bash
python3 <skill_dir>/scripts/extract-blocks.py <mcp_temp_file> /tmp/blocks_out.json <page_id> <title>
```

> **Tip**: Create a separate save script per page using `write_file()` then `terminal("python3 script.py")`.

## Verification

After export:
```bash
find raw/category-export/ -type f | sort
```

Check against a known-good export (e.g., `raw/tools-export/`) for structural consistency:
- Root .md has TOC + child page links
- Each sub-page folder has identically-named .md
- No bare block data leaking between pages
