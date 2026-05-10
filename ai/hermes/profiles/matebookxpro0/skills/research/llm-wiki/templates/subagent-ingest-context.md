# Subagent Ingest Context Template

Copy this block and fill in the `{{PLACEHOLDERS}}` when dispatching a
subagent to create wiki pages from a notebook export section.

## Context

```
WIKI_PATH=/home/yusiwen/git/mine/wiki. Read SCHEMA.md, index.md, log.md
first for conventions. Export section at
raw/{{EXPORT_NAME}}/{{SECTION_PATH}}/.

Key rules:
- Lowercase-hyphenated filenames for ALL new pages
- YAML frontmatter with title/created/updated/type/tags/sources
- Every page has [[wikilinks]] to 2+ other pages (cross-link within section
  and to existing pages in the wiki)
- Write in English even if raw source filenames are in Chinese
- Group related sub-topics into single well-structured pages — do NOT create
  a page per source file. Target 5-15 pages total per subagent, not 50.
- DO NOT edit index.md or log.md — return list of created files in summary.
  The parent will update index.md and log.md.
- Tags must come from SCHEMA.md taxonomy. Add new tags at your discretion
  but be conservative.

Existing wiki pages to be aware of:
{{LIST_KEY_EXISTING_PAGES}}
```

## Goal

Create wiki concept and entity pages from:
- `raw/{{EXPORT_NAME}}/{{SECTION_PATH}}/`
{{LIST_OF_SOURCE_FILES_TO_READ}}

Main topics to cover:
{{LIST_OF_TOPICS}}

Create concept pages under `concepts/{{DOMAIN}}/` and entity pages under
`entities/tools/`. Return in your summary a list of every file you created
so the parent can update index.md and log.md.
