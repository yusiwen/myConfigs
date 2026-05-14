---
name: wolai-export-schema
description: "Reverse-engineered schema of wolai.app's markdown export format. Documents how pages, subpages, blocks, images, files, and internal links are rendered to the filesystem. Required knowledge before building MCP↔local path mappings."
version: 1.2.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [wolai, export, schema, mcp, sync, mapping]
    category: research
    related_skills: [wiki-reingest, wiki-git-pull-push, wiki-content-audit]
---

# Wolai Export Schema

## Trigger

This skill activates when you need to:
- Understand the structure of files in `raw/*-export/` directories
- Build a bidirectional mapping between MCP page IDs and local file paths
- Diagnose export anomalies (duplicate files, missing content)
- Plan a sync workflow between wolai.app and the local wiki

## Export Overview

The 14 `raw/*-export/` directories are snapshots of wolai.app root pages exported to markdown via wolai's built-in export feature. Each export directory corresponds to one root page in wolai.

| Export dir | Wolai root page | Size |
|---|---|---|
| `algorithms-data-structures-export` | Algorithms & Data Structures | 56 files |
| `artificial-intelligence-export` | Artificial Intelligence | 226 files |
| `big-data-data-science-export` | Big Data & Data Science | 48 files |
| `cloud-computing-export` | Cloud Computing | 607 files |
| `compilers-linkers-export` | Compilers & Linkers | 30 files |
| `database-export` | Database | 139 files |
| `distributed-systems-export` | Distributed Systems | 197 files |
| `miscellaneous-export` | Miscellaneous | 72 files |
| `network-export` | Network | 265 files |
| `operating-system-export` | Operating System | 318 files |
| `programming-languages-export` | Programming Languages | 1305 files |
| `thoughts-export` | Thoughts | 156 files |
| `tools-export` | Tools | 195 files |
| `web-export` | Web | 37 files |

## File Structure Convention

### Hierarchy Mapping

Every wolai page (type: `"page"` block) maps to a **directory** + a **markdown file** with the same name:

```
wolai: /compilers-and-linkers/Tools/GCC
       ↓ export       ↓ normalize title
local: compilers-linkers-export/tools/gcc/gcc.md
                               └─dir──┘└─file─┘  (same name!)
```

### Root Page

The root page file sits at the export root:

```
compilers-linkers-export/compilers-&-linkers.md
database-export/database.md
web-export/web.md
```

### Subpages

Each subpage creates two things:
1. A **directory** named after the page (normalized)
2. A **markdown file** of the same name inside that directory

```
tools/gcc/gcc.md      ← standard case
tools/tools.md        ← the Tools *directory* has a tools.md for the Tools page itself
```

### Nested Subpages (3+ levels deep)

Continue the pattern recursively:

```
tools/graalvm/native-image/native-image.md
                  └── child dir ──┘└─── file ────┘
```

## Filename Convention

The export normalizes page titles with these rules:

| Rule | Before | After |
|---|---|---|
| Lowercase | `GCC Options` | `gcc-options` |
| Spaces → hyphens | `Large Language Models` | `large-language-models` |
| Chinese preserved | `原理` | `原理` |
| Parentheses preserved | `JWT（JSON Web Token）` | `jwt（json-web-token）` |
| Ampersand preserved | `Tools & Utilities` | `tools-&-utilities` |
| Apostrophe preserved | `Let's Encrypt` | `let's-encrypt` |
| Question mark preserved | `如何实现的？` | `如何实现的？` |
| Dashes preserved | `JIT-compilation` | `jit-compilation` |
| Trailing spaces stripped | `title ` | `title` |

## Duplicate File Pattern (Critical!)

When a page has child subpages, the export creates **two copies**:

```
# Expected (dir + file same name):
gcc/gcc.md

# Also created (duplicate nesting):
gcc/gcc/gcc.md  
gcc/additional-tools/additional-tools/additional-tools.md
```

This happens because the export tool creates the directory structure, then re-exports child pages as if the parent directory itself is a page. The outer copy (`parent/file.md`) is canonical. The inner copy (`parent/parent/parent.md`) is an artifact — the files are identical.

**Rule:** When matching paths, prefer the shallowest match. The deep-nested duplicates can be ignored.

## Frontmatter

**Most exported pages have NO frontmatter.** The markdown starts directly with `# Title`.

