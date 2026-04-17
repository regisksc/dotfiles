# Skills and Rules Catalog

## Current Rules (~/.claude/rules/)

| File | Purpose | When Applied |
|------|---------|--------------|
| `agent-guardrails.md` | Core guardrails for safety and control | Always |
| `user-authority-scope.md` | User authority, git rules, minimal scope | Always |
| `development-workflow.md` | Plan-first, TDD, acceptance criteria | Development tasks |
| `orchestration.md` | Multi-agent patterns, delegation | When using agents/subagents |
| `memory-usage.md` | How to use auto memory | When context spans sessions |
| `flutter-dart.md` | Flutter/Dart conventions | Flutter projects |

## Skills Usage (Superpowers Plugin)

### Process Skills (use BEFORE implementation)

| Skill | When to Use | Command |
|-------|-------------|---------|
| `superpowers:using-superpowers` | Start of any conversation | Auto-loaded |
| `superpowers:brainstorming` | Before creative work, adding features, modifying behavior | `/brainstorm` |
| `superpowers:writing-plans` | Multi-step tasks with spec/requirements | `/write-plan` |
| `superpowers:dispatching-parallel-agents` | 2+ independent tasks | Manual dispatch |

### Implementation Skills

| Skill | When to Use | Command |
|-------|-------------|---------|
| `superpowers:test-driven-development` | Implementing features/bugfixes, before writing code | `/tdd` |
| `superpowers:executing-plans` | Executing written implementation plan | `/execute-plan` |
| `superpowers:subagent-driven-development` | Independent tasks in current session | Manual |
| `superpowers:using-git-worktrees` | Feature work needing isolation | `/worktree` |

### Review & Completion Skills

| Skill | When to Use | Command |
|-------|-------------|---------|
| `superpowers:requesting-code-review` | Completing tasks, before merging | `/review` |
| `superpowers:receiving-code-review` | Processing review feedback | Manual |
| `superpowers:finishing-a-development-branch` | Implementation complete, tests pass | Manual |
| `superpowers:verification-before-completion` | Before claiming work complete | Auto-check |

### Debugging Skills

| Skill | When to Use | Command |
|-------|-------------|---------|
| `superpowers:systematic-debugging` | Any bug, test failure, unexpected behavior | Auto-trigger |
| `gsd:debug` | Systematic debugging with persistent state | `/gsd:debug` |

## Skills Workflow

```
User request → Check skills (even 1% chance) → Announce skill → Follow skill exactly
                                                              ↓
                                               Create TodoWrite if checklist
                                                              ↓
                                               Execute per skill instructions
```

## Red Flags (when to check for skills)

Thoughts that mean STOP and check skills:
- "This is just a simple question" → Questions are tasks
- "I need more context first" → Skills before clarifying questions
- "Let me explore the codebase first" → Skills tell you HOW
- "This doesn't need a formal skill" → Use it anyway
- "The skill is overkill" → Simple things become complex

## Skill Priority Order

1. **Process skills first** (brainstorming, debugging) - determine HOW
2. **Implementation skills second** - guide execution

## Integration with Course Modules

| Course Module | Related Skills |
|---------------|----------------|
| M03 - Planning, TDD, Evals | `writing-plans`, `test-driven-development` |
| M04 - Multi-Agent | `dispatching-parallel-agents`, `subagent-driven-development` |
| M07 - Guardrails | `agent-guardrails.md`, `user-authority-scope.md` |
| M07 - Worktrees | `using-git-worktrees` |
