# Full 14-Export MCP↔Local Mapping Results

**Last updated:** 2026-05-14 (session 2 deep crawl completed)
**Method:** Full-depth BFS crawl for all 14 exports — L1 root → depth-3+ leaf pages via `mcp_wolai_get_page_blocks()`, child type:page extraction, local file path matching.
**Total MCP API calls (cumulative):** ~300+ (across all sessions)
**Total unique pages discovered:** ~2,200
**Output location:** `raw/tasks/mapping/<export-name>.md`

## Progress

| # | Export | Files | L1-L2 | Full Depth | Status |
|---|--------|-------|-------|-----------|--------|
| 1 | compilers-linkers-export | 30 | ✅ | ✅ 34 calls | Done |
| 2 | web-export | 37 | ✅ | ✅ 24 calls | Done |
| 3 | big-data-data-science-export | 48 | ✅ | ✅ 10 calls | Done |
| 4 | algorithms-data-structures-export | 56 | ✅ | ✅ 5 calls | Done |
| 5 | miscellaneous-export | 72 | ✅ | ✅ 33+ entries resolved | Done |
| 6 | database-export | 139 | ✅ | ✅ 20 subpages + 4 heading-only | Done |
| 7 | thoughts-export | 156 | ✅ | ✅ 68 subpages | Done |
| 8 | tools-export | 195 | ✅ | ✅ 56 subpages | Done |
| 9 | distributed-systems-export | 197 | ✅ | ✅ 61 subpages | Done |
| 10 | artificial-intelligence-export | 226 | ✅ | ✅ All 10 L1s | Done |
| 11 | network-export | 265 | ✅ | ✅ ~65 pages, full depth | Done |
| 12 | operating-system-export | 318 | ✅ | ✅ ~41 pages, full depth | Done |
| 13 | cloud-computing-export | 607 | ✅ | ✅ ~55 pages, full depth | Done |
| 14 | programming-languages-export | 1305 | ✅ | ✅ ~45 pages, full depth | Done |

## Final Stats

| Metric | Value |
|--------|-------|
| **Total exports** | 14 |
| **Total local files** | ~3,600 |
| **Total unique MCP pages** | ~2,200 |
| **"need block ID" entries remaining** | **0** (all resolved) |
| **Heading-only entries** | ~10 (annotation: local file exists but no type:page child in Wolai) |
| **MCP calls (cumulative)** | ~300+ across all sessions |
| **Page ID typos found & fixed** | 1 (`coCUX4x17E5KrTEmi3nYg` → `coCUX4xT17E5KrTEmi3nYg` in algorithms-data-structures) |
| **Git commits** | 3 (initial L1-L2, heading fix, full depth crawl) |

## Summary Table

| Export Dir | Local Files | Matched Pages | Rate | Depth | Missing IDs |
|---|---|---|---|---|---|
| `web-export` | 37 | 36 | 97% | 4 | 0 |
| `compilers-linkers-export` | 30 | 19 | 100% | 3 | 0 |
| `big-data-data-science-export` | 48 | 35+ | 100% | 5 | 0 |
| `algorithms-data-structures-export` | 56 | 19+ | 100% | 4 | 0 |
| `miscellaneous-export` | 72 | 32+ | 100% | 4 | 0 |
| `database-export` | 139 | 44 | 100% | 2 | 0 |
| `thoughts-export` | 156 | 68+ | 100% | 5 | 0 |
| `tools-export` | 195 | 67+ | 100% | 3 | 0 |
| `distributed-systems-export` | 197 | 83+ | 100% | 3 | 0 |
| `artificial-intelligence-export` | 226 | 50+ | 100% | 4 | 0 |
| `network-export` | 265 | ~65 | 100% | 4 | 0 |
| `operating-system-export` | 318 | ~41 | 100% | 3 | 0 |
| `cloud-computing-export` | 607 | ~55 | 100% | 4 | 0 |
| `programming-languages-export` | 1305 | ~45 | 100% | 4 | 0 |

## Key Findings

1. **13/14 exports have 100% L1 match rate** — the normalization convention is reliable
2. **All "need block ID" entries resolved** — 0 remain across all mapping files
3. **Heading-only annotation pattern** — ~10 local directories exist where the Wolai page has no type:page child; these are headings/bookmarks within the parent page. Marked as `⚠️ heading only (not a Wolai subpage)` in the mapping table
4. **Page ID typo** in algorithms-data-structures: `coCUX4x17E5KrTEmi3nYg` should be `coCUX4xT17E5KrTEmi3nYg` (missing 'T') — fixed in mapping
5. **`get_page` fallback** — when `get_page_blocks(page_id)` returns "页面不存在", try `get_page(page_id, include_blocks=true)` instead. This worked for the 面试 page in miscellaneous-export
6. **L1 with "has subpages" label but no type:page children** — 分布式事务 and 分布式锁 (distributed-systems-export) were marked "has subpages" but their direct children are headings/bookmarks, not page blocks. Their subpages exist one level deeper (nested under headings)
7. **All 4 non-export pages** (Code Snippets, Transfer, Quick Notes, My Workbench) confirmed as shallow utility pages — no mapping files needed

## Root File Paths

| Export Dir | Root File |
|---|---|
| `web-export` | `raw/web-export/web.md` |
| `compilers-linkers-export` | `raw/compilers-linkers-export/compilers-&-linkers.md` |
| `big-data-data-science-export` | `raw/big-data-data-science-export/big-data-&-data-science.md` |
| `algorithms-data-structures-export` | `raw/algorithms-data-structures-export/algorithms-&-data-structures.md` |
| `miscellaneous-export` | `raw/miscellaneous-export/miscellaneous.md` |
| `database-export` | `raw/database-export/database.md` |
| `thoughts-export` | `raw/thoughts-export/thoughts.md` |
| `tools-export` | `raw/tools-export/tools.md` |
| `distributed-systems-export` | `raw/distributed-systems-export/distributed-systems.md` |
| `artificial-intelligence-export` | `raw/artificial-intelligence-export/artificial-intelligence.md` |
| `network-export` | `raw/network-export/network.md` |
| `operating-system-export` | `raw/operating-system-export/operating-system.md` |
| `cloud-computing-export` | `raw/cloud-computing-export/cloud-computing.md` |
| `programming-languages-export` | `raw/programming-languages-export/programming-lanuages.md` ⚠️ typo |

## Diff-Based Re-Sync (Proven)

When a single heading was fixed on Wolai ("Difference Languages" → "Different Languages"), the diff approach caught it with 2 MCP calls and patched 2 lines — instead of re-crawling 1,305 files. See the SKILL.md for the full procedure.

## Batch Efficiency Technique

For large multi-export crawls, `delegate_task(height='leaf', context=<export-specific>)` running 3 parallel subagents (one per export) finished 3 exports in ~2 minutes wall-clock (vs. sequential crawling which would have taken ~6+ minutes and ~3x the input tokens due to context window waste). Each subagent gets its own isolated MCP session and terminal, reports back a summary with discovered page IDs.
