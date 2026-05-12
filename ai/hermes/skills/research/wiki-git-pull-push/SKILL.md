---
name: wiki-git-pull-push
description: "Git pull-before-write + push-after-write workflow for wiki repos synced across multiple machines. Reduces merge conflicts on append-only files (log.md, index.md)."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos]
metadata:
  hermes:
    tags: [wiki, git, sync, multi-machine, conflict-resolution]
    category: research
    related_skills: [llm-wiki]
---

# Wiki Git Pull-Push Workflow

## When This Skill Activates

This skill activates when you are about to **write to, create, update, or modify any file** in a wiki repository that is synced via Git. This includes:

- Any `llm-wiki` ingest, update, or create operation
- Writing to `log.md`, `index.md`, entity pages, concept pages
- Linting or batch operations that modify wiki files

## Core Rule: Pull Before Write, Push After Write

Every wiki write operation **MUST** follow the sequence:

```
① git pull --rebase        # get latest from remote
② make changes             # create/update wiki files
③ git commit               # commit changes
④ git push                 # push to remote
⑤ if push fails → goto ①  # retry up to 3 times
```

## Wiki Path Resolution

The wiki path is resolved using the same logic as `llm-wiki` (in priority order):

1. `WIKI_PATH` environment variable (e.g. in `~/.hermes/.env`)
2. `skills.config.wiki.path` in `~/.hermes/config.yaml`
3. Default: `~/wiki`

Use `$WIKI` or the resolved path for all git operations.

## The 3-Step Shell Function

```bash
wiki_git_cycle() {
  local msg="$1"
  local wiki="${WIKI:-${WIKI_PATH:-$HOME/wiki}}"
  cd "$wiki" || return 1

  # Step 1: Pull before write
  git pull --rebase 2>&1 || {
    echo "PULL FAILED — manual intervention needed"
    return 1
  }

  # ... (agent makes changes here) ...

  # Step 2: Commit
  git add -A
  git commit -m "${msg:-wiki update}" || true

  # Step 3: Push with retry
  for i in 1 2 3; do
    if git push 2>&1; then
      echo "PUSH SUCCEEDED"
      return 0
    fi
    echo "PUSH FAILED (attempt $i/3) — pulling latest and retrying..."
    sleep 2
    git pull --rebase 2>&1 || return 1
  done

  echo "PUSH FAILED after 3 attempts"
  return 1
}
```

## Typical Session Flow

```python
# Resolve wiki path (consistent with llm-wiki resolution)
import os
wiki = os.environ.get("WIKI") or os.environ.get("WIKI_PATH") or os.path.expanduser("~/wiki")

# Before any wiki operation:
terminal(f"cd {wiki} && git pull --rebase")

# ... agent does wiki work (create pages, update index, append log) ...

# After all changes:
terminal(f"cd {wiki} && git add -A && git commit -m '...' && git push")
```

## Pitfalls

- **If `git pull --rebase` fails** (network issue, unrelated content conflict) — stop and tell the user. Do NOT make changes without pulling.
- **`git push` failure may be permission-related**, not a conflict. After 3 retries, report the error output to the user.
- **Large commits (>20 files) increase conflict risk** — prefer smaller, more frequent commits.
- **`git pull --rebase` without arguments** requires the current branch to have an upstream tracking branch configured (usually set automatically on first clone/push). If not, specify remote and branch explicitly: `git pull --rebase origin main`
- **This skill assumes `log.md` is append-only** — the workflow is most effective when log entries are only added at the bottom, never reordered or rewritten.