Exception: pages that were **re-ingested** into the wiki (via `wiki-reingest` skill) have a small frontmatter block added during ingestion:

```yaml
---
source_export: wolai-web
ingested: 2026-05-11
sha256: fdad33943dcf6cc7b0fad2b71ceb40b2760e3607c2dcfdf356734ecd293f0f62
---
```

## Markdown Content Format

### Page Structure

Every page follows this template:

```markdown
# Page Title

## 目录

- [Section 1](#Section-1)
- [Section 2](#Section-2)
  - [Subsection 2.1](#Subsection-2.1)

<!-- bookmarks / links / actual content ... -->
```

The `## 目录` section is the auto-generated Table of Contents from wolai.

### Block Types in Markdown

| Wolai Block | Markdown Output |
|---|---|
| **Heading h1** | `# Section Title` |
| **Heading h2** | `## Subsection Title` |
| **Heading h3** | `### Deeper Title` |
| **Text block** | Plain markdown text |
| **Bullet list** | `- item` |
| **Numbered list** | `1. item` |
| **Todo list** | `- [ ] task` / `- [x] done` |
| **Code block** | ```` ```language ```` |
| **Bookmark** | `[Title](url "Title")` |
| **Image** | Stored in `image/` subdirectory, referenced via relative path |
| **File attachment** | Stored in `file/` subdirectory, referenced via relative path |
| **Divider** | `---` |
| **Callout / Quote** | `> text` |
| **Simple table** | Standard markdown table `\| col1 \| col2 \|` |

### Internal Links (bi_links)

Internal links between wolai pages are rendered as:

```markdown
[Target Page Title](https://www.wolai.com/PAGE_ID "Target Page Title")
```

The URL contains the wolai page ID in the path (e.g., `https://www.wolai.com/qtGYp9QJiTDqEDH3kFDGWv`). This is the key for MCP↔local mapping.

Multiple bi_links on one line are concatenated:
```markdown
[Page A](url-a "Page A")[Page B](url-b "Page B")
```

### External Links

Standard markdown links:
```markdown
[visible text](https://example.com "tooltip text")
```

### Code Blocks

Language-specified fenced code blocks:
````markdown
```python
def hello():
    print("world")
```
````

### Image / File Attachments

Images and files are stored in `image/` and `file/` subdirectories alongside the page's markdown file. They also exhibit the duplicate nesting pattern:

```
tools/clang/image/image_ywdetpgzxb.png            ← canonical
tools/clang/image/image/image_ywdetpgzxb.png       ← duplicate artifact
```

The markdown references use relative paths:
```markdown
![alt text](image/image_name.png)
[link text](file/document.pdf)
```

## Non-Export Pages (No Local Snapshot)

4 wolai root pages have NO corresponding export directory:

| Wolai Page | ID | Purpose |
|---|---|---|
| Code Snippets | `t3cQz3B65ykiRioor4D3zd` | Code snippets, not wiki content |
| Transfer between devices | `ii547eNBoaFppfCjpq6hnd` | Cross-device transfer helper |
| Quick Notes | `hYfSappafo6pGXdRsVrEZu` | Scratch notes |
| My Workbench | `eRABbBQazaAMvuTHiaQoty` | Personal workbench |

These were created after the export snapshot or are utility pages not meant for the wiki.

## Processing Order: Smallest-First

Process exports in **ascending order by file count** (30, 37, 48, 56, 72, 139, 156, 195, 197, 226, 265, 318, 607, 1305). This yields quick wins early, builds crawl confidence with small datasets, and means if context runs out mid-way through a large export, less progress is lost.

## Progress Tracking Pattern

After each export completes, present a progress table so the user stays oriented across multi-session work:

| # | Export | Files | Status |
|---|--------|-------|--------|
| 1 | compilers-linkers-export | 30 | Done |
| 2 | web-export | 37 | Done |
| ... | ... | ... | ... |
| 14 | programming-languages-export | 1305 | Pending |

Keep this table updated in the conversation after each export. Do NOT rely on reading old mapping files to remember progress — the table in the current message is the source of truth.

## Large Export Efficiency Heuristic

For exports with **100+ local files** (database-export and above), it is more efficient to **confirm L1 page IDs** and mark deeper subpages as "block ID needed" rather than crawling every sub-leaf to full depth. The 95%+ match rate of the path-prediction algorithm makes deep crawling unnecessary for most subpages.

**Procedure for large exports:**
1. Read existing L1-L2 mapping
2. Call `get_page_blocks` for each L1 page to confirm it's a type:"page" (not heading-only)
3. For L1 pages with type:"page" children, note them as "has subpages"
4. Do NOT recurse into every sub-page's children beyond confirming their type
5. Write the mapping file with those deeper pages marked `need block ID`

Reserve full-depth BFS crawling for small exports (under 100 files) where confirmation matters more than speed.

## Known Edge Cases

See `references/edge-cases.md` for the complete edge-case catalog. Key ones:

1. **Parenthesized acronyms** — `(SSE)` may be stripped: normalize then try `title.replace('(', '').replace(')', '')`
2. **Slash in title** — `/` becomes `-` when not surrounded by spaces (C/C++ → c-c++)
3. **Typo preservation** — Export faithfully preserves wolai typos in filenames
4. **`type: "database"` blocks** — Inline database tables produce NO export files
5. **Heading→subdirectory** — h1 headings with a child `type: "page"` block may become subdirectories
6. **UUID-suffixed flat files** — Occasionally the export produces a flat `.md` file at the export root with a UUID suffix (e.g., `timing-wheel_w9pq51uzt3ybqk32oghaf2.md`). These are duplicates of a deeper page that the export tool failed to place into the correct subdirectory. Check if the UUID matches a subpage block ID or parent page ID; the canonical copy is in the subdirectory.

## Full Mapping Results

See `references/mapping-results.md` for the complete 14-export mapping table with match rates. Key takeaway: **13/14 exports achieve 90-100% match rates** using the path-prediction algorithm below.

## Full-Depth BFS Crawl Methodology

When the L1-L2 surface mapping is complete, pages flagged as having `type: "page"` sub-children require a **BFS recursive crawl** to discover the full tree depth.

### When to Crawl

Load this skill when:
- You need to build a full-depth mapping of all pages in a wolai export (not just L1-L2)
- You're verifying which MCP subpages map to which local files at depth 2+
- You're storing mapping results in `raw/tasks/mapping/<export>.md`

### BFS Crawl Procedure

For each export with flagged subpages:

1. **Start with L1 subpages** — from the `mcp_wolai_get_page_blocks()` response, identify children where `"type": "page"`. These are subpages that produce their own export directories.

2. **Recurse** — call `get_page_blocks(page_id)` for each type:"page" child. Check its children the same way. Continue until a page has no type:"page" children (it's a leaf).

3. **Leaf test** — a page is a leaf when all its children are `text`, `heading`, `bookmark`, `code`, `image`, `quote`, `bul_list`, `enum_list`, `bull_list`, `bi_link`, or `divider` types — anything EXCEPT `page`.

4. **Match local paths** — each MCP page maps to `{parent-dir}/{normalized-title}/{normalized-title}.md`. Verify the file exists on disk.

5. **Save incremental cache** — every 10-15 calls, write to `_mapping_cache/<export>.json` to survive session interruptions.

### Rate Limiting

```python
# Conservative: 2-4 parallel calls per turn
# Batch size 4 tested successfully with zero errors across 30+ MCP calls
# Start at 2 for safety, increase to 4 for throughput
```

The wolai MCP API handles batch size 4 without errors. The user may want to start conservatively at 2 for safety, but 4 has been verified in production scans.

### `get_page` Fallback for Failed Pages

Occasionally `mcp_wolai_get_page_blocks(page_id)` returns `"页面不存在"` (page not found) for pages that actually exist. This is a known API quirk — the page exists and is accessible but the blocks endpoint refuses.

**Fallback:** Use `mcp_wolai_get_page(page_id, include_blocks=true)` instead. This returns the same children block structure. Example: the 面试 page (`eYWPoPVMNs6UHa1Yj7t8w2`) succeeded with this fallback.

**When to try:** If `get_page_blocks` errors but you know the page exists (it's in the tree, MCP `get_page` returns its metadata), use the fallback before marking it as not found.

### Heading-Only Annotation

Not every local `.md` file in a raw export corresponds to a Wolai subpage (`type: "page"` block). Some correspond to `text` or `heading` blocks within the parent page. This often happens for "appendix" or "reference" content that users created as inline headings with bookmarks, not as sub-pages.

**How to detect:** After calling `get_page_blocks(parent_id)`, scan each child's `"type"` field. If no child with that local path's title has `"type": "page"`, it's heading-only.

**How to annotate:** Change the mapping entry status to `⚠️ heading only (not a Wolai subpage)` — keep the page ID as `—` since there's no subpage to link to.

**Real-world examples from database-export:** Elasticsearch has 4 heading-only entries: 应用, 运维, REST APIs, and Tools. All exist as `.md` files in `elasticsearch/` subdirectories but none are `type: "page"` blocks in the MCP response — they're content sections within the Elasticsearch page.

### Parallel Crawl with delegate_task

For large multi-export crawls, the most time-efficient approach is to delegate each export to a separate subagent:

```
delegate_task(tasks=[
  {"goal": "Crawl export A...", "toolsets": ["terminal", "file", "skills"]},
  {"goal": "Crawl export B...", "toolsets": ["terminal", "file", "skills"]},
  {"goal": "Crawl export C...", "toolsets": ["terminal", "file", "skills"]},
])
```

**Why:** Each subagent gets its own isolated MCP session and context window. 3 exports crawl in parallel, finishing in ~2 min wall-clock vs. ~6 min sequentially. The subagent handles its own MCP calls, discovers page IDs, and patches its own mapping file — returning only a summary. This avoids polluting the parent's context with intermediate MCP responses.

**When to use:** When you have 3+ exports ready for deep crawl and each has independent pages (no cross-export dependencies). The subagent needs MCP access, so `toolsets` must include the MCP tools (they're inherited by default — only set `toolsets` if you need to restrict).

**Trade-off:** Each subagent consumes its own input/output token budget independently. Total token cost may be similar to sequential, but wall-clock time is 3× faster and the parent context stays clean.

### Per-Export Mapping File

Write results to `raw/tasks/mapping/<export>.md` with this structure:

```markdown
# MCP ↔ Local Mapping: <Export Name>

**Wolai page:** [Title](https://www.wolai.com/ROOT_PAGE_ID)
**Export dir:** `raw/<export-dir>/`
**Total local files:** <N>
**Total unique MCP pages:** <N>
**Max depth:** <N>
**MCP calls:** <N>

## Full Page Tree

```
Root (PAGE_ID)     ← root.md
├── Subpage (ID1)   ← subpage/subpage.md     [leaf]
├── Subpage 2 (ID2) ← subpage2/subpage2.md   [has subpages]
│   └── Child (ID3) ← subpage2/child/child.md [leaf]
```

## Mapping Table

| # | Page ID | Title | Local Path | Depth | Status | Subpage IDs |
|---|---------|-------|-----------|-------|--------|-------------|
| 1 | `PAGE_ID` | Title | `path/file.md` | 0 | ✅ leaf | — |
| 2 | `PAGE_ID` | Title | `path/file.md` | 1 | ✅ has subpages | `CHILD_ID` (Child Title), `CHILD_ID2` (Child Title 2) |
| 3 | `—` | Missing ID | `path/file.md` | 2 | ⚠️ need block ID | — |

The **Subpage IDs** column is populated after calling `get_page_blocks` for each parent and filtering `children.ids` for blocks where `"type": "page"`. See the procedure below.

When a page is marked "has subpages" but `get_page_blocks` returns no `type: "page"` children, note this explicitly: `(no direct page children — content is bookmarks/headings)`. This distinguishes "colloquially has subpages" (the page has nested content) from "MCP has subpages" (has actual sub-page blocks to crawl).

## Stats

| Metric | Value |
|--------|-------|
| Leaf pages | <N> |
| Pages with subpages | <N> |
| Missing block IDs | <N> |
| **L1 subpages discovered** | <N> (across <M> L1 pages with subpages) |
| **Pages with direct subpages** | <X>/<Y> (<notes about exceptions>) |

## Quirks & Notes

- List any title→path anomalies, duplicate artifacts, or edge cases found.
- Document any pages that exist locally but couldn't be matched to an MCP block.


## Limitations

1. **Information loss in export**: bi_links lose their orientation direction (embedded/unlinked), some block metadata is dropped
2. **Duplicate files**: The export creates `parent/parent/parent.md` artifacts — always prefer the shallowest path
3. **Heading-only pages**: Pages that consist only of links/bookmarks are exported as TOC-only markdown with no prose
4. **Chinese normalization**: Chinese characters are preserved as-is but must not be further normalized when matching
5. **MCP API cost**: Full crawl of 18 root pages × ~100 subpages ≈ 1,800 API calls (~30-60 min)

## Mapping File Formats (for Change Detection)

The 14 mapping files under `raw/tasks/mapping/*.md` use 4 distinct formats that the snapshot builder must parse:

### Format A: Standard Table (6 columns)

Used by: database-export, AI, big-data, web, miscellaneous, algorithms

```
| # | Page ID | Title | Local Path | Depth | Status |
|---|---------|-------|-----------|-------|--------|
| 1 | `id...` | Title | `path/file.md` | 0 | ✅ |
| 2 | — | Missing | `path/file.md` | 1 | ⚠️ need block ID |
```

### Format B: Extended Table (7 columns + Subpage IDs)

Used by: distributed-systems-export. Subpage IDs column is pipe-index-7.

```
| # | Page ID | Title | Path | Depth | Status | Subpage IDs |
|---|---------|-------|------|-------|--------|-------------|
| 2 | `id` | API | `path` | 1 | ✅ | `cId` (Title), ... |
```

### Format C: Bracket Tree

Used by: cloud-computing, network, OS, programming-languages

```
Title [page_id] ★ (N items, M subpages)
├── Child [child_id] (K children)
```

### Format D: Parenthetical Tree

Used by: compilers-linkers, web-export

```
Title (page_id) ← path.md
├── Child (child_id) ← child/child.md   [leaf]
```

### Parsing Strategy

Try A → C → D, then catch-all (any backtick/paren/bracket-wrapped IDs). The catch-all ensures pages in non-standard positions (e.g., per-heading mini-tables in thoughts-export) aren't missed.

## Verification

After building a mapping, verify by spot-checking:
1. Pick 3 random pages from the map
2. Call `mcp_wolai_get_page(page_id)` to get the title from MCP
3. Read `local_path` and check that `# Title` matches the MCP title
4. Verify that `edited_at` (MCP) vs file `mtime` shows the expected drift

## Diff-Based Re-Sync (After Wolai Edit)

When the user says "I've updated/upgraded page X, re-map it", do NOT re-crawl the entire page tree. Use a diff-based approach:

### Procedure

1. **Load the existing mapping** from `raw/tasks/mapping/<export>.md`
2. **Get the root page's current blocks** via `mcp_wolai_get_page_blocks(root_page_id)`
3. **Extract `edited_at` timestamps** for the root and every child page block
4. **Compare against the mapping file's generation timestamp** (the "Generated:" line in the mapping file)
5. **Build a change set** — only pages where `edited_at > mapping_generated_at` need attention:

   ```
   # For each page block with newer edited_at:
   - Type: "page" with new children → re-crawl this subtree
   - Type: "heading" with changed title → update the string in the local file
   - Type: "page" but same children count/IDs → no action needed
   ```

6. **For heading-only changes** (like the "Difference Languages" → "Different Languages" fix), update the single heading line in the root markdown file. No MCP calls needed beyond the initial root page blocks.
7. **For structural changes** (added/removed subpages), re-crawl only the affected subtree (1-2 MCP calls), then update the mapping file's tree diagram and local file count.

### Example

From this session: user upgraded "Programming Languages" page on wolai. Diff found exactly one change:
- Heading block `eJJAFxKEo2y9mHQ2qY2txD`: title changed from "Difference Languages" → "Different Languages"
- All 13 language subpages: unchanged (same `edited_at`, same version, same children)
- All 6 inline heading sections: unchanged

**Action taken:** Updated 2 lines in `programming-lanuages.md` (TOC entry + heading). No MCP calls beyond the initial root block fetch. No updates to mapping file tree structure. This is 10× faster than a full re-crawl.

### When to Re-Crawl vs. Patch Only

| Change Type | Action |
|---|---|
| Heading title only | Patch the string in the local markdown file |
| Page title changed | Update both the directory name and the mapping file |
| Subpage added | Re-crawl that single parent subtree; add to tree diagram |
| Subpage deleted | Remove from tree diagram; file still exists but mark deleted |
| Content inside a page | No mapping change; export would need re-export |
| Version bump, no structural change | Note in mapping file, no action needed |

## Cache Cleanup

Intermediate `_mapping_cache/<export>.json` files are **session-resume artifacts** — they allow a multi-turn BFS crawl to survive context window compaction. Once all exports in a batch are fully mapped and `.md` mapping files are written, these JSON caches should be **deleted**:

```bash
rm -rf /path/to/wiki/_mapping_cache/
```

Do NOT commit cache files to the wiki repo. The canonical mapping data lives only in `raw/tasks/mapping/*.md`.

Similarly, any stray `_mapping_*.json` files at the wiki root (created before the `_mapping_cache/` directory convention was adopted) should be cleaned up.

## Pitfalls

1. **Scope drift: mapping == raw/MCP correspondence only.** Mapping finds the MCP page_id for each local file in `raw/*-export/` and records it. That is the entire task. Do NOT:
   - Discuss whether the content should be ingested into the wiki
   - Compare against existing wiki pages in `comparisons/`, `concepts/`, etc.
   - Talk about "gaps" in the wiki that could be filled
   - Analyze the content for quality or completeness
   
   The raw exports are frozen snapshots of wolai — their only relationship to the wiki is that some may have been ingested earlier. The mapping task is purely about `raw/*-export/` ↔ MCP correspondence. Any mention of wiki pages is a scope error the user will correct.

2. **User preference: no parallel bursts.** Never call more than 2 MCP `get_page_blocks` simultaneously. The user explicitly prefers conservative rate limiting. One-at-a-time per turn is safest.

3. **Long sessions lose context.** For exports with 100+ unique pages (database-export, thoughts-export, and above), the crawl spans multiple conversation context windows. Save `_mapping_cache/<export>.json` every 10-15 calls with a `last_crawled` timestamp. The next session loads this cache and resumes from where it left off.

4. **Many MCP children are NOT subpages.** A page with 14 "children" may have only 2-3 that are `type: "page"` (actual subpages). The rest are headings, bookmarks, text blocks, and bi_links. Scan each child's `"type"` field — only `"page"` warrants deeper crawling.

5. **L1-L2 files may be outdated.** The initial mapping files (`raw/tasks/mapping/*.md`) may list subpages that no longer exist, or miss subpages that were added later in wollai. Always verify L1 page blocks against current MCP data rather than blindly trusting old maps. Fix any stale entries.

6. **"has subpages" in status does not guarantee type:page children.** A page colloquially "has subpages" (deeper content) but the root block's `children.ids` may contain only `heading`, `bookmark`, `text`, and `bi_link` blocks — no `type: "page"` blocks at all. Real-world examples from the distributed-systems-export: **分布式事务** and **分布式锁** were both marked "has subpages" but had zero direct page children. Their deeper content lives under headings, not as sub-page blocks.

   **What to do:** After calling `get_page_blocks(parent_id)`, scan each child's `"type"` field. If none are `"page"`, the parent is effectively a leaf for crawl purposes. Note this in the mapping table: `(no direct page children — content is bookmarks/headings)`.

   Exception: Subpages may exist deeper — nested under headings rather than as direct children of the root page block. Example from distributed-systems-export: **分布式锁** has `MultiLock` and `NestedLock` as type:page children of heading blocks within the root, not direct children. These are reachable via BFS recursion through headings, not at depth-1.

## Change Detection Pipeline

After the baseline mapping is complete, use `references/change-detection.md` and `detect-changes.py` to detect Wolai edits:

1. **Build snapshot** — `python3 detect-changes.py --build-snapshot` extracts all page IDs from mapping files (zero MCP calls)
2. **Scan** — agent iterates pages, calls `mcp_wolai_get_page_blocks`, extracts `edited_at` from root block
3. **Detect** — compares `edited_at` against snapshot to find EDITED/NEW/DELETED pages
4. **Preview** — formatted table per export
5. **Execute** — on confirm: sync `.md` content + re-ingest into wiki

Two-tier scanning: `--quick` (L1s only, ~200 calls) or `--full` (all pages, ~683 calls). Batch size 4 tested successfully.

See `references/change-detection.md` for the full architecture and `detect-changes.py` in `raw/tasks/mapping/`.

## Related

- `wiki-reingest` — Add ingested frontmatter to exported pages
- `wiki-git-pull-push` — Git workflow for multi-machine wiki sync
- `wiki-content-audit` — Survey exports for content types and gaps
- `native-mcp` — MCP client: connect servers, register tools (stdio/HTTP)
- `wolai-export-mapping` — Overlaps with this skill (both cover MCP↔local mapping). Consider consolidation.
