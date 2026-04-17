# Development Workflow with AI

## Core Chain: Context → Research → Plan → Tasks

Narrow and define scope to reduce drift.

| Step | Purpose | Action |
|------|---------|--------|
| **Context** | What to solve, constraints, stack | Define problem clearly before asking for solutions |
| **Research/guidelines** | How to solve, best practices | Search repo + dependencies for existing patterns first |
| **Plan** | High-level order of execution | Create phased approach with dependencies |
| **Tasks** | Actionable items | Break plan into small, verifiable steps |

## Plan-First Execution

Before implementing:
1. Create high-level plan with phases/steps in order
2. Define dependencies ("step 2 depends on step 1")
3. Define acceptance criteria per phase
4. Execute one phase at a time
5. Validate each phase before moving to next

## TDD with Agents

1. **Define behavior:** Describe expected behavior in clear language
2. **Test first:** Write tests that fail (verify they actually fail)
3. **Minimal implementation:** Code minimum to pass tests
4. **Validate:** Run tests, confirm pass
5. **Refactor (optional):** Improve code keeping tests green

Never write test + implementation together and both pass first try - test must fail first.

## Acceptance Criteria

After implementation, verify against explicit criteria:
- List specific behaviors that must work
- Define edge cases that must be handled
- Run relevant tests
- Only then consider delivery validated

## Environment Management

- Document how to start/tear down environment
- List ports, commands (build, test, logs)
- Include seed data or test credentials
- Manage port conflicts proactively

## Minimal Scope Principle

- Change only what was requested
- Search for existing API before adding new layers
- Suggest additional improvements but ask first
- No over-commenting - comment only non-obvious behavior or intent
