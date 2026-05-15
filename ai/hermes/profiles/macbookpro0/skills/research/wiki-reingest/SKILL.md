---
name: wiki-reingest
description: "Manage wiki content: ingest external sources, audit raw exports against existing pages, re-ingest updated zip exports, and maintain SCHEMA.md conventions."
version: 2.0.0
author: Hermes Agent
platforms: [linux, macos]
metadata:
  hermes:
    tags: [wiki, ingest, audit, sync, update, management]
    category: research
    related_skills: [llm-wiki]
---

# Wiki Content Management

Manage the personal knowledge wiki at `~/git/mine/wiki/` — ingest external articles, audit raw export directories for missing pages, and re-ingest updated zip exports.

## Principles

- **raw/ is the source of truth** — what's on disk is what the wiki pages reference
- **Follow SCHEMA.md** — every concept entity page must have YAML frontmatter, `[[wikilinks]]`, provenance markers (`^[raw/...]`), and be registered in `index.md` + `log.md`
- **Batch over file-by-file** — prefer automated scans over manual per-file edits
- **Raw sources get sha256 frontmatter** — ingested external content (`source_url`, `ingested`, `sha256`) so re-ingests can detect drift
- **Bump `updated` date** on every page modification

## Triggers

This skill should be loaded when the user asks to:
- Audit or scan a `raw/export-*/` directory against existing wiki pages
- Ingest an external article, Q&A transcript, or markdown file into the wiki
- Re-ingest an updated zip export (wolai.app, etc.)
- Create or update a concept or entity page by synthesizing raw sources
- Sync key-resources links from raw exports to wiki pages

---

## Workflow A: Audit Raw Export Directories

When the user says "check which files from raw/foo-export aren't in the wiki yet":

### Steps

1. **List raw files** — find all `.md` files excluding `*/file/*` and `*/image/*` (asset dirs):
   ```bash
   find <raw_dir> -name '*.md' ! -path '*/file/*' ! -path '*/image/*' | sort
   ```

2. **List existing wiki pages** — check `concepts/` and `entities/`:
   ```bash
   find ~/git/mine/wiki/concepts ~/git/mine/wiki/entities -name '*.md' | sort
   ```

3. **Cross-reference** — for each raw file, determine if its content is already reflected in an existing wiki page. Check:
   - Direct page matches (same topic name)
   - Batch ingestion logs in `log.md` — most exports were batch-ingested on 2026-05-10
   - Parent directories that were condensed into single summary pages

4. **Categorize** each raw file as:
   - **Ingested** — already covered by an existing wiki page (no action needed)
   - **Index/overview** — top-level index file whose content is distributed across existing pages
   - **Nested duplicate** — wolai.app often nests sub-pages under identically-named subdirectories; skip the duplicates
   - **Missing** — no existing wiki page covers this content

5. **For missing items**: suggest a target wiki page path and priority. Use the existing page organization:
   - `concepts/linux-kernel/` — kernel internals
   - `concepts/networking/` — network protocols and devices
   - `concepts/cloud/` — cloud computing, K8s
   - `concepts/container/` — container/Docker
   - `concepts/ai-ml/` — AI/ML concepts
   - `concepts/programming/` — programming languages (organized by language)
   - `entities/tools/` — software tools and frameworks
   - `concepts/misc/` — miscellaneous topics

6. **Save report** to `raw/tasks/ingest/missing-page_<export-name>.md` with format:
   - Header (generated date, source, purpose)
   - Summary table (status counts)
   - ✅ Already ingested section (organized by category)
   - ❌ Missing section (with suggested page path and priority)

### Pitfalls

- **Many exports were already batch-ingested** on 2026-05-10 (AI/ML, programming-languages, cloud-computing, network, compilers-linkers, algorithms, thoughts, miscellaneous). Don't flag these as missing.
- **Nested duplicates** — wolai.app exports often have the same file at `topic/topic.md` and `topic/topic/topic.md`. Only the shallowest instance matters.
- **tools-export was NOT batch-ingested** (~98% missing) — this is the exception.
- **distributed-systems-export and database-export** have concept pages but most entity/tool pages are missing.
- **Don't list every raw file individually** in reports for exports with 200+ files — group by category and summarize.

---

## Workflow B: Ingest External Article / Q&A

