---
name: debug-workflow
description: Standardized workflow for debugging issues, from context gathering to resolution and memory mining.
---

# Debug Workflow

Trigger: user says "debug workflow" or `/debug-workflow`

Follow these steps sequentially to resolve the issue:

1. **Context Gathering**: Run `mem-search` for similar past errors/bugs.
2. **Architecture Assessment**: Use `graphify query` to understand the component architecture involved.
3. **Log Analysis**: Use `context-mode` `ctx_batch_execute` to analyze and extract insights from any logs.
4. **Delegation (Optional)**: If the issue is highly complex, use `openspace execute_task` to delegate sub-investigations.
5. **Resolution**: Apply the fix.
6. **Knowledge Persistence**: After fixing the issue, run `mempalace mine` to record the solution for future reference.
