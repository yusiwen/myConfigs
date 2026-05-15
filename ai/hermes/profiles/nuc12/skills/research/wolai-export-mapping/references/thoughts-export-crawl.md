# Thoughts Export — Deep-Crawl Results (2026-05-14)

## Context

The `thoughts-export.md` mapping had 13 L1 pages with 5 prior MCP calls. 4 L1 pages had "has subpages" status but zero block IDs listed. 1 L1 (System Designing) had a prose-only description. This file documents the deep-crawl technique and results.

## L1 Pages Crawled

| L1 Page | ID | Subpages Found | Prior Status |
|---------|-----|---------------|--------------|
| Design Patterns | `gbDqasMG1PqgT4ka1zCfEH` | 8 | "has subpages" — no IDs |
| Mathematics | `nvhcBbFKNv2fR4Yvy6GUic` | 7 | "has subpages" — no IDs |
| Scaffold Projects & Frameworks | `abTikFpzYu66vokhD8HPEX` | 2 | "has subpages" — no IDs |
| 中台 | `kS22wpdfLAmS7XFnWVaRkB` | 3 | "has subpages" — no IDs |
| System Designing | `mfCt88GjWN8gWfARif2FDH` | 41 | prose-only list of titles |

**Total:** 61 new structured entries from 5 MCP calls (4 deep-crawl + 1 System Designing).

## Subpage ID Counts by L1

- Security: 7 (already listed)
- Design Patterns: 8
- Mathematics: 7
- Scaffold Projects: 2
- 中台: 3
- System Designing: 41 (under "System Designs" heading)
- **Total confirmed:** 68

## System Designing — "System Designs" Heading Structure

System Designing's content is organized under headings. The "System Designs" heading (`oiNhTQfuqNPoESYHjpWwtD`) contains 42 child blocks, 41 of which are `type: "page"`. The one non-page is a "Household Management" heading. The subpages span diverse system design topics from High Concurrency Systems to Captcha.

## Local Path Matching Observations

The export tool produces filenames matching the pattern:

```
raw/thoughts-export/<L1-slug>/<subpage-folder>/<subpage-folder>.md
```

Where `<subpage-folder>` is derived from the Wolai page title via:
- Lowercasing ASCII text (keep Chinese case)
- Spaces → hyphens
- ` / ` (space-slash-space) → `---`
- ` & ` → `-&-`
- Parentheses kept verbatim

All 68 confirmed MCP page IDs had matching local `.md` files, confirming no drifts found in this subtree.
