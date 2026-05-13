# Export Audit Checklist

Use when auditing a `raw/<export-name>/` directory against existing wiki pages.

## Scan

```bash
# List all raw .md files (excluding asset dirs)
find raw/<export-name> -name '*.md' ! -path '*/file/*' ! -path '*/image/*' | sort

# List existing concepts and entities
find concepts/ entities/ -name '*.md' | sort
```

## Classification

For each raw file, determine:

1. **Already ingested** — existing wiki page covers it. Check:
   - Batch ingest logs in `log.md` (most happened 2026-05-10)
   - Direct page match in `concepts/` or `entities/`
   - Parent topic condensed into a single summary page

2. **Index/overview** — top-level index (e.g., `protocols/protocols.md`). No page needed.

3. **Nested duplicate** — wolai.app nests identical content under `topic/topic/topic.md`. Skip.

4. **Missing** — needs a new or enhanced wiki page.

## Priority Levels

| Priority | Criteria |
|----------|----------|
| **High** | Core protocols, major tools, topics with extensive raw content (10+ files) |
| **Medium** | Important but narrower tools or concepts |
| **Low** | Minor tools, single-article topics, personal notes |

## Report Template

Save to `raw/tasks/ingest/missing-page_<export-name>.md`:

```markdown
# Ingest Audit: raw/<export-name>

> Generated: YYYY-MM-DD
> Source: `raw/<export-name>/` (N .md files)
> Purpose: Full cross-reference audit.

## Summary

| Status | Count |
|--------|-------|
| Already ingested | N |
| Index/overview | N |
| Truly missing | N |

## ✅ Already Ingested

...

## ❌ Truly Missing

| # | Raw source | Suggested wiki page | Priority |
...
```

## Previously Audited Exports

| Export | Status | Notes |
|--------|--------|-------|
| artificial-intelligence | 95% ingested | Batch-ingested |
| programming-languages | 95% ingested | Batch-ingested |
| cloud-computing | 90% ingested | Batch-ingested; CNI plugins missing |
| network | 94% ingested | Batch-ingested |
| operating-system | ~50% ingested | Kernel sub-topics + CLI tools missing |
| tools | ~2% ingested | **Largest gap — not batch-ingested** |
| algorithms-data-structures | 95% ingested | Batch-ingested |
| big-data-data-science | 85% ingested | Entity pages for niche tools missing |
| compilers-linkers | 100% ingested | Fully ingested |
| database | ~60% ingested | Oracle + niche DBs missing |
| distributed-systems | ~40% ingested | Nginx, Prometheus, SSO, MQ tools missing |
| miscellaneous | 80% ingested | Batch-ingested |
| thoughts | 85% ingested | Batch-ingested |
| web | 100% ingested | Fully ingested |
