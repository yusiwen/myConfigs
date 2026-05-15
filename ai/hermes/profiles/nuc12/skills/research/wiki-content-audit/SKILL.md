---
name: wiki-content-audit
description: "Survey raw export directories in the wiki for a specific content type (comparisons, entities, concepts, etc.), categorize findings, and produce an inventory — without making any changes. Complements wiki-reingest and llm-wiki: audit first, then decide what to ingest."
version: 1.2.0
author: Hermes Agent
platforms: [linux, macos]
metadata:
  hermes:
    tags: [wiki, audit, survey, inventory, organization]
    category: research
    related_skills: [llm-wiki, wiki-reingest, wolai-export-schema, wolai-export-mapping]
---

# Wiki Content Audit

When the user wants to find all content of a specific type (comparisons, entities, concepts, tools, etc.) across the raw export directories — before deciding what to ingest — use this workflow.

## Principles

- **Audit before ingestion** — inventory first, then decide which items become wiki pages. The user has seen the full landscape and can prioritize.
- **Multi-pass search** — filenames alone miss content that uses comparison language. Use at least two passes: filename patterns + heading/content patterns.
- **Categorize by domain** — group findings by their natural domain (AI/ML, networking, databases, etc.), which maps directly to wiki sub-categories like `comparisons/ai-ml/`, `comparisons/networking/`.
- **Distinguish full docs from sections** — a page entirely about a comparison (title says "A vs B") is a stronger candidate than a section within a larger page.
- **Verify candidates** — read the first few lines of each candidate to confirm it really is a comparison (or whatever content type you're hunting). Filename/h1 alone can be misleading.

## Workflow Steps

### ① Establish the Baseline

Before scanning raw exports, check what already exists in the wiki for this content type:

```bash
# Check index.md for existing category listing
read_file "$WIKI/index.md"

# Check the category directory directly
find "$WIKI/comparisons" -type f -name '*.md' 2>/dev/null | wc -l
```

Record the "before" state so the user knows what's new vs already ingested.

**⚠️ Important:** The user's perception of "what exists" may be outdated due to recent bulk ingests. Also check `log.md` for the most recent ingest events:

```bash
# Check what was recently added — the last 5 creation entries
grep -E '^## \[|create \|' "$WIKI/log.md" | tail -10
```

This avoids chasing phantom gaps. If the last ingest was days ago, the user's perception is likely accurate. If it was today or yesterday, their count may be stale.

### ② Multi-Pass Search of Raw Exports

#### Pass 1: Filename/Path Pattern Matching

Search for the content type keyword in file and directory names:

```bash
find "$WIKI/raw" -type f -name '*.md' | \
  grep -iE '(vs|对比|compar|versus|区别|差异|选择|优缺点|优劣|比较|diff\b)' | \
  grep -v '/image/' | grep -v '/file/' | sort
```

For broader recall, also match directory names:

```bash
find "$WIKI/raw" -type d | grep -iE '(vs|对比|compar)' | sort
```

#### Pass 2: Heading Content Matching

Search for the content type appearing in markdown headings (h1, h2, h3):

```bash
rg -n '^#+ .+ (vs|VS|versus|对比|比较|区别|差异|优势|choose|compar|difference) .+' \
  --type md "$WIKI/raw/" 2>/dev/null | \
  grep -v '/image/' | grep -v '/file/' | sort -t: -k1,1 -u
```

**⚠️ False-positive filtering:** Filenames containing `vs` often match individual tool names that are NOT comparisons:
- `ovs.md` (Open vSwitch) — a tool, not `OVS vs XY`
- `lvs.md` (Linux Virtual Server) — a tool, not `LVS vs XY`  
- `ipvs.md` (IP Virtual Server) — a tool, not `IPVS vs XY`
- `vscode.md` (Visual Studio Code) — an IDE, not `VS vs Code`

Always verify matches by reading context around the match, not just the filename.

#### Pass 3 (recommended): Chinese Comparison Phrases in Body Content

Comparison topics in Chinese notes often use natural-language patterns rather than explicit "vs" markers. These are the most productive search — they catch entire classes of comparison content (database selection, APM tooling, config centers, MQ evaluation) that heading searches miss:

```bash
rg -n '与.*相[比比]|的区别$|的区别\b|优缺点|优劣对比|哪个好|选哪个|对比分析|对比表|比较表|vs方案|替代方案|选型' \
  --type md "$WIKI/raw/" 2>/dev/null | \
  grep -v '/image/' | grep -v '/file/' | cut -d: -f1 | sort -u
```

This catches content like "MySQL与PostgreSQL相比哪个更好", "配置中心选型", "APM方案选型".

#### Pass 4 (optional): Selection/Evaluation Section Headings

Some documents have explicit "选型" (selection/tool evaluation), "方案对比" (plan comparison), or "优缺点" (pros/cons) sections — strong signals of comparison content:

```bash
rg -n '^##.*[选选]型|^###.*[选选]型|^##.*方案对比|^###.*方案对比' \
  --type md "$WIKI/raw/" 2>/dev/null | \
  grep -v '/image/' | grep -v '/file/'
```

#### Pass 5 (optional): Table Detection

Comparison content often uses markdown tables. Use this only when other passes miss obvious candidates — it's noisy:

```bash
rg -l '^\|.*\|.*\|$' --type md "$WIKI/raw/" 2>/dev/null | \
  grep -v '/image/' | grep -v '/file/'
```

### ③ Verify Candidates

For each candidate file, confirm it's genuinely about comparison content. Use the **TOC-based deep verification** technique — more reliable than reading just the first few lines:

```python
# Extract TOC and scan for comparison indicators
for path in candidates:
    result = read_file(path, limit=200)
    lines = result['content'].split('\n')
    
    # Extract TOC (items under ## 目录)
    toc_items = []
    in_toc = False
    for l in lines:
        if l.strip() == '## 目录':
            in_toc = True
            continue
        if in_toc:
            if l.strip().startswith(('- [', '* [')):
                toc_items.append(l.strip())
            elif l.strip().startswith('##') and '目录' not in l:
                break
    
    # Scan for comparison indicators throughout content
    comp_hits = [l for l in lines if any(kw in l.lower() 
        for kw in [' vs ', '对比', '比较', 'versus', 'difference'])]
    
    # Check if H1/H2 headings contain comparison language
    headings = [l for l in lines if l.startswith('# ')]
    h2s = [l for l in lines if l.startswith('## ')]
    has_comp_heading = any('vs' in h.lower() or '对比' in h or '比较' in h 
                          for h in headings + h2s)
    
    # Decision:
    if has_comp_heading and len(comp_hits) >= 3:
        type = "Full doc"  # whole page is the comparison
    elif has_comp_heading or len(comp_hits) >= 3:
        type = "Section"   # comparison is a subsection
    else:
        type = "Marginal"  # flag for review
```

### ④ Categorize Findings

Group verified candidates by:

| Dimension | What to capture |
|-----------|----------------|
| **Export source** | Which raw/ subdirectory (network-export, thoughts-export, etc.) |
| **Domain** | AI/ML, Networking, Databases, Programming, DevOps, Security, etc. |
| **Type** | Full doc (entire page is about the comparison) vs Section (§ within a larger page) |
| **Title** | What the comparison actually compares |
| **Topic** | Brief description of what's being compared |
| **Size hint** | Total lines (optional, helps estimate effort) |

### ⑤ Present the Inventory

Structure the output clearly:

```
=== EXISTING WIKI PAGES ===
comparisons/<domain>/<page> — <topic>

=== RAW COMPARISON CONTENT FOUND ===

== Full Documents ==
#1 | raw/<export>/<path> | <Topic A vs Topic B>

== Sections Within Documents ==
#2 | raw/<export>/<path> | <Topic A vs Topic B> | at heading "## X vs Y"
```

If there are many items, group by domain with sub-headings. The user can then prioritize which to ingest.

## Post-Audit: Creating Wiki Pages from Audit Findings (Bulk Ingest)

When the user reviews the inventory and says "add all of them" (or selects a subset), follow this workflow to create wiki pages from the audited raw content.

> **Related:** For the downstream mapping pipeline — resolving page IDs, detecting drift between Wolai and local copies, and syncing changes — see `wolai-export-mapping` skill (research category). The audit feeds into the mapping, and the mapping enables change detection.

### Prerequisites

- The audit is complete (you have a categorized inventory of findings)
- The user has confirmed which items to create pages for
- You've already pulled the git repo (see `wiki-git-pull-push` skill)

### Workflow

#### ① Organize by Domain Sub-Category

Create sub-category directories under the content type (e.g., `comparisons/`) matching the domains from your audit:

```python
import os
wiki = "/home/yusiwen/git/mine/wiki"
domains = ["ai-ml", "networking", "databases", "programming", ...]
for d in domains:
    os.makedirs(f"{wiki}/comparisons/{d}", exist_ok=True)
```

Map each audited item to its domain sub-category. Use existing wiki naming conventions from SCHEMA.md.

#### ② Read Raw Source Content

For each item, read the raw source file to extract or reference the content. Use batch `read_file` calls:

```python
from hermes_tools import read_file

sources = {
    "page-name": "/home/yusiwen/git/mine/wiki/raw/<export>/<path>.md",
    ...
}
for name, path in sources.items():
    result = read_file(path, limit=200)
    # Store for page creation
```

### Handling Different Source Types

Not all comparison findings are equal. Handle each type differently:

#### Full Docs (dedicated comparison files)

The entire raw file is about the comparison. Read the full content, distill into a wiki page with comparison tables.

#### Sections Within Documents

The comparison is a subsection of a larger document. Read the parent file, identify the comparison section boundaries (find the heading, then find the next heading of the same level or end of file), and extract just that portion.

**To find section boundaries:**

```python
lines = content.split('\n')
section_start = -1
section_end = -1
for i, l in enumerate(lines):
    if '## Comparison Heading' in l:
        section_start = i
    if section_start >= 0 and i > section_start + 1:
        if l.strip().startswith('## '):
            section_end = i
            break
if section_end < 0:
    section_end = len(lines)
section_content = '\n'.join(lines[section_start:section_end])
```

#### External Link Collections

Some raw files are just link collections — the original author bookmarked comparison articles rather than writing inline content (e.g., "数据库选型" linking to "Percona vs MariaDB", "配置中心选型" linking to multiple config center comparisons). For these:

- **Create the wiki page** synthesizing the comparison from your knowledge
- Use the external links as `sources:` in the frontmatter
- Add a "Further Reading" section pointing to the original links
- Do NOT just dump URLs into the page content — write actual comparison content

#### Already-Ingested Content (Extraction)

When comparison content already exists as a section within an existing wiki concept page, **extract it** into a standalone comparison page and leave a `[[wikilink]]` in its place.

See the section below: **⑥ Extract Embedded Content from Existing Wiki Pages**.

#### ③ Create Wiki Pages

Each page needs:
- **YAML frontmatter** — title, created/updated (today), type, tags, sources (pointing back to the raw file)
- **Content** — comparison table or structured sections. Use markdown tables for side-by-side comparisons.
- **Cross-references** — at least 2 `[[wikilinks]]` to existing wiki pages

Use `write_file` to create each page. Batch to minimize round-trips:

```python
from hermes_tools import write_file

today = "2026-05-13"
wiki = "/home/yusiwen/git/mine/wiki"

for name, content in pages.items():
    domain = domain_map[name]
    path = f"{wiki}/comparisons/{domain}/{name}.md"
    write_file(path, content)
```

**Frontmatter template:**

```yaml
---
title: A vs B Comparison
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: comparison
tags: [comparison, <domain>, <tag1>, <tag2>]
sources:
  - raw/<export>/<path>.md
---
```

**Content patterns:**
- **Comparison tables** — use markdown tables with columns for each subject, rows for comparison dimensions
- **Selection guides** — add a "When to Use Each" section with practical guidance
- **Key differences** — highlight the most important distinctions rather than exhaustive lists

#### ④ Update index.md

Add entries under the correct sub-category section. Each entry follows the existing format:

```
- [[comparisons/<domain>/<page-slug>|<Display Title>]] — One-line description.
```

Also:
- Bump the total page count in the index header
- Update "Last updated" date

#### ⑤ Update log.md

Append a single log entry covering the batch:

```
## [YYYY-MM-DD] create | <Content Type> pages from raw exports
- **Created:** N wiki pages across M sub-categories:
  - `comparisons/<domain>/` — page1, page2, page3
  - ...
- **Updated** `index.md` — M new sub-category sections, N new index entries
- **Bumped** total page count: X → Y
```

#### ⑦ Git Commit and Push

Follow the `wiki-git-pull-push` skill: commit with a descriptive message, push with up to 3 retries.

> ⚠️ **Duplicate skill name collision:** If loading `wiki-git-pull-push` fails with "Ambiguous skill name: N skills match across local skills dir and external_dirs", it means a duplicate exists. Profile-local skills take precedence over external_dirs. To fix, delete the stale copy from the profile's skills dir: run `rm -rf ~/.hermes/profiles/<profile>/skills/<category>/<skill-name>/`, then reload the skill by name. The remaining copy (shared from git) will resolve cleanly.

### ⑦ Extract Embedded Content from Existing Wiki Pages

When existing concept/entity wiki pages contain comparison sections that should be standalone comparison pages, use this extraction workflow.

**Signal:** The concept page has a `##` heading like `## RDBMS vs NoSQL`, `## Prefill vs Decode`, or `## Comparison vs. Non-Comparison Sorting`.

#### Extraction Workflow

1. **Read the source page** — get its full content with `read_file(path, limit=<total_lines>)`
2. **Identify section boundaries** — find the comparison heading, then find the next `##` (or end of file)
3. **Create the standalone page** — with frontmatter, the extracted content, and `sources:` pointing to the concept page
4. **Modify the original page** — replace the comparison section with a `[[wikilink]]` back to the new standalone page
5. **Update index.md** — add the new page under the appropriate Comparisons section
6. **Update log.md**

#### Example: Extraction Code

```python
# Step 1-2: Find section boundaries
from hermes_tools import read_file

orig = read_file(f"{wiki}/concepts/database/database-overview.md")
lines = orig['content'].split('\n')

section_start = -1
for i, l in enumerate(lines):
    if '## RDBMS vs NoSQL' in l:
        section_start = i
        break

# Find next ## heading to mark end of section
section_end = len(lines)
for i in range(section_start + 1, len(lines)):
    if lines[i].strip().startswith('## '):
        section_end = i
        break

section_content = '\n'.join(lines[section_start:section_end])

# Step 3: Create standalone page
standalone = f"""---
title: RDBMS vs NoSQL
created: {today}
updated: {today}
type: comparison
tags: [comparison, databases, rdbms, nosql]
sources:
  - concepts/database/database-overview.md
---

{section_content.lstrip('#').strip()}
"""
write_file(f"{wiki}/comparisons/databases/rdbms-vs-nosql.md", standalone)

# Step 4: Modify original — replace section with wikilink
new_lines = []
skip = False
for i, l in enumerate(lines):
    if l.strip() == '## RDBMS vs NoSQL':
        skip = True
        new_lines.append('## RDBMS vs NoSQL')
        new_lines.append('')
        new_lines.append('See the dedicated comparison page: [[comparisons/databases/rdbms-vs-nosql|RDBMS vs NoSQL]].')
        continue
    if skip:
        if l.strip().startswith('## ') or i >= len(lines) - 1:
            skip = False
            new_lines.append(l)
        continue  # skip section content
    new_lines.append(l)

write_file(f"{wiki}/concepts/database/database-overview.md", '\n'.join(new_lines))
```

#### Pitfalls of Extraction

- **Don't lose frontmatter** — the original concept page may have its own frontmatter (which should stay). The extracted page gets new frontmatter.
- **Maintain context** — the extracted section may reference content above it (definitions, diagrams). Include a brief context sentence or wikilink to the parent page.
- **Check for wikilinks** — the extracted section may contain `[[wikilinks]]` to other pages. Keep them in the new standalone page — they work fine from any location.
- **Update index.md title** — the concept page's index entry may reference the comparison section. Update it to point to the new standalone page.
- **Don't extract if the section is integral** — if the comparison section is tightly coupled to content above/below it (e.g., a paragraph references "as discussed in the comparison section below"), consider keeping it in place and just adding a `[[see also]]` link instead.

### Comparison Page Template (Concrete Example)

Use this exact format for comparison wiki pages. Each page should have: intro context → option descriptions → comparison table → guidance:

```yaml
---
title: A vs B Comparison
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: comparison
tags: [comparison, <domain>, <tag1>, <tag2>]
sources:
  - raw/<export>/<path>.md
---
```

```markdown
# A vs B Comparison

Brief context paragraph explaining why this comparison matters and when you'd encounter these options.

## Option A

- Trait 1 description
- Trait 2 description
- Best for: scenario X

## Option B

- Trait 1 description
- Trait 2 description
- Best for: scenario Y

## Key Differences

| Aspect | Option A | Option B |
|--------|----------|----------|
| Dimension 1 | Values | Values |
| Dimension 2 | Values | Values |
| Typical use case | Scenario | Scenario |

## Guidance

- Use **Option A** when: situation 1, situation 2
- Use **Option B** when: situation 3, situation 4
- Note any edge cases or hybrid approaches
```

### Raw Export Path Pitfall: Unpredictable Directory Names

The 14 `raw/*-export/` directories use **Chinese-named subdirectories** that don't match English expectations. A file you expect at `raw/network-export/protocols/ip/ip.md` may actually be at `raw/network-export/协议/ip/ip.md`. The parent task's path hints are almost always wrong.

**Always verify with `search_files` before assuming a path.** Search by leaf filename — more reliable than guessing the directory hierarchy:

```python
# Instead of guessing the English path:
# ❌ read_file("raw/network-export/protocols/dns/dns.md")
# ✅ search_files("dns.md", path="raw/network-export", target="files")
# ✅ search_files("递归", path="raw/network-export", file_glob="*.md")
```

The Chinese subdirectory names follow the original Wolai page titles. Common patterns:

| English Expectation | Actual Chinese Name |
|---|---|
| `linux/` | `发行版/` or `内核/` |
| `protocols/` | `协议/` |
| `devices/` | `设备/` |
| `processes/` | `进程/` |
| `filesystem/` | `文件系统/` |
| `security/` | `安全/` |
| `tools/` | `工具/` |
| `frameworks/` | `框架/` |

### Parallel Batch Creation via delegate_task

For bulk ingest (10+ pages), delegate to parallel subagents. This is the fastest approach:

```python
from hermes_tools import delegate_task

delegate_task(tasks=[
    {
        "goal": "Create 8 comparison pages under comparisons/networking/...",
        "context": "Source paths, format template, tags...",
        "toolsets": ["file", "search", "terminal"],
    },
    # ... up to 3 parallel tasks
])
```

**Key requirements:**
- Pass the exact page format template in `context` so all subagents produce consistent output
- Include **SCHEMA.md filename conventions** in context
- Include a **fallback instruction**: if source file not found, write from domain knowledge
- **DO NOT trust subagent self-reports** — verify file creation by listing the directory after
- After all subagents finish, update `index.md` and `log.md` centrally
- One commit per ingest session

### Verify Subagent Claims

Subagents are good workers but unreliable reporters. Always verify side-effect claims:

```python
# After delegate_task returns "all pages created"
# Don't trust the self-report — check the filesystem
by subdir = sorted(os.listdir(f"{wiki}/comparisons/{subdir}"))
```

### Numbering Consistency

Keep a running count of all pages to report accurately:

```python
total = len(list(cmp.rglob("*.md"))) - 1  # subtract index.md itself
new_count = total - pre_count
```

Don't assume arithmetic — let the filesystem be the source of truth.

## Supporting Files

| File | Purpose |
|------|---------|
| `references/html-extraction-via-curl.md` | HTML-to-text extraction via curl+Python when the browser tool is unavailable (Chrome sandbox fails in headless/VM environments). Use for extracting docs/research content from static web pages. |

## Efficiency Patterns for Large Batches

- **Batch reads** — use 5-10 `read_file` calls per `execute_code` block rather than one per block
- **Batch writes** — use 8-15 `write_file` calls per `execute_code` block
- **Index/log updates** — do these as single patch operations, not per-page updates
- **De-duplicate nested paths** — raw exports often have triply-nested paths (file in dir of same name in dir of same name). Pick the shortest unique path or the one closest to the leaf.

### Entity Page Creation from Concept Pages

When you create (or update) a **concept page** for a notable **software tool, runtime, library, model, company, or person**, check whether it also qualifies for an **entity page** under `entities/`. This provides the **3-layer coverage pattern**:

```
raw/<export>/xxx.md          ← Source snapshot (raw export)
concepts/<domain>/xxx.md     ← Deep explanation (architecture, usage, security)
entities/tools/xxx.md         ← Fast index (key facts, relationships, cross-links)
```

**When to create an entity page:**
- The topic is a **named tool** (gVisor, React, Vite, Docker, etc.)
- The topic is a **company or organization** (Google, Cloudflare, etc.)
- The topic is a **person** (Linus Torvalds, Guido van Rossum, etc.)
- The topic is a **published model** (GPT-4, Llama 3, etc.)

**When NOT to create an entity page:**
- The topic is a **concept** (e.g., "OCI Specifications", "Container Security" — these are concepts, not entities)
- The topic is a **comparison** (use the `comparisons/` directory instead)
- The topic is already covered by an entity page of a different name (e.g., don't create "LLaMA" as both a model entity and a tool entity)

**Entity page structure (follow the React pattern):**

```yaml
---
title: Tool Name
created: YYYY-MM-DD
updated: YYYY-MM-DD
type: entity
tags: [<domain>, <category>, ...]
sources:
  - concepts/<domain>/<concept-page>.md     # ← Link back to the concept page
  - raw/<export>/<path>.md                    # ← Link to the raw source
---
```

```markdown
# Tool Name

**Short description** — one-sentence elevator pitch.

## Overview

- **Type**: What kind of thing is it (application kernel / UI library / build tool / etc.)
- **Released**: Year or date of first release
- **Language**: Primary implementation language
- **License**: Open-source license
- **Website**: [link](...)
- **GitHub**: [link](...)

## Architecture (quick reference)

| Component | Role |
|-----------|------|
| ... | ... |

A compact table or bullet list covering the main architectural components.

## Integrations / Ecosystem

| Platform | Integration |
|----------|-------------|
| ... | ... |

## Alternatives

- **Alternative A** — One-line description
- **Alternative B** — One-line description

## See Also

- [[concepts/<domain>/<concept-page>|Tool Name]] — Detailed concept page
- [[entities/tools/<category>/<related>|Related Entity]] — ...
```

**Workflow:**
1. The concept page already exists (you just created or updated it)
2. Check if the concept is a notable entity (see criteria above)
3. Create the entity page under the correct `entities/tools/<category>/` subdirectory
4. Add `[[wikilink]]` from the entity page's "See Also" back to the concept page
5. Add `[[wikilink]]` from the concept page's "Related Pages" to the entity page
6. Update `index.md` under the correct Entities section, and bump the total page count
7. Append entry to `log.md`
8. Commit and push

**Existing entity categories:**
- `entities/tools/ai-ml-frameworks/` — ML/AI frameworks (PyTorch, TensorFlow, vLLM, etc.)
- `entities/tools/container-vm/` — Containers & VMs (Kubernetes, KVM, gVisor, etc.)
- `entities/tools/network-services/` — Network services (Envoy, WireGuard, etc.)
- `entities/tools/network-diagnostics/` — Network diagnostic tools (tcpdump, nmap, etc.)
- `entities/tools/security-auth/` — Security & auth (iptables, OpenSSH, etc.)
- `entities/tools/web-app-frameworks/` — Web frameworks (React, Vue, Next.js, etc.)
- `entities/tools/build-systems/` — Build systems (Makefile, etc.)
- `entities/tools/code-editors/` — Code editors (CLion, etc.)
- `entities/tools/perf-debug/` — Performance & debugging (Delve, etc.)
- `entities/tools/shells-scripting/` — Shells & scripting (zsh, etc.)
- `entities/tools/sysadmin-utils/` — Sysadmin utilities (lsof, logrotate, etc.)
- `entities/tools/test-quality/` — Testing & quality (Playwright, JUnit, etc.)
- `entities/people/` — Notable individuals
- `entities/models/` — ML models

If no existing category fits, choose the closest one. The user can reorganize later.

### Content Quality: Research Standalone Reusability

When creating a concept page about a library, runtime, or component, check whether any of its **sub-components** have standalone usage outside the parent project. This is easy to miss because official docs typically describe sub-components as internal architecture, even when they're independently reusable.

**Signal:** A component has a separately documented library, a standalone GitHub repo, or a `pkg/` directory that can be imported independently.

**How to check:**
1. Scan the official docs' first 1-2 paragraphs for phrases like "can be used independently", "standalone library", "separate module"
2. Check if sub-packages are importable as their own Go modules / PyPI packages
3. Search for real-world projects that depend on the sub-component (e.g., `go.mod` imports, `requirements.txt`)
4. Distinguish: is the sub-component *only* used internally, or is it published as a standalone library?

**Example — gVisor's netstack:**
- Official docs: "netstack can be used independently as a userspace network stack"
- `google/netstack` → standalone Go module ("IPv4 and IPv6 userland network stack")
- Cloudflare's `slirpnetstack` → imports `gvisor.dev/gvisor/pkg/tcpip/...` as a library

**Structure in the page:**
Separate "Inside X" from "Outside X" with clear subsections, so the reader immediately sees both roles:

```markdown
### Component (Standalone Usage)

**Inside the parent project:** how it's used internally.
**Independent usage:** how other projects adopt it as a standalone library.
```

**Why this matters:** Without this check, the reader may conclude the component is tightly coupled, never realising it's a reusable library. The official announcement/blog post for the parent project may not mention standalone usage — you have to find the sub-project's own docs.

### Pitfalls for Bulk Creation

- **Verify before creating** — filenames can be misleading (e.g., `git-diff.md` is a command reference, not a comparison). Always read the first few lines of a raw file before creating a wiki page from it.
- **Frontmatter YAML must be valid** — JSON code blocks inside `.format()` strings cause `KeyError`. Use string concatenation or escaped braces (`{{ }}`) when the page content contains curly braces. Alternatively, avoid `.format()` and use f-strings or concatenation.
- **Respect the wiki's filename convention** — lowercase, spaces-to-hyphens, preserve special chars (Chinese, parens, ampersands). Read SCHEMA.md, don't rely on memory alone.
- **Don't add the `|` pipe prefix** — the `read_file` output format (`LINE_NUM|CONTENT`) is display-only. When patching log.md or index.md, the actual file content does NOT start with `|`.
- **Survey first, act second** — the user wants a comprehensive inventory before any writes, as the question "give me a list before doing anything else". Do the multi-pass search, present the full categorized list, then wait for the go-ahead. This applies even when the user seems to be asking for both in one message — the survey naturally splits into two turns.
- **Don't re-ask for each item in a confirmed batch** — once the user says "ingest these into the wiki" after seeing the inventory, proceed with all items. Do not pause after each one to ask "ok, next?".
- **Clustering subagents by export** — for 30+ items, delegate_task with 3 parallel subagents, each handling one export cluster (e.g., network, OS, programming-languages). Within each subagent's task context:
  - Provide a template markdown page showing exact format
  - Include SCHEMA.md filename convention excerpt
  - Include the fallback instruction: "if source file not found, write from domain knowledge"
  - Warn about Chinese-named subdirectories and give the common pattern table (see "Raw Export Path Pitfall" above)
  - **Do NOT trust subagent self-reports** — always verify by listing the created files after delegate_task returns
- **Subagent source-path verification** — subagents cannot be trusted to find correct source files on the first try. Their task context must include:
  - "Use `search_files` to find each source file by leaf filename before reading — don't assume the path is correct"
  - "If the first `read_file` returns a 404/error, use `search_files` to locate the actual file"
  - "The raw exports use Chinese-named subdirectories — see the pattern table below"
- **One commit per batch** — don't create 35 individual commits for 35 pages. Batch all creations into one commit with a descriptive message.
- **Handle JSON in page content** — when your wiki page contains JSON code blocks, the `{` and `}` in the JSON will be interpreted as `.format()` placeholders. Use raw string concatenation instead of `.format()`, or escape braces as `{{` and `}}`.
- **Don't over-ask user for confirmation on each item** — once they say "add all," the decision is made. Proceed to create all pages without pausing at each one.
- **Deduplicate duplicates** — raw exports often have nested duplicates (e.g., `raw/network-export/.../comparison/comparison.md` and `raw/network-export/.../comparison.md`). Pick the shortest unique path or the one closest to the leaf.
- **Watch for duplicate paths from nested zip structures** — some notebook exports create triply-nested filename directories (file.md contained in a dir with the same name, contained in another dir with the same name). Use Python's `set()` to filter these.
- **Handle the scale** — with 3,600+ raw files in 14 export dirs, avoid O(n^2) operations in search passes. Use ripgrep (`rg`) over `grep -r` for content searches — rg is 10-100x faster.
- **Don't limit to one export dir** — the user may have comparison content spread across multiple exports (thoughts-export has security comparisons, network-export has protocol comparisons). Sweep all directories.
- **Check the articles directory too** — `raw/articles/` contains curated external sources that may include comparison content.
