# Comparison Audit Result — 2026-05-14 (Final Sweep)

## Context

The user asked for a "full swipe" of all raw exports for comparison content, believing only 2 sub-categories and 3 pages existed. After the first two bulk ingests (May 13 + May 14), the wiki already had **54 pages across 9 sub-categories**. This audit was to verify no dedicated comparison pages were missed.

## Method

This was the most thorough sweep executed across all 14 export directories (~3,600+ files):

1. **Pass 1: Filename patterns** — `*vs*`, `*对比*`, `*comparison*`, `*选择*` across all raw exports, excluding images and attachments
2. **Pass 2: H1 heading content** — `rg -n '^# .+ (vs|VS|versus|对比|比较) .+'` across all .md files
3. **Pass 3: Chinese body-content phrases** — `rg -n '与.*相[比比]|的区别|优缺点|选型|对比分析|替代方案'` 
4. **Pass 4: Section heading patterns** — `^##.*选型|^##.*方案对比|^##.*优缺点`
5. **Pass 5: Deep verification** — For each candidate, read actual content, checked TOC structure, scanned for comparison indicators

## Result

**No un-ingested dedicated comparison pages found.** All comparison content where the entire page was about comparing two+ things was already ingested into `comparisons/` in the two prior bulk operations.

## Remaining: 7 Embedded Comparison Sections

These are sections within larger concept/tool pages that contain comparison content but are not standalone comparison pages:

| # | Raw file | Export | Embedded Heading | Topic | Extract-worthy? |
|---|----------|--------|-------------------|-------|----------------|
| 1 | `operating-system-export/kernel/...kernel-threads.md` | OS | ## Kernel Thread vs User Threads | Full comparison table (~60 rows) | ✅ Good candidate |
| 2 | `programming-languages-export/java/frameworks/database/mybatis/fastmybatis.md` | PL | ## fastmybatis与MyBatis generator对比 | ORM tool comparison | ✅ Decent |
| 3 | `database-export/cassandra/cassandra.md` | DB | ## 选型比较 (Cassandra vs HBase vs MongoDB) | NoSQL db selection | ✅ Could extract |
| 4 | `algorithms-data-structures-export/other/other.md` | Algo | ## 集合比较 | Set difference algorithms | ⚠️ Small |
| 5 | `distributed-systems-export/分布式事务/seata/seata.md` | DS | ## 比较 (AT vs XA) | Distributed tx comparison | ✅ Decent |
| 6 | `programming-languages-export/.../yaml/yaml.md` | PL | ## Block-style vs Flow-style | YAML syntax | ⚠️ Minor |
| 7 | `operating-system-export/安全/linux-access-control-list-(acl).md` | OS | ## X vs x in recursive mode | ACL detail | ⚠️ Tiny |

## Key Learnings for Future Audits

- **Always check log.md first** — the user's perception of "what exists" may be days out of date if bulk ingests happened recently
- **Chinese natural-language queries catch what "vs" searches miss** — "选型" (selection) and "的区别" (difference) are the most productive single patterns
- **Tool name false positives**: OVS, LVS, IPVS, VSCode all contain "vs" but are NOT comparisons — filter these out early
- **After two bulk ingests, the "low-hanging fruit" is exhausted** — remaining content is embedded sections, not standalone pages
