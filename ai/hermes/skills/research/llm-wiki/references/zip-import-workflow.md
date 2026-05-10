# Zip Import Workflow — Concrete Example

This is a worked example of importing notebook-app ZIP exports into the wiki.
Written from a real session where two large exports were ingested (264 + 184 markdown files).

## Step 1: Examine and Estimate

```bash
# Size up the export
unzip -l ~/Export.zip | awk '...END{printf "Markdown: %d\nImages: %d\nPDFs: %d\n", md, img, pdf}'

# Get the structure
unzip -l ~/Export.zip | tail -n +4 | head -n -2 | awk '{for(i=4;i<=NF;i++) name=(i==4)?$4:name" "$i; print name}' | sort -t/ -k1,1 -u | head -30
```

## Step 2: Extract to Temp

```bash
mkdir -p /tmp/ingest-temp
unzip -o "$HOME/Export.zip" -d /tmp/ingest-temp/  # 300s timeout if large
```

## Step 3: Copy Raw Sources (Python, not terminal)

```python
import shutil, os
SRC = "/tmp/ingest-temp/NotebookID"
RAW = "/home/user/git/mine/wiki/raw/export-name"
extensions = {'.md', '.pdf', '.png', '.jpg', '.jpeg', '.gif', '.svg'}
for root, dirs, files in os.walk(SRC):
    for f in files:
        if os.path.splitext(f)[1].lower() in extensions:
            dest = os.path.join(RAW, os.path.relpath(root, SRC))
            os.makedirs(dest, exist_ok=True)
            shutil.copy2(os.path.join(root, f), os.path.join(dest, f))
```

## Step 4: Scope Check with User

Present: markdown count, major sections, current wiki state.
Ask: full auto, smart subset, or per-section? (Use `clarify` tool with 4 choices.)

## Step 5: Delegate to Subagents

Divide the export's directory tree into logical batches. Each batch = one `delegate_task` call.

**Batch structure (example from Cloud Computing export):**
- Subagent 1: Kubernetes section (~50 source files) → ~12 concept pages
- Subagent 2: Docker/Containers section (~40 source files) → ~8 concept pages
- Subagent 3: Everything else (IaaS, Tools, Architecture, Edge...) → ~30 pages (concepts + entities)

**Context to pass each subagent:**
```
WIKI_PATH=/home/user/git/mine/wiki
```
Plus instructions to read SCHEMA.md, index.md, log.md first.

**Rules to embed in each delegate:**
- lowercase-hyphenated filenames
- YAML frontmatter with title/created/updated/type/tags/sources
- Every page links to 2+ other pages via [[wikilinks]]
- Group related sub-topics into coherent pages (don't flood with tiny pages)
- Write in English (even if source filenames are in Chinese)
- Update index.md and log.md (but see parent-reconciliation pattern below)

## Step 6: Index/Log Reconciliation

**Do NOT let subagents patch index.md and log.md independently.** Parent should:
1. Collect file lists from subagent summaries
2. Patch index.md: add entries under the correct sections, bump total count
3. Append to log.md: one entry per subagent batch
4. Check for formatting artifacts (extra `|` pipes from concurrent edits)

## Step 7: Clean Up

```python
import shutil
shutil.rmtree("/tmp/ingest-temp")
```

## Pitfalls from this Session

- **Zip filenames with `&` (e.g., "Algorithms & Data Structures.zip"):** The shell interprets `&` as a background operator. Terminal tool errors: "Foreground command uses '&' backgrounding." Copy to a safe temp name first via Python `shutil.copy2()`.
- **Terminal timeout on `rm -rf` with 300+ files:** Use `execute_code` with `shutil.rmtree()` instead.
- **Subagent timeout on 600s default:** The third subagent (tools/devices/performance, 30 API calls) hit the 600s timeout. For very large sections, set `child_timeout_seconds` higher or split into smaller batches.
- **Chinese filenames in source:** The export had Chinese directory names like `容器/工具/`. Subagents correctly wrote pages in English but linked back to the raw source path. Works fine.
- **Concurrent index.md edits cause `|` artifacts:** Lines like `||- [[page]]` instead of `|- [[page]]`. The parent must clean these up after all subagents finish.
- **read_file display aliasing:** The `|` column separator makes it look like lines have `||` prefix. Use `sed -n '5p' file | cat -A` to verify actual content.
