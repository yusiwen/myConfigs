# Bulk Comparison Ingest — 2026-05-14 (Second Sweep + Extraction)

## What Happened

After the initial 35 comparison pages were created, the user asked to "find any potential comparisons furthermore." A deeper multi-pass search using Chinese comparison phrases discovered 13 more comparison topics. Additionally, 3 existing wiki concept pages had embedded comparison sections that were extracted into standalone pages.

## New Search Techniques (not in first sweep)

### Chinese Comparison Phrases
Instead of just "vs" and "comparison", searched for:
- `与.*相比` — "compared with"
- `的区别` — "difference between"
- `优缺点` — "pros and cons"
- `选型` — "selection/evaluation"
- `哪个好` — "which is better"
- `对比分析` / `选择` — "comparison analysis" / "choose"
- `替代方案` — "alternative plan"

These caught documents about database selection (MySQL vs PostgreSQL), message queue selection (Kafka vs RocketMQ), config center comparison, and APM tool comparison that English-only searches missed.

### TOC-Based Verification
Instead of just reading the first few lines, extracted the Table of Contents (## 目录) of each candidate and scanned for comparison indicators throughout the body. This caught comparisons buried deep in documents.

### External Link Indicators
Some raw files are link collections — the author bookmarked comparison articles (e.g., "配置中心/配置中心.md" with "统一配置中心选型对比" link). These don't have inline comparison content but are clearly comparison references. Created pages synthesizing the comparison content from knowledge.

## Extraction Pattern: Embedded → Standalone

Three existing concept pages had comparison sections that were extracted:

| Source File | Section Extracted | New Comparison Page |
|---|---|---|
| `concepts/database/database-overview.md` | `## RDBMS vs NoSQL` | `comparisons/databases/rdbms-vs-nosql.md` |
| `concepts/ai-ml/llm-inference-mechanics.md` | `## Prefill vs Decode Inference Phases` | `comparisons/ai-ml/prefill-vs-decode.md` |
| `concepts/algorithms/sorting-algorithms.md` | `## Comparison vs. Non-Comparison Sorting` | `comparisons/algorithms/comparison-vs-noncomparison-sorting.md` |

### Modification to Originals

Each original concept page had its comparison section replaced with:
```markdown
## RDBMS vs NoSQL

See the dedicated comparison page: [[comparisons/databases/rdbms-vs-nosql|RDBMS vs NoSQL]].
```

This preserves the navigation flow (user still sees the heading at the same place) while redirecting to the richer standalone page.

## Pitfalls (Session 2)

### The read_file display-trap
When `read_file` outputs `LINE_NUM|CONTENT`, the `|` is a display separator, not actual file content. Patching log.md with `old_string` containing `|` adds literal pipe characters to the file. Always re-read the patched section to verify format integrity.

### External-link-only pages
Some raw "comparison" files are just link dumps (e.g., a page with a single URL to "MySQL与PostgreSQL相比哪个更好"). For these, write actual comparison content from your knowledge, using the URL as a `sources:` reference. Don't dump URLs into the page body.
