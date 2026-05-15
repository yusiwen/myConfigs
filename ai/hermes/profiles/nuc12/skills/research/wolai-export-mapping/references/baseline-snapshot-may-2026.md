# Baseline Snapshot: May 14, 2026

Built from all 14 mapping files. Zero MCP calls — extracted page IDs from mapping file text.

## Totals

| Metric | Value |
|--------|-------|
| **Unique pages** | 683 |
| **Mapping files** | 14 |
| **Exports with page IDs** | 14/14 |
| **All edited_at** | `null` (first build — populated on first MCP scan) |

## Per-Export Breakdown

| Export | Pages | Format |
|--------|-------|--------|
| algorithms-data-structures | 34 | table + catch-all |
| artificial-intelligence | 39 | table + bracket tree + catch-all |
| big-data-data-science | 48 | table |
| cloud-computing | 33 | bracket tree |
| compilers-linkers | 28 | tree + catch-all |
| database | 49 | table |
| distributed-systems | 79 | table (extended, with subpage col) |
| miscellaneous | 68 | table + catch-all |
| network | 71 | bracket tree |
| operating-system | 32 | bracket tree |
| programming-languages | 16 | bracket tree + catch-all |
| thoughts | 81 | table + catch-all (68 from mini-tables) |
| tools | 68 | table + catch-all (56 from subpage tables) |
| web | 37 | table |

## Detection Cost Estimates

| Mode | Pages to scan | Parallel batches | Est. wall time |
|------|--------------|-----------------|----------------|
| `--quick` (first run) | 683 | 342 | ~17 min |
| `--full` (first run) | 683 | 342 | ~17 min |
| `--quick` (subsequent) | ~200 L1s | 100 | ~5 min |
| `--full` (subsequent) | 683 | 342 | ~17 min |

After first run, `edited_at` values are populated. Quick mode only re-checks L1 pages (~200).
