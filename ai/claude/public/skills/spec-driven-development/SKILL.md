---
name: spec-driven-development
description: Use when starting or continuing software development where work must be routed through spec clarification, tactical planning, scoped execution, and review to avoid vibe coding, context drift, duplicated code, or premature implementation.
---

# Spec-Driven Development

Use this as the default development operating system.

The goal is not to jump from a rough request to code. The goal is to route the work into the right phase, keep context clean, reuse proven patterns, and only execute after the current slice is explicit enough to implement safely.

This skill is intentionally a meta-workflow. It does not replace strong existing skills. It decides when to compose them.

## When to Use

- Blank or nearly blank project
- New feature in an existing codebase
- New set of related features
- Mid-stream continuation of partially implemented work
- Architecture-affecting bugfix or refactor
- Any work where direct implementation would become vibe coding

Do not use this for:

- Trivial one-file edits with no ambiguity
- Pure Q and A
- Single-command operational tasks
- Review-only requests where no planning or execution is needed

## Core Principle

Treat code generation as execution of an explicit contract, not improvisation.

The contract has four phases:

1. Discuss
2. Plan
3. Execute
4. Review

If the work is large, run the loop per slice, not once for the whole milestone.

## Quick Reference

| If the request looks like... | Start here | Strong default |
| --- | --- | --- |
| Blank project or fuzzy product request | Discuss | Use `brainstorming`, then plan the first slice |
| Clear feature in an existing app | Discuss | Inspect reuse targets, then make a tactical plan |
| Multiple features or milestone-sized work | Discuss | Split into slices before execution |
| Partial implementation already exists | Discuss | Audit current state, reconstruct the delta, then re-plan |
| New library, API, or architecture uncertainty | Discuss + research | Use `deep-research` before locking the plan |
| Finished implementation | Review | Run verification and code review before calling it done |

## Execution Checklist

Use this compact loop when the skill is active:

1. Classify the context: greenfield, single feature, multi-feature, continuation, research-heavy, or review-only.
2. Define the current slice before coding.
3. Inspect the codebase for affected files, reusable patterns, and constraints.
4. Pull external docs or proven examples only when needed.
5. Write a tactical plan with exact files to create or modify.
6. Execute only the current slice.
7. Review against the spec, plan, verification output, and codebase consistency.
8. If review fails or new facts appear, loop back to discuss or plan before continuing.

## Non-Negotiable Rules

- Never jump directly from a rough goal to implementation when scope, behavior, or file impact is unclear.
- Prefer internal reuse and documented external patterns over invention.
- Keep each execution slice small enough that the model can finish without context collapse.
- Give execution tactical instructions. "Build X" is weak. "Modify files A/B/C this way" is strong.
- Use fresh context, fresh subagents, or a new chat between phases when the previous phase produced a reusable artifact.
- End every execution slice with review.
- If reality changes during execution, update the spec or plan before continuing.

## Context Router

Classify the request before doing any implementation work.

| Situation | Route | Notes |
| --- | --- | --- |
| Blank project, unclear product, UX, or scope | Discuss -> Plan -> Execute -> Review | `brainstorming` is the default discuss engine here. |
| Existing project, clear single feature | Fast Discuss -> Plan -> Execute -> Review | Discuss may be short, but do not skip file and pattern discovery. |
| Existing project, multiple features or a mini-milestone | Discuss -> Plan by slice -> Execute/Review loop per slice | Break the spec into small deliverable slices. |
| Ongoing implementation with work already in progress | Audit current state -> Delta Discuss -> Plan -> Execute -> Review | Reconstruct the delta before writing more code. |
| Unfamiliar ecosystem, new API, or high uncertainty | Discuss with research -> Plan -> Execute -> Review | Pull in `deep-research` when 1-2 lookups are not enough. |
| User asked only for review | Review | Review against the expected behavior, not just style. |

## Phase 1: Discuss

Discuss means: understand the current context well enough that the next phase is grounded.

Do this first:

1. Identify which of these contexts you are in: greenfield, single feature, multi-feature, continuation, review-only.
2. Inspect the local codebase for affected files, reusable patterns, constraints, and conventions.
3. Identify whether requirements are already clear or still need design work.
4. Identify whether external documentation or external examples are needed.
5. Define the current slice. If it feels too big to execute comfortably, split it now.

Use these skills when applicable:

- `brainstorming`: Greenfield work, unclear requirements, UX questions, or behavior design
- `deep-research`: New libraries, external APIs, architecture choices, or multi-source investigation
- `mem-search`: Prior solutions from older sessions when available
- `systematic-debugging`: Bugs, failures, or strange behavior discovered during discuss

