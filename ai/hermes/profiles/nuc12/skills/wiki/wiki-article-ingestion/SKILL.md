---
name: wiki-article-ingestion
description: "Ingest an external article from raw/articles/ into the wiki knowledge base — create/update entity pages, concept pages, sync to raw exports and Wolai. Covers: placement, frontmatter, source tracking, index updates, and handoff to sync-export-to-wolai."
version: 1.0.0
author: Hermes Agent
---

# Wiki Article Ingestion

## When This Skill Activates

This skill activates when the user asks you to integrate new external content into the wiki — typically a file in `raw/articles/` (from Google AI Mode, Claude, Perplexity, web research, etc.) that needs to be absorbed into the wiki's entity/concept pages, raw exports, and Wolai.

This is the **first step** of bringing external knowledge in. For syncing changes BACK to Wolai on already-exported pages, see `sync-export-to-wolai`.

## Workflow

### Step 1: Read and Understand the Article

```bash
read_file(path="raw/articles/<filename>.md")
```

Identify:
- **Core topic** — what concept, entity, or comparison does it cover?
- **Existing wiki coverage** — does an entity or concept page already exist? (search by keywords)
- **Taxonomy fit** — entity (`entities/tools/...`) or concept (`concepts/<domain>/...`)?

### Step 2: Determine Wiki Placement

| Article scope | Wiki target | Example |
|---------------|-------------|---------|
| Specific tool/product details | Entity page under `entities/tools/<category>/<name>.md` | GaussDB distributed replication → `entities/tools/database-engines/gaussdb.md` |
| General concept explanation | Concept page under `concepts/<domain>/<concept>.md` | CAP theorem → `concepts/distributed-systems/cap-theorem.md` |
| Side-by-side comparison | Comparison page under `comparisons/<domain>/<name>.md` | MySQL vs PostgreSQL → `comparisons/databases/mysql-vs-postgresql.md` |
| Broad topic spanning multiple pages | Create entity page + update overview concept page | GaussDB → new entity page + add to NewSQL table in distributed-database-systems.md |

**Decision rules:**
- If the article describes a specific product's internals → entity page (tools/database-engines/)
- If the article explains a general principle → concept page
- If the article describes a relationship between products/tools → entity updates + overview updates

### Step 3: Update the Wiki Page(s)

**For entity pages:**
- Add the article to `sources:` frontmatter: `raw/articles/<filename>.md`
- Add or expand the relevant section in the body
- Use `[[wikilinks]]` to connect to related pages (minimum 2 per page)
- Follow SCHEMA.md frontmatter conventions

**For concept pages:**
- Same frontmatter + wikilink conventions
- Add provenance markers where appropriate (`^[raw/articles/source.md]`)

### Step 4: Determine If a Raw Export Corresponds

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

All ingestion follows a consistent pipeline:

```
raw/articles/<article>.md
  → (create/update) entities/ or concepts/ page  ← frontmatter sources: entry
  → (update) raw/<export-name>/.../<page>.md     ← if raw export exists
  → (sync) Wolai page via MCP                    ← delegates to sync-export-to-wolai
  → (verify) mapping file                         ← check if mapping needs updating
  → (record) index.md + log.md
  → (persist) git commit + push
```

## Pitfalls

- **Article may be misnamed** — when the filename doesn't match content (e.g., `llm-inference-google-ai-mode-qa5.md` about GaussDB), rename it with `google-ai-mode_` prefix + descriptive suffix before ingestion
- **Not every article needs Wolai sync** — only if a corresponding raw export exists. Standalone `raw/articles/` files are wiki-internal only
- **gif/emoji placeholders** in Google AI Mode exports — skip or clean up; they are formatting artifacts from the AI UI
- **Citation markers like [系统 1], [系统 2]** — AI-generated indexing artifacts; clean them up or integrate the info naturally
- **Mapping check is always required** — even when just updating content, verify no structural change occurred that would invalidate the existing mapping
