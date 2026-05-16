---
name: wiki-article-ingestion
description: "Create wiki pages from external content — two entry paths: article-driven (raw/articles/ files) and research-driven (web research + synthesis). Covers: placement, frontmatter, concept page structure, research depth, source tracking, cross-links, index/log updates, and handoff to sync-export-to-wolai."
version: 1.0.0
author: Hermes Agent
---

# Wiki Article Ingestion & Concept Page Creation

## When This Skill Activates

This skill activates when the user asks you to integrate new external content into the wiki. It covers **two entry paths**:

1. **Article-driven** — a file in `raw/articles/` (from Google AI Mode, Claude, Perplexity, web research, etc.) needs to be absorbed into wiki pages
2. **Research-driven** — the user asks for a wiki page on a topic with no source file; you research online, synthesize, and create the page from scratch

Both paths converge at the same downstream steps (frontmatter, cross-links, log, git cycle).

For syncing changes BACK to Wolai on already-exported pages, see `sync-export-to-wolai`.

## Workflow

### Step 1: Identify the Source

**Article-driven path (file exists):**
```bash
read_file(path="raw/articles/<filename>.md")
```

**Research-driven path (no file — web research needed):**
Use `web_search` + `web_extract` (or `browser` tools) to gather comprehensive information. Then check the wiki for existing coverage:

```bash
search_files("<topic>", path="$WIKI", target="files")
search_files("<topic>", path="$WIKI", target="content")
```

### Step 2: Determine Wiki Placement

| Content scope | Wiki target | Example |
|---------------|-------------|---------|
| Specific tool/product details | Entity page under `entities/tools/<category>/<name>.md` | GaussDB distributed replication → `entities/tools/database-engines/gaussdb.md` |
| General concept explanation | Concept page under `concepts/<domain>/<concept>.md` | CAP theorem → `concepts/distributed-systems/cap-theorem.md` |
| Side-by-side comparison | Comparison page under `comparisons/<domain>/<name>.md` | MySQL vs PostgreSQL → `comparisons/databases/mysql-vs-postgresql.md` |
| Broad topic spanning multiple pages | Create entity page + update overview concept page | GaussDB → new entity page + add to NewSQL table in distributed-database-systems.md |

**Decision rules:**
- If the content describes a specific product's internals → entity page (tools/database-engines/)
- If the content explains a general principle → concept page
- If the content describes a relationship between products/tools → entity updates + overview updates

### Step 3: Synthesize and Write the Wiki Page

**For concept pages** (the most common research-driven outcome):

Structure the page with these sections (adapt as needed):

| Section | Purpose |
|---------|---------|
| **Intro** | One-paragraph definition with the key insight — what is it, why does it matter |
| **Architecture** | Visual/ASCII diagram showing how components connect, with clear explanation |
| **Detailed breakdown** | Sub-components, variants, design trade-offs with comparison tables |
| **Training / How it works** | For ML models: loss functions, training strategies, negative sampling |
| **Classification** | Tables grouping models by domain, capability, or era |
| **Applications** | Real-world use cases with concrete examples |
| **Strengths & Limitations** | Bullet lists — what it's good at and where it falls short |
| **Code Example** | Working Python/other code the reader can run |
| **Historical Context** | Timeline or evolution table connecting milestones |
| **Related Pages** | `[[wikilinks]]` to existing wiki pages (minimum 3) |

**Research depth guidelines:**
- Make 5-10 `web_search` calls covering different angles (architecture, training, comparison, applications, history)
- Extract at least 3 authoritative sources for factual claims
- Comparison tables should have 6+ rows and be verifiable
- Code examples should be runnable with real libraries (not pseudocode)

**For article-driven path only — Step 4: Determine If a Raw Export Corresponds**

Search for a matching raw export under `raw/<export-name>/`. If one exists:
- It is the source-of-truth snapshot for Wolai sync
- Update it with the new content (matching the entity/concept page's structure)
- The raw export acts as the bridge between wiki page content and Wolai

If no raw export exists, the article stands alone under `raw/articles/` and no Wolai sync is needed.

### Step 5: Sync to Wolai (If Raw Export Exists)

Load and follow `sync-export-to-wolai` skill for the Wolai update:
- Find the Wolai page ID (via mapping file or search)
- Update the Wolai page via MCP to mirror the raw export content
- Check mapping file for needed updates

### Step 6: Update Index and Log

```bash
# Update index.md
# - Add entity/concept page entry under the correct section
# - Bump the total page count

# Update log.md (append-only)
# - Format: ## [YYYY-MM-DD] <action> | <subject>
# - List all created and updated files
```

### Step 7: Git Commit and Push

```bash
cd $WIKI
git add -A
git commit -m "feat: ingest <article-topic> from raw/articles into wiki"
# push with 3 retries
for i in 1 2 3; do
  if git push origin master 2>&1; then echo "PUSH SUCCEEDED"; break; fi
  sleep 2
  git pull --rebase origin master 2>&1 || break
done
```

## Data Flow

All ingestion follows a consistent pipeline, regardless of entry path:

```
[Article-driven]  raw/articles/<article>.md ──┐
[Research-driven] web research ──────────────┤
                                               ▼
                              (create/update) entities/ or concepts/ page
                                                  │
                                                  ▼
                              (update) raw/<export-name>/.../<page>.md
                                       └── if raw export exists
                                                  │
                                                  ▼
                              (sync) Wolai page via MCP
                                       └── delegates to sync-export-to-wolai
                                                  │
                                                  ▼
                              (verify) mapping file
                                       └── check if mapping needs updating
                                                  │
                                                  ▼
                              (record) index.md + log.md
                                                  │
                                                  ▼
                              (persist) git commit + push
```

## Pitfalls

- **Article may be misnamed** — when the filename doesn't match content (e.g., `llm-inference-google-ai-mode-qa5.md` about GaussDB), rename it with `google-ai-mode_` prefix + descriptive suffix before ingestion
- **Not every article needs Wolai sync** — only if a corresponding raw export exists. Standalone `raw/articles/` files are wiki-internal only
- **gif/emoji placeholders** in Google AI Mode exports — skip or clean up; they are formatting artifacts from the AI UI
- **Citation markers like [系统 1], [系统 2]** — AI-generated indexing artifacts; clean them up or integrate the info naturally
- **Mapping check is always required** — even when just updating content, verify no structural change occurred that would invalidate the existing mapping
- **`patch` tool pipe-prefix gotcha** — the `patch` tool output shows `LINE_NUM|CONTENT` with a pipe separator, but the actual file content does NOT have pipes. When crafting a replacement in `old_string`, make sure you haven't accidentally captured the display-format `|` prefix. This bit me when updating `log.md`: the `old_string` I grabbed from `read_file` output included leading `|` on some lines, producing corrupted output. **Always copy `old_string` from the actual file (confirmed by reading a second time) rather than from the first `read_file` output, which may show the display-format pipes.**
