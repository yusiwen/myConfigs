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
