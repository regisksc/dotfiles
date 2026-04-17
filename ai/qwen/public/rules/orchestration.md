# Multi-Agent Orchestration

## When to Dispatch Parallel Agents

Use parallel agents when:
- 2+ independent tasks with no shared state
- Different problem domains (different files, subsystems, bugs)
- Agents won't interfere with each other

Do NOT use when:
- Failures are related (fixing one might fix others)
- Need full system context to understand
- Agents would edit same files or use same resources

## Role Specialization

| Role | Responsibility | When to use |
|------|----------------|-------------|
| **Planner** | Explore, design, write implementation plan | Before any non-trivial implementation |
| **Coder/Executor** | Execute plan, write code | After plan is approved |
| **Reviewer** | Review against original plan and standards | After major steps or completion |
| **Tester** | Generate and run tests | After implementation or for bug fixes |

## Delegation Best Practices

1. **Focused scope:** One clear problem domain per agent
2. **Self-contained context:** All information needed to understand the problem
3. **Specific output:** Define what the agent should return

Example agent prompt:
```
Fix the 3 failing tests in src/agents/agent-tool-abort.test.ts:

1. Test names and what they expect
2. Root cause hypothesis (timing vs actual bugs)

Your task:
1. Read test file and understand what each verifies
2. Identify root cause
3. Fix by [specific approach]

Do NOT change unrelated code.

Return: Summary of what you found and what you fixed.
```

## Human-in-the-Loop Checkpoints

Pause for user confirmation at:
- After plan written, before execution
- After major phase completion
- Before merge/integration
- When encountering unexpected obstacles

## Failure Recovery

After N failed retries:
1. Hand off to user with summary
2. Confirm before irreversible actions
3. Consider alternative approaches

## Worktrees for Isolation

Use git worktrees when:
- Multiple agents working in parallel on same repo
- Experimenting without affecting active branch
- Long-running features coexisting with hotfixes

Commands:
```bash
# Create worktree + branch
git worktree add ../proj-feature -b feature-branch

# List active worktrees
git worktree list

# Remove after merge
git worktree remove ../proj-feature
```
