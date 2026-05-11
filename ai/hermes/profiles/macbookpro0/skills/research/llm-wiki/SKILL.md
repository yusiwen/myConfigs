---
name: llm-wiki
description: "Karpathy's LLM Wiki: build/query interlinked markdown KB."
version: 2.7.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [wiki, knowledge-base, research, notes, markdown, rag-alternative]
    category: research
    related_skills: [obsidian, arxiv]
---

# Karpathy's LLM Wiki

Build and maintain a persistent, compounding knowledge base as interlinked markdown files.
Based on [Andrej Karpathy's LLM Wiki pattern](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f).

Unlike traditional RAG (which rediscovers knowledge from scratch per query), the wiki
compiles knowledge once and keeps it current. Cross-references are already there.
Contradictions have already been flagged. Synthesis reflects everything ingested.

**Division of labor:** The human curates sources and directs analysis. The agent
summarizes, cross-references, files, and maintains consistency.

## When This Skill Activates

Use this skill when the user:
- Asks to create, build, or start a wiki or knowledge base
- Asks to ingest, add, or process a source into their wiki
- Asks to research a topic and add it to the wiki ("find information about X and wiki it")
- Asks a question and an existing wiki is present at the configured path
- Asks to lint, audit, or health-check their wiki
- References their wiki, knowledge base, or "notes" in a research context
- Asks to find, inventory, or audit what exists on a topic in the wiki — even if the request seems like a simple lookup, it may reveal gaps that become new pages

## Wiki Location

**Resolution order (check each until found):**

1. `WIKI_PATH` environment variable (e.g. in `~/.hermes/.env`)
2. `skills.config.wiki.path` in `~/.hermes/config.yaml` (e.g. `${HOME}/git/mine/wiki`)
3. Default: `~/wiki`

```bash
# Check config.yaml for skills.config.wiki.path
CONFIG_WIKI=$(python3 -c "
import yaml
with open('$HOME/.hermes/config.yaml') as f:
    cfg = yaml.safe_load(f)
try:
    p = cfg['skills']['config']['wiki']['path']
    # Expand $HOME / ${HOME}
    import os
    p = os.path.expandvars(p)
    print(p)
except (KeyError, TypeError):
    pass
" 2>/dev/null)
WIKI="${WIKI_PATH:-${CONFIG_WIKI:-$HOME/wiki}}"
```

The wiki is just a directory of markdown files — open it in Obsidian, VS Code, or
any editor. No database, no special tooling required.

## Architecture: Three Layers

```
wiki/
├── SCHEMA.md           # Conventions, structure rules, domain config
├── index.md            # Sectioned content catalog with one-line summaries
├── log.md              # Chronological action log (append-only, rotated yearly)
├── raw/                # Layer 1: Immutable source material
│   ├── articles/       # Web articles, clippings
│   ├── papers/         # PDFs, arxiv papers
│   ├── transcripts/    # Meeting notes, interviews
│   └── assets/         # Images, diagrams referenced by sources
├── entities/           # Layer 2: Entity pages (people, orgs, products, models)
├── concepts/           # Layer 2: Concept/topic pages
├── comparisons/        # Layer 2: Side-by-side analyses
└── queries/            # Layer 2: Filed query results worth keeping
```

**Layer 1 — Raw Sources:** Immutable. The agent reads but never modifies these.
**Layer 2 — The Wiki:** Agent-owned markdown files. Created, updated, and
cross-referenced by the agent.
**Layer 3 — The Schema:** `SCHEMA.md` defines structure, conventions, and tag taxonomy.

## Resuming an Existing Wiki (CRITICAL — do this every session)

When the user has an existing wiki, **always orient yourself before doing anything**:

① **Read `SCHEMA.md`** — understand the domain, conventions, and tag taxonomy.
② **Read `index.md`** — learn what pages exist and their summaries.
③ **Scan recent `log.md`** — read the last 20-30 entries to understand recent activity.

```bash
# Determine wiki path (from $WIKI_PATH, config.yaml, or default)
# See "Wiki Location" section above for the resolution logic
WIKI="${WIKI_PATH:-${CONFIG_WIKI:-$HOME/wiki}}"
# Orientation reads at session start
read_file "$WIKI/SCHEMA.md"
read_file "$WIKI/index.md"
read_file "$WIKI/log.md" offset=<last 30 lines>
```

Only after orientation should you ingest, query, or lint. This prevents:
- Creating duplicate pages for entities that already exist
- Missing cross-references to existing content
- Contradicting the schema's conventions
- Repeating work already logged

For large wikis (100+ pages), also run a quick `search_files` for the topic
at hand before creating anything new.

## Initializing a New Wiki

When the user asks to create or start a wiki:

1. Determine the wiki path (from `$WIKI_PATH` env var, or ask the user; default `~/wiki`)
2. Create the directory structure above
3. Ask the user what domain the wiki covers — be specific
4. Write `SCHEMA.md` customized to the domain (see template below)
5. Write initial `index.md` with sectioned header
6. Write initial `log.md` with creation entry
7. Confirm the wiki is ready and suggest first sources to ingest

### SCHEMA.md Template

Adapt to the user's domain. The schema constrains agent behavior and ensures consistency:

```markdown
# Wiki Schema

## Domain
[What this wiki covers — e.g., "AI/ML research", "personal health", "startup intelligence"]

## Conventions
- File names: lowercase, hyphens, no spaces (e.g., `transformer-architecture.md`)
- Every wiki page starts with YAML frontmatter (see below)
- Use `[[wikilinks]]` to link between pages (minimum 2 outbound links per page)
- When updating a page, always bump the `updated` date
- Every new page must be added to `index.md` under the correct section
- Every action must be appended to `log.md`
- **Provenance markers:** On pages that synthesize 3+ sources, append `^[raw/articles/source-file.md]`
  at the end of paragraphs whose claims come from a specific source. This lets a reader trace each
  claim back without re-reading the whole raw file. Optional on single-source pages where the
  `sources:` frontmatter is enough.

## Frontmatter
  ```yaml
  ---
  title: Page Title
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  type: entity | concept | comparison | query | summary
  tags: [from taxonomy below]
  sources: [raw/articles/source-name.md]
  # Optional quality signals:
  confidence: high | medium | low        # how well-supported the claims are
  contested: true                        # set when the page has unresolved contradictions
  contradictions: [other-page-slug]      # pages this one conflicts with
  ---
  ```

`confidence` and `contested` are optional but recommended for opinion-heavy or fast-moving
topics. Lint surfaces `contested: true` and `confidence: low` pages for review so weak claims
don't silently harden into accepted wiki fact.

### raw/ Frontmatter

Raw sources ALSO get a small frontmatter block so re-ingests can detect drift:

```yaml
---
source_url: https://example.com/article   # original URL, if applicable
ingested: YYYY-MM-DD
sha256: <hex digest of the raw content below the frontmatter>
---
```

The `sha256:` lets a future re-ingest of the same URL skip processing when content is unchanged,
and flag drift when it has changed. Compute over the body only (everything after the closing
`---`), not the frontmatter itself.

## Tag Taxonomy
[Define 10-20 top-level tags for the domain. Add new tags here BEFORE using them.]

Example for AI/ML:
- Models: model, architecture, benchmark, training
- People/Orgs: person, company, lab, open-source
- Techniques: optimization, fine-tuning, inference, alignment, data
- Meta: comparison, timeline, controversy, prediction

Rule: every tag on a page must appear in this taxonomy. If a new tag is needed,
add it here first, then use it. This prevents tag sprawl.

## Page Thresholds
- **Create a page** when an entity/concept appears in 2+ sources OR is central to one source
- **Add to existing page** when a source mentions something already covered
- **DON'T create a page** for passing mentions, minor details, or things outside the domain
- **Split a page** when it exceeds ~200 lines — break into sub-topics with cross-links
- **Archive a page** when its content is fully superseded — move to `_archive/`, remove from index

## Entity Pages
One page per notable entity. Include:
- Overview / what it is
- Key facts and dates
- Relationships to other entities ([[wikilinks]])
- Source references

## Concept Pages
One page per concept or topic. Include:
- Definition / explanation
- Current state of knowledge
- Open questions or debates
- Related concepts ([[wikilinks]])

## Comparison Pages
Side-by-side analyses. Include:
- What is being compared and why
- Dimensions of comparison (table format preferred)
- Verdict or synthesis
- Sources

## Update Policy
When new information conflicts with existing content:
1. Check the dates — newer sources generally supersede older ones
2. If genuinely contradictory, note both positions with dates and sources
3. Mark the contradiction in frontmatter: `contradictions: [page-name]`
4. Flag for user review in the lint report
```

### index.md Template

The index is sectioned by type. Each entry is one line: wikilink + summary.

```markdown
# Wiki Index

> Content catalog. Every wiki page listed under its type with a one-line summary.
> Read this first to find relevant pages for any query.
> Last updated: YYYY-MM-DD | Total pages: N

## Entities
<!-- Alphabetical within section -->

## Concepts

## Comparisons

## Queries
```

**Scaling rule:** When any section exceeds 50 entries, split it into sub-sections
by first letter or sub-domain. When the index exceeds 200 entries total, create
a `_meta/topic-map.md` that groups pages by theme for faster navigation.

### log.md Template

```markdown
# Wiki Log

> Chronological record of all wiki actions. Append-only.
> Format: `## [YYYY-MM-DD] action | subject`
> Actions: ingest, update, query, lint, create, archive, delete
> When this file exceeds 500 entries, rotate: rename to log-YYYY.md, start fresh.

## [YYYY-MM-DD] create | Wiki initialized
- Domain: [domain]
- Structure created with SCHEMA.md, index.md, log.md
```

### 0. Wiki Gap Analysis & Page Planning

When the user asks to **find existing documents about a topic** in the wiki, and the search reveals scattered or missing coverage, this workflow fills the gaps:

① **Exhaustive search first** — use multiple search strategies to find every existing mention:
   ```bash
   # Search by topic keywords (English)
   search_files "windows.*(debug|reverse|process)" target="content" path="\$WIKI" -i
   # Search by tool names / jargon
   search_files "(windbg|x64dbg|ida|ghidra)" target="content" path="\$WIKI" -i
   # Search by Chinese / localized terms
   search_files "(逆向|反汇编|调试器|脱壳)" target="content" path="\$WIKI"
   # Check entities/tools/ for related tool pages
   search_files "*windows*debug*" target="files" path="\$WIKI"
   ```

② **Read SCHEMA.md for placement rules** — understand the directory taxonomy before deciding where to put new pages. Don't guess; read the actual schema.

③ **Read index.md for existing sections** — find which section the new page belongs to, and check for nearby sibling pages that inform the page's focus and cross-links.

④ **Synthesize findings** — report to the user what exists and what the gaps are. Reference specific file paths: "Found Sysinternals mentioned in `raw/operating-system-export/发行版/Windows/Windows.md` (lines 335-361), Ghidra/radare2 in `raw/programming-languages-export/others/others.md`, but no dedicated pages for WinDbg, x64dbg, or IDA Pro."

⑤ **Propose placement with reasoning** — before creating, explain *why* a given path is right:
   - **Concept page** (`concepts/programming/`): when the topic is about techniques, tool comparisons, or cross-cutting knowledge (RE tools overview, PE format, process injection)
   - **Entity page** (`entities/tools/`): when it's about a single well-defined tool with its own usage docs (WinDbg alone, IDA Pro alone)
   - **Enrich existing page** (`raw/...` or `concepts/...`): when the new information supplements a page that already covers the territory
   - Cite schema rules: "SCHEMA.md says `concepts/programming/` covers assembly, compilation, and low-level programming — RE tools fit here because the existing `c-cpp-fundamentals.md` already mentions reverse engineering"

⑥ **Create with cross-references** — new pages must have:
   - Proper YAML frontmatter (title, created, updated, type, tags from taxonomy)
   - At least 2 `[[wikilinks]]` to existing pages
   - Links back to the raw/ source files where the information was found (provenance)
   - A practical table or selection guide if the topic involves multiple tools (helps readers choose)

⑦ **Update navigation** — same as Ingest step ⑤: add to index.md under the correct section, bump total pages count, append to log.md.

⑧ **Report what was created** — the page path, summary, and which existing pages it cross-references.

This workflow differs from "Research & Ingest" (step 2) in that it starts from *wiki content* rather than *external sources*. The goal is curation of existing knowledge, not expansion from new research. The user already has the domain expertise — they want you to organize what's there and fill the structural gaps.

## Pre-Ingest: Auditing Content Sources via MCP

Before ingesting any new export into the wiki, **first audit what exists** in the source application (wolai, Notion, etc.) via MCP. This gives you a complete inventory to compare against on-disk `raw/*-export` folders, revealing gaps, missing pages, and scope before any processing.

See `references/mcp-content-audit.md` for the full workflow with exact tool calls, recursive page tree exploration patterns, and reporting format.

## Core Operations

### 1. Ingest

When the user provides a source (URL, file, paste), integrate it into the wiki:

① **Capture the raw source:**
   - URL → use `web_extract` to get markdown, save to `raw/articles/`
   - PDF → use `web_extract` (handles PDFs), save to `raw/papers/`
   - Pasted text → save to appropriate `raw/` subdirectory
   - Name the file descriptively: `raw/articles/karpathy-llm-wiki-2026.md`
   - **Add raw frontmatter** (`source_url`, `ingested`, `sha256` of the body).
     On re-ingest of the same URL: recompute the sha256, compare to the stored value —
     skip if identical, flag drift and update if different. This is cheap enough to
     do on every re-ingest and catches silent source changes.

② **Discuss takeaways** with the user — what's interesting, what matters for
   the domain. (Skip this in automated/cron contexts — proceed directly.)
   **Note:** If the user says "just add it", "wiki this", or otherwise signals
   they want the ingest without back-and-forth, skip directly to step ③.

③ **Check what already exists** — search index.md and use `search_files` to find
   existing pages for mentioned entities/concepts. This is the difference between
   a growing wiki and a pile of duplicates.

④ **Write or update wiki pages:**
   - **New entities/concepts:** Create pages only if they meet the Page Thresholds
     in SCHEMA.md (2+ source mentions, or central to one source)
   - **Existing pages:** Add new information, update facts, bump `updated` date.
     When new info contradicts existing content, follow the Update Policy.
   - **Cross-reference:** Every new or updated page must link to at least 2 other
     pages via `[[wikilinks]]`. Check that existing pages link back.
   - **Tags:** Only use tags from the taxonomy in SCHEMA.md
   - **Provenance:** On pages synthesizing 3+ sources, append `^[raw/articles/source.md]`
     markers to paragraphs whose claims trace to a specific source.
   - **Confidence:** For opinion-heavy, fast-moving, or single-source claims, set
     `confidence: medium` or `low` in frontmatter. Don't mark `high` unless the
     claim is well-supported across multiple sources.

⑤ **Update navigation:**
   - Add new pages to `index.md` under the correct section, alphabetically
   - Update the "Total pages" count and "Last updated" date in index header
   - Append to `log.md`: `## [YYYY-MM-DD] ingest | Source Title`
   - List every file created or updated in the log entry

⑥ **Report what changed** — list every file created or updated to the user.

A single source can trigger updates across 5-15 wiki pages. This is normal
and desired — it's the compounding effect.

### 2. Research & Ingest

When the user asks you to **find information about a topic and add it to the wiki** (e.g., "research tensor parallelism and add it to the wiki"), the user is the curator but not the source provider. Follow this hybrid workflow:

① **Clarify scope if needed** — is the user asking for a deep dive or a summary?
   What angle matters to them? Don't over-ask; if the topic is well-bounded, proceed.

② **Research the topic** — gather authoritative sources:
   - Use available tools (web_* search, browser, curl+terminal) to find 2-5 good sources
   - Prioritize: official docs (NVIDIA, HuggingFace, AWS) > papers (arxiv) > blog posts
   - If browser/search tools aren't available, see `references/web-research-fallback.md` for
     curl+GitHub API techniques — Bing via curl and the GitHub Issues API are the most
     reliable fallbacks
   - **Skip this step** if the user explicitly wants you to summarize from existing knowledge
     (e.g., "you mentioned TP earlier, explain it" — you can synthesize from what you know)

③ **Capture raw sources:**
   - Save each source to `raw/articles/` or `raw/papers/` with proper frontmatter
     (`source_url`, `ingested`, `sha256`). For pages fetched via curl/browser where the
     full HTML is impractical, save a condensed excerpt with key facts and note
     `extracted: true` in the frontmatter.
   - For topics where you synthesize primarily from your own knowledge with light web
     verification, create a synthetic raw source: `raw/articles/research-topic-research-note.md`
     with `source_type: agent-knowledge` — this documents what you knew vs. what you looked up.

④ **Check what already exists** — scan index.md and existing pages for entities/concepts
   this research touches. Same as Ingest step ③.

⑤ **Write or update wiki pages** — same as Ingest step ④. Since you're synthesizing from
   multiple sources AND your own knowledge, use provenance markers (`^[raw/articles/source.md]`)
   more aggressively to distinguish claims from the research vs. background knowledge.

⑥ **Update navigation** — same as Ingest step ⑤.

⑦ **Report what changed** — same as Ingest step ⑥.

**Example from this session:** The user asked "find information about tensor parallelism" without providing a URL. I researched via curl to AWS SageMaker docs, created a raw source excerpt, then wrote 5 concept pages + 1 comparison page. The raw source was a condensed excerpt (not the full HTML page), annotated with `extracted: true`.

### 3. Query

When the user asks a question about the wiki's domain:

① **Read `index.md`** to identify relevant pages.
② **For wikis with 100+ pages**, also `search_files` across all `.md` files
   for key terms — the index alone may miss relevant content.
③ **Read the relevant pages** using `read_file`.
④ **Synthesize an answer** from the compiled knowledge. Cite the wiki pages
   you drew from: "Based on [[page-a]] and [[page-b]]..."
⑤ **If the wiki has only scattered mentions but no dedicated page,** report
   what you found and offer to create a proper page. For example: "There are
   3 mentions of PCIe scattered across [[hardwares]], [[qemu]], and raw source
   files, but no dedicated PCIe page. Want me to create one?"
⑥ **File valuable answers back** — if the answer is a substantial comparison,
   deep dive, or novel synthesis, create a page in `queries/` or `comparisons/`.
   Don't file trivial lookups — only answers that would be painful to re-derive.
⑦ **Update log.md** with the query and whether it was filed.

### 4. Lint

When the user asks to lint, health-check, or audit the wiki:

① **Orphan pages:** Find pages with no inbound `[[wikilinks]]` from other pages.
```python
# Use execute_code for this — programmatic scan across all wiki pages
import os, re
from collections import defaultdict
wiki = "<WIKI_PATH>"
# Scan all .md files in entities/, concepts/, comparisons/, queries/
# Extract all [[wikilinks]] — build inbound link map
# Pages with zero inbound links are orphans
```

② **Broken wikilinks:** Find `[[links]]` that point to pages that don't exist.

③ **Index completeness:** Every wiki page should appear in `index.md`. Compare
   the filesystem against index entries.

④ **Frontmatter validation:** Every wiki page must have all required fields
   (title, created, updated, type, tags, sources). Tags must be in the taxonomy.

⑤ **Stale content:** Pages whose `updated` date is >90 days older than the most
   recent source that mentions the same entities.

⑥ **Contradictions:** Pages on the same topic with conflicting claims. Look for
   pages that share tags/entities but state different facts. Surface all pages
   with `contested: true` or `contradictions:` frontmatter for user review.

⑦ **Quality signals:** List pages with `confidence: low` and any page that cites
   only a single source but has no confidence field set — these are candidates
   for either finding corroboration or demoting to `confidence: medium`.

⑧ **Source drift:** For each file in `raw/` with a `sha256:` frontmatter, recompute
   the hash and flag mismatches. Mismatches indicate the raw file was edited
   (shouldn't happen — raw/ is immutable) or ingested from a URL that has since
   changed. Not a hard error, but worth reporting.

⑨ **Page size:** Flag pages over 200 lines — candidates for splitting.

⑩ **Tag audit:** List all tags in use, flag any not in the SCHEMA.md taxonomy.

⑪ **Log rotation:** If log.md exceeds 500 entries, rotate it.

⑫ **Report findings** with specific file paths and suggested actions, grouped by
   severity (broken links > orphans > source drift > contested pages > stale content > style issues).

⑬ **Append to log.md:** `## [YYYY-MM-DD] lint | N issues found`

## Working with the Wiki

### Searching

```bash
# Find pages by content
search_files "transformer" path="$WIKI" file_glob="*.md"

# Find pages by filename
search_files "*.md" target="files" path="$WIKI"

# Find pages by tag
search_files "tags:.*alignment" path="$WIKI" file_glob="*.md"

# Recent activity
read_file "$WIKI/log.md" offset=<last 20 lines>
```

### Bulk Ingest (Single Source, Multiple Pages)

When a single source (article, paper, URL) generates 5-15 wiki pages, batch the updates:
1. Read the source first
2. Identify all entities and concepts in it
3. Check existing pages in one search pass (not N individual lookups)
4. Create/update all pages in one pass
5. Update index.md once at the end
6. Write a single log entry covering the batch

### Importing Notebook/App Exports (ZIP or On-Disk Markdown)

When the user provides a markdown export from a note-taking app — either as a ZIP file (Obsidian, Notion, Bear) or as files already on disk under `raw/<export-name>/` (e.g., from MCP export scripts):

> **First time importing an export?** → Follow the workflow below.
> **Re-importing an updated export?** → Use the `wiki-reingest` skill instead, which compares by content hash and asks about new/updated/deleted files.

> **Export was produced programmatically (MCP, API)?** → The `wolai-export-to-markdown` skill covers the export side. The ingest workflow below handles the import side regardless of how the raw markdown was produced.

#### Step 0: Prepare raw sources

If the raw files are **already on disk** (e.g., from MCP export at `raw/web-export/`):
1. **Add frontmatter** to every `.md` file — compute `sha256` of the body and prepend:
   ```python
   import hashlib, os, glob
   for fp in glob.glob(f"{WIKI}/raw/<export-name>/**/*.md", recursive=True):
       with open(fp, 'r') as f: content = f.read()
       if content.startswith('---'): continue
       fm = f"""---
   source_export: <export-name>
   ingested: {today}
   sha256: {hashlib.sha256(content.encode()).hexdigest()}
   ---
   \n"""
       with open(fp, 'w') as f: f.write(fm + content)
   ```
2. **Estimate scope** — count the `.md` files. If 50+ files, parallel subagents are warranted.

If the raw files come as a **ZIP**: unzip to a temp dir first, then proceed with scope estimation.

#### Step 1: Delegate to parallel subagents

2. **Copy raw sources:** Use `execute_code` (Python) to copy all `.md`, `.pdf`, and images to `raw/<export-name>/` preserving the original directory hierarchy. This is faster and avoids `terminal` timeouts from per-file subshells:
   ```python
   import shutil, os
   SRC = "/tmp/some-export/NotebookRoot"
   RAW = f"{WIKI}/raw/export-name"
   extensions = {'.md', '.pdf', '.png', '.jpg', '.jpeg', '.gif', '.svg'}
   for root, dirs, files in os.walk(SRC):
       for f in files:
           if os.path.splitext(f)[1].lower() in extensions:
               dest = os.path.join(RAW, os.path.relpath(root, SRC))
               os.makedirs(dest, exist_ok=True)
               shutil.copy2(os.path.join(root, f), os.path.join(dest, f))
   ```

3. **Delegate to parallel subagents** (via `delegate_task` with max 3 concurrent — `delegate_task` enforces a default `max_concurrent_children=3` limit; split into batches of 3 if more are needed). Divide the export into logical sections (e.g., Kubernetes, Containers, IaaS/Tools). Each subagent gets:
   - The wiki path, SCHEMA.md context
   - Its section's raw source path(s)
   - Instructions to read its section's `.md` files, create concept/entity pages
   - Key rules: frontmatter, [[wikilinks]], lowercase-hyphenated filenames, proper tags, write in English

4. **Parent reconciles index + log — children MUST NOT touch them.** This is critical:
   - Each subagent writes pages and returns a list of created files in its summary.
   - The **parent** collects all results, then patches `index.md` and `log.md` **once** at the end.
   - If a subagent is instructed to update index/log, multiple concurrent edits will produce formatting artifacts (`||` prefixes, broken pipes, duplicate section headers).
   - **Explicitly tell subagents**: "Do NOT modify index.md or log.md — the parent agent will handle those after all subagents finish."
   
   If the subagent model doesn't support returning summaries cleanly, serialize: dispatch one subagent for page creation, then a separate one for index/log updates after all pages exist.

5. **Group sub-topics, don't flood:** For a 200+ file export, instruct subagents to create **well-structured pages** that group related sub-topics (e.g., one "kubernetes-networking.md" page rather than 15 tiny ones). Target 8-15 pages per subagent, not 50.

6. **Clean up:** Remove the temp directory after ingest completes:
   ```python
   import shutil
   shutil.rmtree("/tmp/export-temp")
   ```

7. **Report growth:** After all subagents finish, summarize: pages created, wiki size before/after, raw files ingested.

8. **Sync Key Resources links:** Raw exports from wolai.app often have user-curated external links between the `## 目录` (TOC) and the first `#` heading — tutorials, official docs, and GitHub repos the user considered most important for that topic. After creating or updating wiki pages, **always sync these links** by running the fix script:

   ```bash
   python3 scripts/fix-top-links.py          # full scan + fix
   python3 scripts/fix-top-links.py --dry-run  # preview only
   ```

   This script (at the `wiki-reingest` skill directory) scans all raw exports, finds matching wiki pages via `sources:` frontmatter, and inserts missing links as a `> 🔗 **Key Resources:**` blockquote after the H1 title. It's **idempotent** — safe to run repeatedly.

   If creating wiki pages manually (not via the script), also add the Key Resources blockquote yourself: extract the external links from between `## 目录` and the first `#` heading in the raw source, and insert them right after the H1 title.

> 📖 See `references/zip-import-workflow.md` for a concrete worked example with exact Python snippets, subagent batch structure, and pitfalls from a real 264+184 file import.
> 📖 See `references/sanitize-raw-filenames.md` for the full file-sanitization workflow: handling Chinese→hash collisions, bottom-up directory renames, conflict resolution, and reference updating.
> 📋 Use `templates/subagent-ingest-context.md` as a copy-and-fill template for each subagent's context/goal block.

### Archiving

When content is fully superseded or the domain scope changes:
1. Create `_archive/` directory if it doesn't exist
2. Move the page to `_archive/` with its original path (e.g., `_archive/entities/old-page.md`)
3. Remove from `index.md`
4. Update any pages that linked to it — replace wikilink with plain text + "(archived)"
5. Log the archive action

### Obsidian Integration

The wiki directory works as an Obsidian vault out of the box:
- `[[wikilinks]]` render as clickable links
- Graph View visualizes the knowledge network
- YAML frontmatter powers Dataview queries
- The `raw/assets/` folder holds images referenced via `![[image.png]]`

For best results:
- Set Obsidian's attachment folder to `raw/assets/`
- Enable "Wikilinks" in Obsidian settings (usually on by default)
- Install Dataview plugin for queries like `TABLE tags FROM "entities" WHERE contains(tags, "company")`

If using the Obsidian skill alongside this one, set `OBSIDIAN_VAULT_PATH` to the
same directory as the wiki path.

### Obsidian Headless (servers and headless machines)

On machines without a display, use `obsidian-headless` instead of the desktop app.
It syncs vaults via Obsidian Sync without a GUI — perfect for agents running on
servers that write to the wiki while Obsidian desktop reads it on another device.

**Setup:**
```bash
# Requires Node.js 22+
npm install -g obsidian-headless

# Login (requires Obsidian account with Sync subscription)
ob login --email <email> --password '<password>'

# Create a remote vault for the wiki
ob sync-create-remote --name "LLM Wiki"

# Connect the wiki directory to the vault
cd ~/wiki
ob sync-setup --vault "<vault-id>"

# Initial sync
ob sync

# Continuous sync (foreground — use systemd for background)
ob sync --continuous
```

**Continuous background sync via systemd:**
```ini
# ~/.config/systemd/user/obsidian-wiki-sync.service
[Unit]
Description=Obsidian LLM Wiki Sync
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/path/to/ob sync --continuous
WorkingDirectory=/home/user/wiki
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
```

```bash
systemctl --user daemon-reload
systemctl --user enable --now obsidian-wiki-sync
# Enable linger so sync survives logout:
sudo loginctl enable-linger $USER
```

This lets the agent write to `~/wiki` on a server while you browse the same
vault in Obsidian on your laptop/phone — changes appear within seconds.

## Pitfalls

- **Zip filenames with `&` or shell-special characters break `unzip`:** The shell interprets `&` as a background operator even inside double quotes. When the terminal tool receives a filename with `&`, it errors with "Foreground command uses '&' backgrounding." **Fix:** Copy the file to `/tmp/` with a safe name first (`shutil.copy2(src, "/tmp/safe-name.zip")`), then `unzip` the copy. This also works for filenames with spaces, parentheses, or other shell meta-characters.
- **Never modify files in `raw/`** — sources are immutable. Corrections go in wiki pages.
- **Always orient first** — read SCHEMA + index + recent log before any operation in a new session.
  Skipping this causes duplicates and missed cross-references.
- **Always update index.md and log.md** — skipping this makes the wiki degrade. These are the
  navigational backbone.
- **Don't create pages for passing mentions** — follow the Page Thresholds in SCHEMA.md. A name
  appearing once in a footnote doesn't warrant an entity page.
- **Don't create pages without cross-references** — isolated pages are invisible. Every page must
  link to at least 2 other pages.
- **Frontmatter is required** — it enables search, filtering, and staleness detection.
- **Tags must come from the taxonomy** — freeform tags decay into noise. Add new tags to SCHEMA.md
  first, then use them.
- **Keep pages scannable** — a wiki page should be readable in 30 seconds. Split pages over
  200 lines. Move detailed analysis to dedicated deep-dive pages.
- **Place pages in the right concept section.** A hardware topic (PCIe, CPU architecture, memory
  bus) belongs in `hardware/`, not `linux-kernel/`. Kernel topics (schedulers, memory management,
  drivers) describe software that manages hardware → use `linux-kernel/`. When unsure about
  the best section, discuss placement with the user rather than guessing.
- **Ask before mass-updating** — if an ingest would touch 10+ existing pages, confirm the scope with the user first. However, if the user profile says they prefer full-auto ingest, respect that preference and proceed directly.
- **Rotate the log** — when log.md exceeds 500 entries, rename it `log-YYYY.md` and start fresh.
  The agent should check log size during lint.
- **Handle contradictions explicitly** — don't silently overwrite. Note both claims with dates,
  mark in frontmatter, flag for user review.
- **When researching, capture good-enough excerpts** — you don't need the full HTML of a web page
  for the raw source. A condensed excerpt with key facts, formulas, and tables is fine. Mark
  `extracted: true` in the raw frontmatter so future lints know it's not a verbatim source.
- **Browser sandbox failures are common** in containers/VMs — fall back to `curl -sL` + Python
  tag-stripping for web research. Set `--no-sandbox` if browser tools are available.
- **Do NOT hash or strip Chinese characters from filenames:** UTF-8 Chinese characters work fine on modern Windows and Linux. Only lowercase, replace spaces with hyphens, and strip trailing whitespace. Hashing Chinese names to `chinese-xxxxx` destroys traceability and was explicitly rejected by the user.
- **Concurrent index/log edits from subagents cause formatting corruption:** When delegating ingest work to parallel subagents, do NOT let each one independently patch `index.md` and `log.md`. Concurrent edits produce artifacts: `||` prefixes on list lines, broken pipe characters, duplicate section headers. **Fix:** Have each subagent return a list of created files in its summary. The **parent** patches `index.md` and `log.md` once after all subagents finish. If the subagent model doesn't support returning summaries cleanly, serialize the work: dispatch one subagent to create pages, then a separate one to update index/log after all pages exist.
- **delegate_task max_concurrent_children defaults to 3:** If you try to dispatch 4+ tasks at once, the tool errors. Split into batches: 3 tasks first, then the remaining 1+ when those complete. The error message tells you the limit — read it and adjust, don't retry with the same count.
- **Subagent file modifications invalidate the parent's cached reads:** Subagents write pages and sometimes patch shared files despite instructions. When the parent later reads a file a subagent modified, it gets a "sibling modified" warning. Always re-read index.md and log.md after all subagents finish rather than relying on earlier cached reads.
- **File renames before directory renames:** When renaming thousands of files, rename files FIRST while parent directories still have their old names. THEN rename directories bottom-up (deepest first). If directories are renamed first, pre-computed old file paths become invalid.
- **Shell meta-characters (`&`, `$`) in zip filenames:** The terminal tool interprets `&` as a background operator even inside double quotes. Copy the zip to `/tmp/` with a safe name first using Python's `shutil.copy2()`, then unzip the copy.
- **Use Python/execute_code for bulk file ops, not terminal:** `rm -rf` on a directory with 300+
  files can timeout the terminal tool. Use `shutil.rmtree()` and `shutil.copytree()` via
  `execute_code` instead — it completes instantly regardless of file count.

## Related Tools

[llm-wiki-compiler](https://github.com/atomicmemory/llm-wiki-compiler) is a Node.js CLI that
compiles sources into a concept wiki with the same Karpathy inspiration. It's Obsidian-compatible,
so users who want a scheduled/CLI-driven compile pipeline can point it at the same vault this
skill maintains. Trade-offs: it owns page generation (replaces the agent's judgment on page
creation) and is tuned for small corpora. Use this skill when you want agent-in-the-loop curation;
use llmwiki when you want batch compile of a source directory.
