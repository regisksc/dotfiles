# Phase Contracts

Use these as compact output contracts when the main skill routes work into a phase.

## Discuss Contract

Purpose: understand the current slice well enough to plan it safely.

Required output:

1. Context mode: greenfield, single feature, multi-feature, continuation, or review-only
2. Goal
3. In-scope behavior
4. Out-of-scope behavior
5. Affected files or systems
6. Internal reuse targets
7. External docs, examples, or references worth following
8. Risks and unknowns
9. Acceptance checks

Escalate to:

- `brainstorming` for unclear requirements, UX, or greenfield work
- `deep-research` for external uncertainty or non-trivial research

## Plan Contract

Purpose: convert the current slice into tactical implementation instructions.

Required output:

1. Files to create
2. Files to modify
3. Change-by-file instructions
4. Reuse instructions
5. External pattern references
6. Execution order
7. Verification steps
8. Split recommendation if still too large

Good plan language:

- "Modify `src/auth/session.ts` to reuse the existing token refresh helper"
- "Create `src/auth/verify-email.ts` following the documented NextAuth pattern from the research step"

Bad plan language:

- "Implement email verification"
- "Update auth everywhere"

## Execute Contract

Purpose: implement exactly the current slice.

Required behavior:

1. Follow the plan rather than freelancing
2. Reuse existing patterns before creating new ones
3. Keep edits scoped to the planned slice
4. Stop and update the plan if new facts invalidate it
5. Leave enough evidence for review

Recommended post-execution evidence:

- changed files
- commands run
- tests or checks run
- deviations from the original plan

## Review Contract

Purpose: compare what was built against what was intended.

Required checks:

1. Spec compliance
2. Plan compliance
3. Regression risk
4. Duplication or reinvention
5. Verification results
6. Remaining gaps or follow-up slices

Required output style:

- Findings first when issues exist
- Residual risks and testing gaps when no issues exist
- Clear verdict on whether the current slice is actually done

## Slice Sizing Heuristics

Split the work before execution if any of these are true:

- more than a handful of files need coordinated changes
- design and implementation are still mixed together
- external docs still need significant discovery
- the agent would need to hold multiple subsystems in working memory at once
- the request sounds like a milestone, not a slice

## Loop Rule

Use one of these loops, depending on context:

- Discuss -> Plan -> Execute -> Review
- Discuss -> Plan -> Execute -> Review -> Discuss for next slice
- Audit -> Discuss -> Plan -> Execute -> Review for continuation mode
- Review only when no additional changes are requested
