# MCP Content Audit for Wiki Ingestion Planning

> Use MCP tools to inventory content sources (wolai, Notion, etc.) before wiki ingestion.
> Compare against on-disk `raw/*-export` folders to find gaps and plan processing.

## When to Use

- A new export from a note-taking app is available and needs processing
- You're planning an initial wiki ingest and want to scope the work
- The user wants to know "how many pages need processing" or "what's missing"
- You want to verify that an export covers everything expected

## Workflow

### ① Inventory Top-Level Pages via MCP

```python
# Pattern: use the source's list-pages MCP tool
# For wolai:
mcp_wolai_list_pages()  # returns all top-level pages with IDs, titles, permissions
```

Capture:
- **Page title** — display name in the source app
- **Page ID** — stable identifier for further MCP queries
- **Total count** — how many top-level pages exist

### ② Inventory On-Disk Exports

```bash
# Find all export folders in raw/
ls -d raw/*-export/
# Or find any raw/ directory at a known wiki path
find <wiki-path> -maxdepth 4 -type d -name 'raw' 2>/dev/null
```

Capture:
- **Folder names** — typically `<topic>-export` format
- **Extra folders** — note any `articles/` or non-export directories

### ③ Create Gap Map

Compare MCP page list against on-disk export folders. Classify each:

| Status | Meaning |
|--------|---------|
| ✅ **Exported** | Page has a matching `*-export` folder on disk |
| ❌ **Not exported** | Page exists in MCP but has no export folder |
| ❓ **Extra** | Folder exists on disk but no matching MCP page |

This answers: "What do we need to export before we can ingest?"

### ④ Recursively Explore a Target Page

For a page that needs processing, determine the full scope:

**a) Get page blocks (flat) — discovers child page IDs:**

```python
mcp_wolai_get_page_blocks(page_id="<id>")
```

Key patterns to look for in the response:
- `"type": "page"` blocks = **sub-pages** (these are the real children that need their own wiki entries)
- `"type": "bi_link"` blocks = **cross-reference links** to pages in other workspaces — these are not sub-pages; they're inline references to external content
- `"type": "heading"` blocks = **sections** within the current page
- `"children": { "ids": [...] }` = IDs of child blocks within each block

**b) Get page outline (hierarchical) — assesses content depth:**

```python
mcp_wolai_get_page_outline(page_id="<id>", max_depth=9)
```

Returns:
- `total_blocks` — rough content volume indicator
- `total_sections` — number of titled sections
- `max_depth` — deepest nesting level
- Section tree with headings, previews, and child section counts

**c) Repeat for each child page (type="page"):**
- Process each sub-page the same way: outline + blocks
- Build the full tree recursively

### ⑤ Classify Sub-Pages by Content Density

| Density | Signals | Blocks | Action |
|---------|---------|--------|--------|
| 🔴 **Very rich** | Many sections, deep nesting, code blocks | 60-150+ | Heavy processing, dedicated wiki pages |
| 🟡 **Medium** | Multiple sections, moderate blocks | 20-60 | Standard wiki page(s) |
| 🟢 **Thin** | Few sections, mostly links/bookmarks | 5-20 | Quick processing, may group with siblings |
| ⚪ **Very thin** | Only external refs (bi_links), no original content | 0-5 | Minimal; often external-link-only |

### ⑥ Produce Audit Report

The report should include:

```
## 📊 Total Scope
- Total pages in tree: N (1 root + N-1 sub-pages)
- Total blocks: ~N
- Total sections: ~N

## 🌳 Page Tree (recursive, indented)
Web 🕸️ (14 blocks)
├── DNS ⚪ (2 blocks, 2 external refs)
├── CDN 🟡 (33 blocks, 3 sections)
│   ├── Implementation
│   ├── Websocket CDN
│   └── 实践
│       ├── Nginx Configuration Demonstrations
│       └── ...
├── Security 🔴 (144 blocks, 14 sections)
│   ├── CORS
│   │   ├── Protocol
│   │   │   ├── HTTP requests
│   │   │   └── HTTP responses
│   │   └── ...
│   └── ...

## 📋 Content Density Breakdown
| Page | Blocks | Sections | Density | Process Priority |
```

## MCP Tool Reference for wolai

| Tool | Purpose | Usage |
|------|---------|-------|
| `mcp_wolai_list_pages` | Top-level page inventory | Call once at start |
| `mcp_wolai_get_page_blocks` | Flat block list + child discovery | Call per page to find sub-pages |
| `mcp_wolai_get_page_outline` | Hierarchical heading structure | Call per page for content depth |
| `mcp_wolai_get_page` | Single page detail + blocks | Call for deeper inspection of specific blocks |

## Interpretation Rules

- **`type="page"` = sub-page** — these are the entries you'd process as individual wiki pages
- **`bi_link` = external reference** — links to content in another workspace/page; not a sub-page, just a cross-ref
- **`bookmark` = external URL** — a saved link to an external website; minimal content
- **`heading` = section** — topics within the current page
- **A page with only `bi_link`/`bookmark` children is thin** — it's basically a link collection, not original writing
- **Pages with `is_full_width: true` and many sections** are the primary knowledge content

## Pitfalls

- **Don't confuse `bi_link` blocks with sub-pages.** A bi_link is an inline cross-reference to another page (often in a different workspace). It doesn't need its own ingest entry.
- **Don't assume content volume equals importance.** Some thin pages (WebSocket, DNS) contain crucial architectural explanations embedded in just a few blocks.
- **The root page may just be a directory index.** Check if it has substantial original content or just links to children.
- **Some MCP tools have max_depth limits** (often 6 or 9). Set it high enough to capture all nesting.
- **Block counts are rough proxies.** A page with 144 blocks but 50 external bookmarks is less content-dense than a page with 40 blocks of original writing.

## Real Example: Web Page Audit

See the conversation with `page_id: "iEW5q6vke2uSz7t6Pw2y5y"` (title: "Web") for a complete worked example that found:
- 12 total pages (1 root + 11 sub-pages)
- ~401 total blocks
- 70+ sections at various depths
- 9 "substantial content" pages + 3 "thin" pages
- 5 missing exports (Code Snippets, Transfer between devices, Quick Notes, My Workbench, Web)
