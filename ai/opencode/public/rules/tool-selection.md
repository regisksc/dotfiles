# Tool Selection Hierarchy

## Decision Tree (execute before any action)

1. **Check for specialized rules first** — If a rule exists for this task type, use it
2. **Default to structured tools** — Prefer `ctx_*` tools over raw Bash for:
   - File reading/searching
   - Data fetching
   - Directory listing
   - Log analysis
3. **Bash whitelist only** — Raw Bash allowed only for:
   - `git` operations
   - Package manager commands
   - Build/test commands
   - File operations (mkdir, cp, mv, rm)

## Blocked Commands (must use ctx_* alternatives)

- `cat` → use `read` tool
- `grep` → use `grep` tool
- `find` → use `glob` tool
- `head/tail` → use `read` with offset/limit
- `curl/wget` → use `webfetch` tool

## Enforcement

This rule fires at session start and before each tool invocation.
