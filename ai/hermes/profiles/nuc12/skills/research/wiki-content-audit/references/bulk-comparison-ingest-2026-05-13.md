# Bulk Comparison Ingest — 2026-05-13 (Worked Example)

## What Happened

The user's wiki had 3 comparison pages across 2 sub-categories. After an audit of all 14 raw export directories (~3,600+ files), 35 comparison topics were identified. The user said "add all 40" and all pages were created in one batch.

## Creation Stats

- **35 new wiki pages** across 8 sub-categories (ai-ml, networking, distributed-systems, kubernetes, databases, programming, devops, security)
- **8 new sub-category directories** (in addition to the existing 2)
- **index.md:** 35 new entries, page count 490 → 525
- **log.md:** single batch entry appended
- **Git:** 1 commit, 37 files changed, 1,427 insertions

## Pitfalls Encountered (actual)

### JSON in .format() strings causes KeyError

When creating a page containing a JSON code block:

```python
content = """---
...
```json
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text"
      }
    }
  }
}
```
""".format(today=today)
```

This raises `KeyError: '\n  "mappings"'` because `.format()` interprets `{` and `}` as placeholders.

**Fix:** Use string concatenation instead of `.format()` when page content contains curly braces:

```python
c22 = """---
title: My Page
created: """ + today + """
updated: """ + today + """
---

Content with { or } characters
"""
```

Or use `{{` and `}}` to escape braces in `.format()` strings.

### Pipe chars in log.md from patch operations

When patching log.md (or any append-only file), the patch can accidentally introduce `|` pipe characters at the start of lines. This happens because `read_file` outputs `LINE_NUM|CONTENT` format, and if you include the `|` in your `old_string`/`new_string`, it gets written into the file.

**Fix:** Always verify the actual file content (not the read_file display format) matches your old_string. The `|` prefix is a display artifact, not actual content.

### Missing the articles directory

The initial sweep focused on the 14 raw export directories but also needs to check `raw/articles/`. The articles directory contains curated external sources that may include comparison content.

## Content Patterns Used

Each comparison page followed this structure:
1. YAML frontmatter (title, created, updated, type, tags, sources)
2. H1 heading matching the comparison topic
3. Brief introduction
4. Comparison table (markdown table with columns for each subject)
5. Key differences or selection guide
6. Practical guidance section

## Domain Mapping

Audited findings were mapped to wiki sub-categories:

| Audit Domain | Wiki Sub-Category | Pages Created |
|---|---|---|
| AI/ML | comparisons/ai-ml/ | 4 |
| Networking | comparisons/networking/ | 5 |
| Distributed Systems | comparisons/distributed-systems/ | 5 |
| Kubernetes | comparisons/kubernetes/ | 3 |
| Databases | comparisons/databases/ | 5 |
| Programming | comparisons/programming/ | 7 |
| DevOps | comparisons/devops/ | 5 |
| Security | comparisons/security/ | 1 |
| (Web/SSE) | comparisons/devops/ | 1 |
