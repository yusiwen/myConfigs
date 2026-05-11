---
description: "Initializes or refreshes the codebase report. Usage: /codebase [refresh]"
model: deepseek/deepseek-v4-flash
subtask: true
---
Check the value of the provided argument: "$ARGUMENTS".

1. If "$ARGUMENTS" is "refresh":
   - Use !`git diff --stat HEAD~1` to see what changed since the last update.
   - Update the existing `CODEBASE.md` with these changes. Do NOT rewrite the whole file.

2. If "$ARGUMENTS" is empty or not "refresh":
   - Perform a full scan of the project structure and core logic.
   - Create or completely overwrite `CODEBASE.md` with a comprehensive map of the codebase.

Ensure the final report includes the architecture, entry points, and key modules.

Ensure the final report uses the same language used in project's AGENTS.md.
If there is no AGENTS.md in the project yet, default language is English.
