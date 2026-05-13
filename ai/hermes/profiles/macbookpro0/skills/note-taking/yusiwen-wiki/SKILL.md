---
name: yusiwen-wiki
description: "Maintain Siwen's personal wiki at ~/git/mine/wiki/ — create/modify pages following SCHEMA.md conventions: frontmatter, wikilinks, index/log updates, tag taxonomy, provenance markers, filename rules."
version: 1.1.0
author: Hermes Agent
platforms: [macos]
metadata:
  hermes:
    tags: [wiki, note-taking, conventions, markdown]
    category: note-taking
    related_skills: [wiki-reingest, wolai-export-to-markdown]
---

# Yusiwen Wiki Maintenance

The wiki lives at `/Users/yusiwen/git/mine/wiki/`. It is a multi-domain personal knowledge base with strict conventions defined in `SCHEMA.md` at the wiki root. **Always read SCHEMA.md before creating or modifying any page.**

## When to Load This Skill

Load this skill when:
- Creating a new wiki page (concept, entity, comparison, etc.)
- Modifying or expanding an existing wiki page
- Adding external resources or references to wiki pages
- The user says "follow the conventions in SCHEMA.md" or "follow wiki conventions"

## Key Conventions (from SCHEMA.md)

### Frontmatter (every page)
```yaml
---
title: Page Title
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: entity | concept | comparison | query | summary
tags: [from taxonomy below]
sources: [raw/articles/source-name.md]
# Optional:
confidence: high | medium | low
contested: true
contradictions: [other-page-slug]
---
```

### Tag Taxonomy
Tags must come from the approved taxonomy in SCHEMA.md. Key categories:
- **AI/ML**: model, architecture, benchmark, training, optimization, fine-tuning, inference, alignment, data, evaluation
- **Programming**: go, rust, c, java, programming
- **Linux Kernel**: kernel, memory-management, scheduling, filesystem, driver, syscall
- **Networking**: networking, tcp-ip, dns, http, cloud-networking, protocol
- **Cloud**: cloud, kubernetes, containers, infrastructure, storage, serverless
- **Science**: science, physics, mathematics, quantum, biology, chemistry

### Filename Convention (ALL files and directories)
1. **Lowercase everything** — `MyFile.md` → `myfile.md`
2. **Spaces to hyphens** — `Big Data.md` → `big-data.md`
3. **Strip trailing spaces**
4. **Preserve ALL special characters** — Chinese characters, `()`, `&`, `'`, `.`, `-`. Do NOT strip, replace, or hash-encode.
5. If unsure → ask the user

### Wikilinks
- Use `[[wikilinks]]` to link between pages
- At minimum 2 outbound wikilinks per page
- Use `[[subdir/pagename]]` only when filenames collide; otherwise Obsidian resolves by filename across all subdirectories
- Frontmatter paths (`sources:`, `contradictions:`) are always relative to wiki root, NOT the page's directory
- After creating or updating a page, **add reverse links** to existing related pages so the graph is bidirectional

### Provenance Markers
- On pages synthesizing 3+ sources, append `^[raw/path/to/source.md]` at end of paragraphs
- Sources may live in `raw/articles/` (user-provided Q&A exports, web clippings) or `raw/<export-name>/` (wolai.app exports like `raw/big-data-data-science-export/`, `raw/cloud-computing-export/`, etc.)
- Always use the full path from wiki root, e.g.: `^[raw/big-data-data-science-export/应用/推荐系统/推荐系统.md]`

### Page Organization
- Pages live in domain subdirectories: `concepts/ai-ml/`, `concepts/programming/`, `entities/tools/`, etc.
- Top-level directory structure: `concepts/{ai-ml,programming,linux-kernel,networking,cloud,science}/`, `entities/{people,companies,tools,models}/`, `comparisons/`, `raw/`

