# Global Agent Rules

## Initialization Workflow (Warm-Start)
- **Priority Action:** Before you perform a full scan or re-analysis of any codebase, check if a file named `CODEBASE.md` exists in the current project root.
- **Context Loading:** If it exists, read it immediately. Use its contents as your primary map for the project's architecture, entry points, and recent state.
- **Scan Bypass:** Do not perform an expensive whole-repo analysis if the information in `CODEBASE.md` is sufficient for the user's initial request.

