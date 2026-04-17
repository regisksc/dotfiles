# Source Patterns

This skill is grounded in a practical anti-vibe development mindset and reinforced by installed skills already present on this machine.

## Video-Derived Principles

### 1. Anti-vibe coding is about replacing improvisation with explicit guidance

- The workflow is framed as spec-driven development rather than "prompt and pray"
- Research should happen before implementation
- Relevant codebase files, external docs, and proven implementation patterns should be gathered first
- The implementation prompt should be tactical and explicit about which files to create or modify
- A fresh phase context is valuable after research so the next step consumes the artifact rather than the whole conversation

Mindset distilled into this skill:

- move from rough intent to explicit execution artifacts
- compress research into reusable planning inputs
- reset phase context when the artifact matters more than the prior conversation
- make implementation instructions tactical, not aspirational

### 2. Large tasks fail; small slices survive context limits

- Large tasks overload context and fail mid-implementation
- The antidote is to start from a spec, break it into small tasks, plan each task, then implement it
- Reuse existing internal code and external documented patterns rather than rewriting or inventing

Mindset distilled into this skill:

- slice first, then execute
- control context size deliberately
- prefer reuse over regeneration
- treat duplication and overengineering as planning failures, not just coding mistakes

### 3. Skills are playbooks that should be loaded on demand, kept lean, and improved over time

- Skills act as playbooks for specific work instead of bloating the base prompt
- A skill should teach something specific and load only when needed
- Skills can be improved over time by feeding new lessons back into them

Mindset distilled into this skill:

- keep the main skill body lean
- move detail into references when needed
- let the skill evolve as new failure modes appear

### 4. Discoverability matters; agents are the customers

- Strong skills solve a specific recurring problem
- Their naming and description should match what other agents would search for
- Give agents direct, usable interfaces and examples instead of vague high-level prose when possible

Mindset distilled into this skill:

- optimize naming and descriptions for agent discovery
- expose operational guidance, not just principles
- make the default path obvious enough that another agent can follow it on the first read

## Installed Skill Influences

This skill intentionally borrows operating ideas from these installed skills:

- `brainstorming`: design-before-build gate for ambiguous or greenfield work
- `make-plan`: documentation discovery first, explicit anti-invention planning
- `do`: execute only through a plan and verify after each phase
- `deep-research`: phased research with scope, plan, retrieval, synthesis, and packaging
- `gsd-discuss-phase`: context extraction before planning
- `gsd-plan-phase`: planning with verification loop
- `gsd-execute-phase`: wave-based execution and fresh-context orchestration
- `gsd-code-review`: explicit review artifact and findings-first review behavior
- `verification-before-completion` and `verification-loop`: evidence before success claims

## Why This Skill Adds A Review Phase

The source anti-vibe workflow already implies verification value, but it stops at implementation. For daily production work, that is not enough.

This skill adds a formal review phase because:

- execution without review still leaves room for regressions and drift
- the best installed local workflows already distinguish planning, execution, and verification
- making review explicit turns the loop into a reusable default operating model for real codebases

## Recommended Mental Model

Use this skill as the top-level router.

- `Discuss` removes ambiguity
- `Plan` removes invention
- `Execute` applies the current slice
- `Review` validates the result and decides whether to loop

If the slice still feels big, it is not ready for execution.
