# Memory Usage Strategy

## Auto Memory Location

Memory directory: `~/.claude/projects/-<project-name>/memory/`

- `MEMORY.md` - Always loaded, working memory (keep under 200 lines)
- Topic files (e.g., `debugging.md`, `patterns.md`) - Detailed notes linked from MEMORY.md

## What to Save

**Save:**
- Stable patterns confirmed across multiple interactions
- Key architectural decisions and important file paths
- User preferences for workflow, tools, communication
- Solutions to recurring problems
- Explicit user requests to remember (e.g., "always use bun")

**Do NOT save:**
- Session-specific context (current task, temporary state)
- Unverified conclusions from single file reads
- Anything contradicting CLAUDE.md instructions
- Speculative information

## How to Save

1. Organize by topic, not chronologically
2. Use Write/Edit tools to update memory files
3. Update or remove memories that are wrong or outdated
4. Check for existing memory before creating new one (avoid duplicates)

## Memory Workflow

```
1. Search existing memory first
2. Verify against project docs if uncertain
3. Update or create memory entry
4. Link from MEMORY.md if new topic file
```

## When to Consult Memory

- Starting new session on same project
- User references previous work ("like we did before")
- Need to verify established patterns
- User asks "did we already solve this?"

## Correction Protocol

When user corrects something stated from memory:
1. Find the incorrect entry in memory files
2. Update or remove it immediately
3. Confirm the correction to user

This prevents same mistake from repeating in future conversations.