Discuss output for the current slice must make these items explicit:

- Goal
- In-scope behavior
- Out-of-scope behavior
- Relevant files and systems
- Reuse targets already present in the codebase
- External docs or examples worth following
- Risks or unknowns
- Acceptance checks

If the work is greenfield or behavior-heavy, the discuss phase should produce or refine a spec before planning. If the work is in an existing codebase, discuss can be shorter, but it still needs to establish the slice and the affected surfaces.

## Phase 2: Plan

Plan turns the current slice into tactical execution instructions.

This is where anti-vibe coding becomes concrete. The plan must remove as much room for freelancing as possible.

Use these skills when applicable:

- `make-plan`: General phased planning
- `writing-plans`: When a design/spec already exists and implementation planning is next
- `gsd-plan-phase`: When the work benefits from the GSD planning and verification loop

Every non-trivial plan should answer:

1. Which files will be created?
2. Which files will be modified?
3. What changes belong in each file?
4. Which existing code should be reused instead of recreated?
5. Which external patterns or docs should be copied from?
6. What order should the work happen in?
7. How will you verify this slice before calling it complete?

If a plan is still too large, split it into smaller slices and loop.

## Phase 3: Execute

Execute only after the slice is explicit.

Use these skills when applicable:

- `do`: Execute a phased plan with subagents
- `gsd-execute-phase`: Execute plan waves in a larger GSD workflow
- `subagent-driven-development`: When the plan contains independent tasks that can run in parallel
- `test-driven-development` or `tdd-workflow`: When the current slice should be implemented test-first

Execution rules:

1. Implement the current slice, not the whole project.
2. Reuse existing files, abstractions, and patterns wherever possible.
3. Prefer documented or already-proven patterns over custom invention.
4. If you discover the plan is wrong, pause execution and update the spec or plan.
5. When context gets noisy, start a fresh phase context instead of pushing through confusion.

## Phase 4: Review

Review is mandatory after execution.

Review means checking the result against the spec, the plan, and the actual codebase impact.

Use these skills when applicable:

- `gsd-code-review`: Structured source review for bugs, regressions, and quality issues
- `requesting-code-review`: Additional review discipline before merge or handoff
- `verification-before-completion`: Required verification before claiming success
- `verification-loop`: Build, lint, test, and diff verification

Review questions:

1. Did the implementation actually satisfy the agreed slice?
2. Did it modify only the intended files and behaviors?
3. Did it reuse existing code instead of duplicating it?
4. Did it follow the documented or discovered pattern?
5. Are there regressions, missing tests, or integration gaps?
6. Is the next slice now clearer, or does the spec need updating first?

If review fails, do not just keep coding. Feed the findings back into discuss or plan, then loop.

## Standard Loops

### Greenfield / Blank Project

1. Discuss with `brainstorming`
2. Produce a spec for the product or current feature slice
3. Plan the first slice tactically
4. Execute only that slice
5. Review
6. Repeat for the next slice

### Existing Project / Single Feature

1. Discuss by inspecting the codebase and reuse targets
2. Plan exact file-level changes
3. Execute the slice
4. Review against the plan and affected surfaces

### Existing Project / Multiple Features

1. Discuss the larger objective
2. Split it into slices before implementation
3. Plan one slice at a time
4. Execute and review one slice at a time

### Continuation Mode

1. Audit current state, current diff, and partially completed work
2. Reconstruct the delta spec for what is still missing
3. Re-plan from the reconstructed state
4. Execute only the delta
5. Review before continuing

### Review-Only Mode

1. Recover expected behavior from request, spec, plan, or code comments
2. Review the changed files and runtime impact
3. Run verification
4. Report findings first, not reassurance first

## Common Mistakes

- Starting execution with only a vague outcome in mind
- Treating a giant feature as one task instead of many slices
- Letting implementation invent new patterns when existing ones already work
- Mixing product discovery, architecture decisions, implementation, and review in one overloaded context
- Skipping review because the code compiles or the UI looks right
- Continuing after a broken plan instead of updating the plan

## Additional Resources

### Reference Files

- `references/source-patterns.md` - Distilled lessons from the local anti-vibe, skills, and workflow videos plus installed-skill influences
- `references/phase-contracts.md` - Detailed phase outputs, checklists, and handoff contracts for discuss, plan, execute, and review

## Operating Standard

Default to this skill for meaningful development work.

The fastest path is usually:

- discuss enough to remove ambiguity
- plan enough to remove invention
- execute only the current slice
- review before claiming success

That is the anti-vibe loop.
