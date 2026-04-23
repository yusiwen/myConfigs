---
description: git commit and push
model: opencode/minimax-m2.5-free
subtask: true
---

git commit and push

make sure it includes a prefix at the beginning of the first line in the message

Here are the prefixes you can choose from:

- build: Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
- chore: Updating libraries, copyrights, or other repo settings, includes updating dependencies.
- ci: Changes to our CI configuration files and scripts (example scopes: Travis, Circle, GitHub Actions)
- docs: Non-code changes, such as fixing typos or adding new documentation (example scopes: Markdown files)
- feat: A commit of the type feat introduces a new feature to the codebase
- fix: A commit of the type fix patches a bug in your codebase
- perf: A code change that improves performance
- refactor: A code change that neither fixes a bug nor adds a feature
- style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc.)
- test: Adding missing tests or correcting existing tests

prefer to explain WHY something was done from an end user perspective instead of
WHAT was done.

do not do generic messages like "improved agent experience" be very specific
about what user facing changes were made

if there are conflicts DO NOT FIX THEM. notify me and I will fix them

## GIT DIFF

!`git diff`

## GIT DIFF --cached

!`git diff --cached`

## GIT STATUS --short

!`git status --short`
