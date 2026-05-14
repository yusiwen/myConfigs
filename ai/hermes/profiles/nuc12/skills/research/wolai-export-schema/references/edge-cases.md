# Edge Cases in Wolai Export → Local Path Mapping

Discovered during the full 14-export MCP crawl (May 2026). These are cases where the simple normalization rule `lowercase + spaces→hyphens` is not enough.

## 1. Parenthesized Acronyms

**Problem:** `"Server-Sent Events (SSE)"` normalizes to `server-sent-events-(sse)` but the export tool produced `server-sent-events-sse` (dropped the parentheses entirely).

**Pattern:** When a title ends with an acronym in parentheses, like `"Topic (ACRONYM)"`, the export seems to drop `(` and `)` and produce `topic-acronym`.

**Examples:**
| Wolai Title | Expected (naive) | Actual Export |
|---|---|---|
| Server-Sent Events (SSE) | `server-sent-events-(sse)` | `server-sent-events-sse` |

**Mitigation:** When a straight normalization doesn't match, try stripping parenthesized content: `title.replace('(', '').replace(')', '')` then re-normalize.

## 2. Slash in Title

**Problem:** `"C/C++"` — the slash `/` converts to `-` when not surrounded by spaces.

| Wolai Title | Export |
|---|---|
| C/C++ | `c-c++` |
| Reactor / Proactor | `reactor-/-proactor` (slash preserved with surrounding spaces) |

**Heuristic:** Slash with no surrounding spaces → becomes `-`. Slash with spaces → preserved.

## 3. Typo Preservation

The export tool faithfully preserves typos. "Programming Lanuages" → `programming-lanuages.md`. If a root file doesn't exist at the expected path, list the export root dir to check for typos.

## 4. `type: "database"` Blocks

Wolai `"type": "database"` blocks (inline databases) do NOT produce `.md` files in the export. Skip them during path prediction.

## 5. Ampersand

`&` is preserved as `&-` (space-ampersand-hyphen) by standard normalization. No special handling needed.

## 6. Dot in Title

Dots are preserved: `.Net Framework` → `.net-framework`. Standard normalization handles dots correctly.

## 7. UUID-Suffixed Flat Files (Artifact Duplicates)

**Problem:** Pages whose block ID ends up embedded in the filename produce flat duplicate `.md` files at the export root level:

```
timing-wheel_w9pq51uzt3ybqk32oghaf2.md
tree_cocux4xt17e5krtemi3nyg.md
```

These are **not standalone pages** — they are duplicates of pages already nested in the directory tree (`data-structures/queue/timing-wheel/timing-wheel.md` and `data-structures/tree/tree.md`). The UUID suffix (`_w9pq51uzt3ybqk32oghaf2`) is the block's MCP ID.

**Pattern:** When a page title normalizes to a string that also appears as a block ID prefix in the export URL, the tool may produce both:
- The canonical nested file: `parent/child/child.md`
- A flat artifact: `child_{block_id}.md`

**Mitigation:** Ignore root-level files with UUID suffixes. The canonical copy is always nested under its parent directory. If a file at root has a name matching `{title}_{more-than-12-chars}.md`, treat it as an artifact.

## 8. Heading→Page Child Pattern

**Problem:** A heading block (type: `"heading"`) can have a type: `"page"` child directly beneath it. The page file ends up in a subdirectory named after the heading:

```
工具/工具.md  (heading: "工具")
  ├── Presto (heading)              ← TYPE: heading
  │   └── Presto (page, 2VPsDp...)  ← TYPE: page → 工具/presto/presto.md
```

The heading itself produces NO file; only the type: `"page"` child produces the `.md` file. But the directory is named after the heading, not the page.

**Mitigation:** When scanning MCP blocks, a `type: "heading"` child followed by a `type: "page"` child creates the subdirectory. The heading title determines the directory name, but the page title determines the filename. Match both independently.

## 9. `get_page_blocks` Returns "页面不存在" Error

**Problem:** Some Wolai pages return `"页面不存在"` (page not found) from `mcp_wolai_get_page_blocks(page_id)` even though the page is accessible.

**Fix:** Use `mcp_wolai_get_page(page_id, include_blocks=true)` instead. This alternative endpoint returns the same block structure with `children.ids`, `type`, and child page data. The response format differs slightly (it wraps blocks differently) but the block data is the same.

**Real-world example:** The 面试 page (`eYWPoPVMNs6UHa1Yj7t8w2`) in miscellaneous-export failed with `get_page_blocks` but succeeded with `get_page`. All child page IDs were successfully extracted.

**When to try the fallback:** If `get_page_blocks` returns an error for a page that you know exists (it's in the page tree, the URL works in the browser), try the `get_page(include_blocks=true)` alternative before marking the page as not found.

## 10. Page ID Typo in Mapping Files

**Problem:** Mapping files sometimes have page IDs with missing characters. Before this session, `raw/tasks/mapping/algorithms-data-structures-export.md` had the Tree's page ID as `coCUX4x17E5KrTEmi3nYg` but the correct ID (from MCP) was `coCUX4xT17E5KrTEmi3nYg` (missing a 'T'). This was likely a transcription error during the initial mapping.

**Fix:** When the mapping file's predicted page ID doesn't match any child in the MCP response, suspect a typo. List the children and look for the closest spelling. The actual page ID is always what MCP returns — the mapping file's copy is the derived artifact and can have errors.

**Real-world example:** During the algorithms-data-structures deep crawl, `mcp_wolai_get_page_blocks(root_id)` returned no children, but the mapping file claimed the Tree page (`coCUX4x17E5KrTEmi3nYg`) existed. Searching for "Tree" in the export root page blocks revealed `coCUX4xT17E5KrTEmi3nYg` — one character different. The mapping was corrected and the page `get_page_blocks` confirmed it.

## 11. Misspelled Page Titles (Preserved as-is)

The export faithfully reproduces MCP page titles, including typos in the original wolai notes:

| MCP Title | Export Directory | Notes |
|-----------|-----------------|-------|
| Alogrithms | `alogrithms/` | Missing 'o' — not "Algorithms" |
| Programming Lanuages | `programming-lanuages/` | Missing 'g' |

**Mitigation:** Do not "correct" the spelling when predicting paths. The export file will match the MCP title, not the corrected form. If path prediction fails, list the parent directory to discover the actual filename.

## Fallback Path Prediction Algorithm

```python
def find_local_path(export_dir, normalized_title):
    base = f"raw/{export_dir}/{normalized_title}"
    # Try standard dir/file.md pattern
    if os.path.isfile(f"{base}/{normalized_title}.md"):
        return f"{base}/{normalized_title}.md"
    # Try flat (root-level file)
    if os.path.isfile(f"raw/{export_dir}/{normalized_title}.md"):
        return f"raw/{export_dir}/{normalized_title}.md"
    # Try without parenthesized acronym
    alt = normalized_title.replace('(', '').replace(')', '')
    if os.path.isfile(f"raw/{export_dir}/{alt}/{alt}.md"):
        return f"raw/{export_dir}/{alt}/{alt}.md"
    # Try slash→hyphen
    alt2 = normalized_title.replace('/', '-')
    if os.path.isfile(f"raw/{export_dir}/{alt2}/{alt2}.md"):
        return f"raw/{export_dir}/{alt2}/{alt2}.md"
    return None
```