### Update Policy
- Every new page must be added to `index.md` under the correct section
- Every action (create, update, ingest, archive, delete) must be appended to `log.md`
- When updating a page, always bump the `updated` date in frontmatter
- When new info conflicts with existing content, check dates, note contradictions in frontmatter
- Provenance markers: on pages synthesizing 3+ sources, append `^[raw/path/to/source.md]` at paragraph end. See [[#Provenance Markers]] above for full convention including raw export paths.

### Page Thresholds
- **Create** when entity/concept appears in 2+ sources or is central to one source
- **Add to existing** when something already covered
- **Split** when page exceeds ~200 lines
- **Archive** when fully superseded — move to `_archive/`, remove from index

### Domain Subdirectories Map
| Root dir | Contents |
|---|---|
| `concepts/ai-ml/` | AI/ML topics (models, techniques, papers) |
| `concepts/programming/` | Programming languages and paradigms |
| `concepts/linux-kernel/` | Linux kernel internals |
| `concepts/networking/` | Networking protocols and infrastructure |
| `concepts/cloud/` | Cloud computing and platforms |
| `concepts/science/` | Physics, math, biology, chemistry |
| `entities/people/` | Notable individuals |
| `entities/companies/` | Organizations and companies |
| `entities/tools/` | Software tools and frameworks |
| `entities/models/` | ML models |
| `comparisons/ai-ml/` | AI/ML comparisons |
| `comparisons/programming/` | Programming language comparisons |
| `raw/` | Source exports (wolai.app, web, articles, papers) |

## Workflow: Creating a New Wiki Page

1. Read SCHEMA.md (this skill already has the rules, but re-read if anything is unclear)
2. **If the topic is sourced from existing raw exports** (not from new external research), first search `raw/` for matching files:
   - Use `search_files` with multiple patterns — include English terms, Chinese terms, synonyms, and related subtopics
   - Example: for "recommender systems" search for `recommend|推荐|recall|ranking|collaborative.filtering|ctr`
   - Check if matching raw sources are already ingested (look for existing concept pages under `concepts/` that cover the topic)
   - If raw sources exist but are un-ingested, list them in the new page's `sources:` frontmatter with their full paths
3. Create the .md file in the correct domain subdirectory
4. Add proper YAML frontmatter with all required fields
5. Write content with `[[wikilinks]]` to related pages (minimum 2 outbound), provenance markers if multi-source
6. **Bidirectional cross-linking** — After creating the new page, search for existing pages that should reference it:
   - Scan related pages (e.g., if you create `recommender-systems.md`, check `reranking.md` and `cross-encoder-reranking.md`)
   - Add `[[wikilinks]]` back from those existing pages to the new page, with appropriate context sections
   - This ensures the cross-reference network is symmetrical and creates a discoverable reading graph
7. Add entry to `index.md` under the correct section
8. Append log entry to `log.md` in the format:
   ```
   ## [YYYY-MM-DD] create | Title
   - **Created:**
     - `path/to/page.md` — description
   - **Updated:**
     - `index.md` — added entry, bumped total pages to N
   - Tags applied: tag1, tag2
   ```
8. Commit and push via git

## Workflow: Modifying an Existing Wiki Page

1. Read the existing page
2. Make changes, preserving existing structure and conventions
3. Bump `updated:` date in frontmatter
4. If adding content from external sources, add provenance markers
5. Append log entry to `log.md` in the format:
   ```
   ## [YYYY-MM-DD] update | Title — brief description
   - **Updated:**
     - `path/to/page.md` — what changed
   - Tags applied: tag1, tag2
   ```
6. Commit and push via git

## Workflow: Auditing Raw Source Exports for Ingestion Gaps

When the user says "find which pages need to be ingested" or "do a full swipe" on a raw export directory, perform a systematic cross-reference. **For the detailed methodology (common mappings, duplicate handling, condensed ingestion handling, priority guidance), load the reference file `references/ingestion-audit-methodology.md`.**

1. **Inventory the raw sources** — Find all `.md` files in `raw/<export-name>/`, excluding `file/` and `image/` asset subdirectories.
2. **Inventory existing wiki pages** — List all pages under `concepts/` and `entities/` to establish what's already been ingested.
3. **Cross-reference by topic** — For each raw file, determine if its topic is already covered by an existing wiki page.
4. **Categorize each raw file** into ingested, missing, or index/overview.
5. **For truly missing items**, recommend which wiki page to create or which existing page to merge into.
6. **Report format (use markdown)**:
   - Summary table at top (ingested vs missing counts)
   - ✅ Already ingested section — grouped by category, with existing page names
   - ❌ Truly missing section — each item with: raw path, suggested wiki page path, priority (High/Medium/Low), and brief rationale
   - Priority matrix at end
7. **Save the report** to `raw/tasks/ingest/missing-page_<export-name>.md` — this is the wiki-side storage convention for pre-ingest audit reports.
8. **Do NOT modify any wiki page or raw source** during the audit phase. The report is a plan, not execution.

**User preference:** Reports should be comprehensive but structured. Use tables and code blocks for clarity. Organize by category (protocols, devices, tools, etc.). Include total counts. Be honest about the ingestion rate (e.g., "94% already ingested").

## Workflow: Creating a Concept Page from External Source Content

When the user shares external research content (exported Q&A conversations, web clippings, PDFs, etc.) and asks to add it to the wiki:

1. **Save the raw source** — Write the full export to `raw/articles/<topic-slug>.md` with raw-source frontmatter:
   ```yaml
   ---
   source_url: <original URL or "user-exported">
   ingested: YYYY-MM-DD
   sha256: <hex digest of all content below the frontmatter>
   ---
   ```
   Compute the SHA256 of the body content (everything after the closing `---`) using **`execute_code` with Python's `hashlib`**, NOT terminal commands. This is more reliable across platforms and avoids shell escaping issues:
   ```python
   import hashlib
   with open(path, "rb") as f:
       body = f.read()
   print(hashlib.sha256(body).hexdigest())
   ```
   The SHA256 enables drift detection on re-ingest: a future re-ingest of the same source can skip processing when content is unchanged, and flag drift when it has changed. **Do NOT use terminal `shasum` or `sha256sum` commands** — they may produce different output depending on the platform (macOS vs Linux), and their output includes the filename which must be stripped.
2. **Create the concept page** — Under `concepts/<domain>/<topic-slug>.md` with full frontmatter (`title`, `created`, `updated`, `type`, `tags`, `sources: [raw/articles/<topic-slug>.md]`, `confidence`).
3. **Synthesize, don't mirror** — Extract key facts, organize into sections, add comparison tables, and include the best explanations/analogies. Do NOT copy the raw source verbatim. Use provenance markers (`^[raw/articles/<topic-slug>.md]`) at the end of paragraphs that synthesize 3+ claims from the source.
4. **Cross-link bidirectionally** — Add `[[wikilinks]]` to existing related pages (minimum 2 outbound). Link to the [[transformer-architecture]] page for architectural basics, [[training-fine-tuning]] for training topics, etc. Then search for existing pages that should link back (e.g., if you add a new inference technique, ensure the parent inference page has a section pointing to it).
5. **Update `index.md`** — Add entry under the correct section, bump the total page count.
6. **Append to `log.md`** — Format:
   ```
   ## [YYYY-MM-DD] add | Title — brief
   - **Created:**
     - `raw/articles/<topic>.md` — description
     - `concepts/<domain>/<topic>.md` — description
   - **Updated:**
     - `index.md` — added entry, bumped total pages to N
   - Tags applied: tag1, tag2
   ```
7. **Commit and push** — Use single quotes for commit messages to avoid `&` parsing issues in the terminal tool.

## Workflow: Enriching an Existing Wiki Page with External Research

When the user asks you to research a topic and enrich existing wiki content:

1. **Load authoritative sources** — documentation sites, arxiv papers, READMEs. Verify claims across 2+ sources.
2. **Extract key facts** — prioritize: definitions, hyperparameters, comparison tables, best practices, original paper references.
3. **Format per SCHEMA.md conventions** — frontmatter, wikilinks (min 2), tables, code blocks where applicable.
4. **Structure for readability** — use sections, subsections, comparison tables. For resource collections (tutorials, tools, papers), organize by **difficulty/audience level** (beginner → intermediate → advanced) or by category.
5. **Include primary source URLs** — link to original papers (arXiv), official docs, and notebook repos.
6. **Add provenance markers** — on any paragraph synthesizing content, append `^[raw/articles/<source-file>.md]` so the reader can trace each claim back. This is in addition to the `sources:` frontmatter.
7. **Bump `updated:` date** in page frontmatter.
8. **Update `index.md`** — bump the "Last updated" date.
9. **Append to `log.md`** — describe what was updated and why.
10. **Commit and push** with a descriptive message using single quotes (see git pitfall below).

**User preference:** User values well-structured, sectioned content with clear organization. Tutorial/resource lists should be grouped by difficulty level. Content should be fact-checked against primary sources. Tables are preferred for comparison data. Code snippets should have language annotations and comments.

## Pitfalls

- **Do not modify `raw/` files** — they are faithful imports from source apps (wolai.app, etc.). The concept pages are where enriched content goes.
- **Do not skip index.md or log.md** — both are mandatory for every creation/update action.
- **Do not use tags outside the taxonomy** — add new tags to SCHEMA.md's taxonomy first, then use them.
- **Do not strip Chinese characters or special chars** from filenames — `&`, `()`, Unicode all valid.
- **Do not use shell tools for `&`-containing filenames** — use Python's zipfile, shutil, etc. instead.
- **Always bump updated date** — the only exception is a brand-new page, which uses created date for both.
- **Provenance markers are required for 3+ sources** — append `^[raw/path/to/source.md]` at paragraph end.
- **Git commit messages with `&` break the terminal tool** — the `&` character is interpreted as shell backgrounding and causes the foreground parser to reject the command. Always use **single quotes** for commit messages: `git commit -m 'commit message with and or whatever'`. Never use double quotes when the message might contain `&&`, `&`, or other shell-special characters.