When the user provides an external markdown file (e.g., Google AI Mode Q&A export, technical article):

### Steps

1. **Read the file** — use `read_file` to understand the content and quality.

2. **Compute sha256** of the full content:
   ```python
   import hashlib
   h = hashlib.sha256(open(path, 'rb').read()).hexdigest()
   ```

3. **Save raw source** to `raw/articles/<descriptive-name>.md` with frontmatter:
   ```yaml
   ---
   source_url: <original URL>
   ingested: YYYY-MM-DD
   sha256: <hex digest>
   ---
   ```
   Then append the original content after the frontmatter.

4. **Create or enhance the concept page** in `concepts/<domain>/`:
   - Add `sources:` frontmatter pointing to the new raw file
   - Bump `updated:` date
   - Add provenance markers `^[raw/articles/<name>.md]` on claims from the new source
   - If adding to an existing page, insert the new section logically (don't just append)

5. **Update `log.md`** — append a new entry with format:
   ```
   ## [YYYY-MM-DD] ingest | <short description>
   - **Created:** (raw source files)
   - **Updated:** (concept/entity pages modified)
   - Tags applied: <tag1>, <tag2>
   ```

6. **Update `index.md`** — if creating a new page, add an entry under the correct domain section. Bump `Total pages` count.

7. **Commit and push** — `git add -A && git commit -m '...' && git push`

### Pitfalls

- **Don't overwrite the existing raw source with frontmatter** — write frontmatter first, then append original content
- **Verify the sha256 is from body only** — if the file already has frontmatter from you, hash everything below the closing `---`
- **Use provenance markers** on specific claims, not just the `sources:` frontmatter — `^[raw/articles/foo.md]`
- **Link to existing related pages** using `[[wikilinks]]` — minimum 2 outbound links per page

---

## Workflow C: Create New Wiki Page from Raw Sources

When synthesizing raw source files into a new concept or entity page:

### Steps

1. **Read relevant raw files** to extract key content.
2. **Create page** at appropriate path per SCHEMA.md domain map:
   - `concepts/<domain>/<slug>.md` for concepts
   - `entities/<type>/<slug>.md` for entities (tools, people, companies, models)
3. **Frontmatter**:
   ```yaml
   ---
   title: Page Title
   created: YYYY-MM-DD
   updated: YYYY-MM-DD
   type: concept | entity | comparison | query | summary
   tags: [from SCHEMA.md tag taxonomy]
   sources:
     - raw/articles/source-file.md
   confidence: high | medium | low
   ---
   ```
4. **Body**:
   - Top: `> 🔗 **Key Resources:**` blockquote with curated links
   - Use `[[wikilinks]]` (minimum 2 outbound links)
   - Use provenance markers `^[raw/articles/foo.md]` for multi-source claims
   - Follow wolai.app conventions if relevant: TOC as `## 目录` after H1, child links as `[Title](Child/Child.md "Title")`
5. **Register** in `index.md` under the correct domain section; bump `Total pages`
6. **Log** in `log.md`
7. **Commit and push**

---

## Workflow E: Audit Entity Coverage

When the user asks to find entities, identify missing entity types, or scan what's linked but not yet an entity page:

### Steps

1. **Map the current entity landscape** — check SCHEMA.md for defined entity types vs actual directories:
   ```bash
   ls ~/git/mine/wiki/entities/
   ```
   Also check `index.md` and SCHEMA.md directory map for declared-but-empty entity paths (e.g. `entities/people/`, `entities/models/`).

2. **Count existing entities by type:**
   ```bash
   find ~/git/mine/wiki/entities -name '*.md' | sed 's|.*/entities/||' | cut -d'/' -f1 | sort | uniq -c | sort -rn
   ```

3. **Find frequently-referenced entities that lack pages** — use multiple signals:

   **Signal A: Wikilink references in concept pages.**
   ```bash
   grep -roh 'entities/[^]]*' concepts/ | sed 's/entities\///;s/|.*//;s/\]//' | sort -u | while read ent; do [ ! -f "entities/$ent.md" ] && echo "$ent"; done
   ```
   (Note: this finds things already wikilinked *as entities* — poor signal alone.)

   **Signal B: Proper noun density in raw/ exports.**
   Scan raw export directory names (they match original wolai.app structure) — every subdirectory is a topic/entity the user studied:
   ```bash
   find raw -mindepth 3 -maxdepth 5 -type d | grep -vE 'image$|file$' | sed 's|raw/||' | sort -u
   ```

   **Signal C: Concept page mentions.**
   Search for specific entity-like names across concept pages:
   ```bash
   # People: grep for known names (Karpathy, Hotz, Torvalds, etc.)
   # Models: grep for model names (BERT, Llama, ResNet, GPT-4, etc.)
   # Orgs: grep for org names (NVIDIA, CNCF, ASF, IEEE, etc.)
   # Standards: grep for protocol/standard names (VXLAN, QUIC, WebAssembly, etc.)
   grep -row 'NVIDIA\|CNCF\|ASF\|IEEE\|JetBrains' concepts/ 2>/dev/null | sed 's/.*:/\t/' | sort | uniq -c | sort -rn
   ```

   **Signal D: Raw export directory structure as entity hints.**
   The raw/ export directories mirror the user's original wolai.app structure, which groups by topic. Directories at depth 3-4 often reveal entity categories:
   ```
   raw/artificial-intelligence-export/工具/ → tools that became entities/tools/
   raw/artificial-intelligence-export/项目/ → projects (potential entity type)
   raw/thoughts-export/security/cryptography/ → crypto concepts
   ```

4. **Cross-reference against existing entities** to confirm gaps:
   ```bash
   # Check if a candidate is already an entity
   ls entities/companies/ | grep -i "nvidia"  # no? that's a gap
   ```

5. **Rank candidates by cross-reference frequency**, not by hunches. The most-linked entities are the highest impact to create first.

6. **Identify missing entity types** beyond the two populated types (tools, companies):
   - **People** (`entities/people/`) — notable individuals referenced by name (Karpathy, Hotz, Torvalds, etc.)
   - **Models** (`entities/models/`) — ML model architectures/families (BERT, Llama, ResNet, GPT-4, etc.)
   - **Organizations** (could extend `entities/companies/` or create `entities/orgs/`) — foundations, standards bodies (CNCF, ASF, IEEE, IETF, etc.)
   - **Standards/Protocols** (new entity type or refine existing concepts) — things that are more entity-like than concept-like (WebAssembly, QUIC, VXLAN, FIPS, etc.)

7. **Present findings** in a structured report organized by type, with:
   - Cross-reference count
   - Context cluster (which concept pages reference it most)
   - Suggested entity type and path
   - Priority (high = referenced across 3+ domains)

### Reference Data from 2026-05-13 Scan

For reference, the most-linked missing entities found in a full wiki audit:

| Category | Top Candidates | Ref Count |
|---|---|---|
| People | Andrej Karpathy, George Hotz, Linus Torvalds, Ken Thompson, Guido van Rossum | moderate |
| ML Models | BERT (31), Llama (27), ResNet (15), GPT-4 (9), Stable Diffusion (9) | high |
| Organizations | NVIDIA (32), Oracle (38), JetBrains (19), CNCF (16), IEEE (29), HashiCorp (12), ASF (12), Canonical (10), Elastic (6) | high |
| Protocols/Standards | PCIe (62), VXLAN (45), FIPS (46), QUIC (35), WebAssembly (19), gRPC (15), OAuth (14) | high |

### Pitfalls

- **Not every raw directory is an entity** — some are concept clusters (e.g., `principles-of-containers/` is a topic, not an entity)
- **Tools already have 391 pages** — don't re-create existing tools; focus on missing types (people, models, orgs)
- **SCHEMA.md already defines entity directories** that may be empty (`entities/people/`, `entities/models/`) — these are deliberate design choices, not oversights, and should be populated
- **Don't create pages for passing mentions** — require at least 2+ concept pages referencing the candidate, or it being central to one deep source
- **Raw/ file naming mimics crawled URLs** — the wolai.app structure has deep nesting and duplicates (topic/topic/topic.md); the shallowest instance is canonical

---

## Workflow F: Batch Create Entity Pages

After auditing entity coverage (Workflow E), when the user says "proceed to create all of these":

### Principles

- **Present a proposal first** — show the user what you plan to create, organized by category, before executing
- **Parallelize via `delegate_task`** — each entity type gets its own subagent. This cuts wall-clock time from minutes to seconds for large batches
- **Create dependency-safe batches** — if people pages are referenced by company pages, create them in the same batch or a prior batch
- **Every page must be registered** in `index.md` and `log.md` after creation
- **Git commit per batch**, not per page — reduces conflict risk on shared files

### Step 1: Category Proposal

Before creating anything, present a structured proposal listing:

- **Entity type** and target directory (e.g. `entities/people/`, `entities/models/`, `entities/companies/`)
- **Count** per type
- **Key candidates** with why they qualify (cross-reference count, domain importance)
- **Open questions** — overlaps, naming uncertainties, boundary cases

Wait for user approval before proceeding.

### Step 2: Batch Creation via `delegate_task`

Once approved, create pages in parallel:

```python
# One subagent per entity type
tasks = [
    {
        "context": "Working directory: ~/git/mine/wiki. Follow SCHEMA.md conventions...",
        "goal": "Create 8 entity pages under entities/people/ ..."
    },
    {
        "context": "...",
        "goal": "Create 7 entity pages under entities/models/ ..."
    },
]
result = delegate_task(tasks=tasks)
```

Each subagent must:

1. **Read SCHEMA.md** for frontmatter/entity conventions
2. **Create each page** with proper frontmatter (title, created, updated, type: entity, tags, sources)
3. **Include**: Overview, Key Facts (table), Relationships section with `[[wikilinks]]` (min 2 per page), Sources
4. **Create a category index page** — `entities/<type>/index.md` with a listing table
5. **Update `index.md`** — add entries under the correct section, bump page count
6. **Append to `log.md`** with full file list
7. **Git commit and push**

### Step 3: Content Rules for Entity Pages

Each entity page follows this structure:

```yaml
---
title: Full Name
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: entity
tags: [from SCHEMA.md taxonomy]
sources:
  - raw/<relevant-export>/path.md
confidence: high | medium | low
---
```

**People pages:** Include aliases, birth year, notable achievements, current role, key projects (nanoGPT, Tinygrad, etc.), educational background.

**Model pages:** Include architecture type, parameter count, release date, training data/corpus, variants (LLaMA 1→4, GPT-4→GPT-4o), hardware used. Link to concept pages — DON'T duplicate architecture explanations.

**Company/Organization pages:** Include founded date, founders, HQ, key products, notable acquisitions, revenue/scale context, open-source projects. Link to entity pages for their products.

**Avoid duplication of concept content** — if a concept page exists (e.g. `concepts/ai-ml/bert.md`), the entity page should focus on the *artifact* (release history, variants, impact), not the architecture. Link to the concept page.

### Step 4: Verify and Fix Cross-References

After all subagents complete:

1. **Verify that wikilinks resolve** — check that every `[[entities/...]]` link in the new pages points to a file that was created in this batch or already exists
2. **Fix broken links** — if a subagent referenced a page that doesn't exist (e.g. `entities/tools/lxc` with no `lxc.md`), rewrite it to point to the appropriate concept page instead
3. **Check `index.md`** — confirm all new entities are listed under the correct section comment (e.g. `<!-- People -->`, `<!-- Models -->`, `<!-- Companies -->`)
4. **Update page count** in index.md header to reflect new total

### Pitfalls

- **`delegate_task` subagents timeout at ~600s** — if a batch creates 30+ pages, split into smaller groups (15-20 per subagent max)
- **Subagents don't share state** — each has its own context window. Define all entity content inline in the task goal; don't assume one subagent knows what another created
- **Cross-type references** (e.g. people → companies) may be broken if the referenced entity is in another subagent's batch. Either:
  - Create dependents in a single batch (people + companies together)
  - Or do a follow-up fix pass after all batches complete
- **`log.md` may get multiple appends** from different subagents — the last one to commit wins. Either coordinate via a single subagent doing all logging, or let the final commit handle it
- **File already exists** — the `write_file` tool will overwrite silently. Check `file_exists` first or use a different path
- **After git push failure from one subagent**, subsequent subagents may try to push a stale state. Always `git pull --rebase` before `git push`

---

## Workflow G: Propose Tool Categorization

When the user asks to "group tools by category" or organize `entities/tools/`:

### Step 1: Gather Data

1. **List all tool files:**
   ```bash
   find entities/tools -name '*.md' -not -name 'index.md' -type f | sort
   ```

2. **Extract raw source paths from frontmatter** — the `sources:` field tells you which raw/export domain the tool belongs to:
   ```bash
   for f in entities/tools/*.md; do
     name=$(basename "$f" .md)
     source=$(grep '^sources:' "$f" -A5 | grep 'raw/' | head -1)
     echo "$name|$source"
   done
   ```

3. **Read first paragraph of each file** for a one-line description.

### Step 2: Group by Source Domain + Functional Role

Group tools using two signals:

**Signal A: Raw source directory** — tools from `raw/tools-export/测试/` are testing tools; from `raw/database-export/` are databases; from `raw/network-export/` are network tools; from `raw/operating-system-export/` are OS tools/distros.

**Signal B: Functional description** — infer from the tool's title and first paragraph. Cross-cutting tools (e.g. `nmap` used in both network-tools and security) go in their primary category.

### Step 3: Present Proposal

Produce a structured report with:

```
## Proposed Categories

| # | Category Name | Count | Examples |
|---|---------------|-------|---------|
| 1 | databases/    | 25    | mysql, postgresql, redis, ... |
| 2 | networking/   | 16    | nginx, envoy, traefik, ... |
| ... | ...
```

Include for each category:
- Short description
- Tool count
- Representative examples (5-10)
- Any boundary cases

### Step 4: Flag Open Questions

Before execution, flag decisions the user needs to make:

1. **Overlapping tools** — tools that belong to multiple categories (e.g. nmap → network-tools & security). Options: primary category only, symlinks, or `also-in` frontmatter field
2. **Aggregate pages** — `monitoring-tools.md`, `storage-tools.md`, `text-processing-tools.md` are cross-cutting overview pages that collect related tools. Options: move to `_overviews/`, absorb into category indexes, or keep at root
3. **Compression / multi-category** — `compression-tools` could go in CLI tools, storage, or packaging — flag for user
4. **Migrate vs annotate** — moving files breaks all existing `[[entities/tools/xxx]]` wikilinks. Ask the user whether to (a) move files + fix references, (b) keep in place + add category index pages, or (c) add `category:` to frontmatter without moving

### Pitfalls

- **Don't guess categories based on tool name alone** — always read the frontmatter source path or first paragraph
- **Tools from same raw export may belong to different categories** — `raw/distributed-systems-export/` contains databases (redis, kafka), proxies (nginx), and coordination tools (etcd). Read each individually
- **OS/distro pages** (alpine-linux, debian-ubuntu, freebsd, minix) are not tools in the conventional sense but live in entities/tools/. Group them under an `oss/` or `operating-systems/` category
- **Aggregate overview pages** (e.g. `storage-tools.md`, `api-testing-tools.md`) should not be counted as individual tools for categorization purposes — they describe the category itself
- **Save the proposal to a file** (`entities/tools/CATEGORIZATION-PROPOSAL.md`) so the user can review it asynchronously

---

## Workflow D: Re-Ingest Updated Zip Export

(Original zip re-ingest workflow — see `scripts/fix-top-links.py` and `scripts/sanitize-raw-files.py`)

### Steps

① Extract and Map — use Python's `zipfile.ZipFile` (safe with `&` and other shell meta-chars)
② Build Content Index — match by sha256, not filename
③ Classify Every File — new / renamed / unchanged / deleted
④ Report to User with clear summary
⑤ Execute based on user decision
⑥ Post-Ingest: run `scripts/fix-top-links.py` to sync key resource links

### Pitfalls

- **Don't match by filename** — zip has original names (`TCP.md`), on disk they're sanitized (`tcp.md`)
- **Don't auto-delete wiki pages** — source deletion doesn't mean the page is wrong
- **SHA256 changes for formatting-only edits** — flag but note the caveat
- **Sanitize filenames: lowercase, spaces→hyphens, preserve Chinese/`&`/`()`/Unicode**
- **Rename files BEFORE directories** — rename files first, then directories bottom-up
- **Use `zipfile.ZipFile` not `unzip`** — shell meta-chars break terminal
- **Clean up temp dirs with `shutil.rmtree()`**

---

## References

- `SCHEMA.md` at wiki root — full conventions for frontmatter, tags, paths, provenance markers
- `references/audit-checklist.md` — checklist for auditing raw export directories
- `references/entity-audit-2026-05-13.md` — full entity coverage scan data (393 existing + candidate entities by type with cross-reference counts)
