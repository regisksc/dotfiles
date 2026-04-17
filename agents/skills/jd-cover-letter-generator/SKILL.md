# JD Cover Letter Generator

Generate a tailored cover letter from any pasted job description (JD), aligned to one of three role tracks:

- Backend Python Engineer
- iOS Engineer
- Flutter Engineer

## Trigger

Use this skill when the user asks:

- "create a cover letter from this JD"
- "tailor this cover letter"
- "adapt my application for this job"

## Required Inputs

1. `role_track`: one of `backend-python`, `ios`, `flutter`
2. `job_description`: full JD text
3. `company_name`: extracted from JD (or `Unknown company`)
4. `must_have_keywords`: 8-15 keywords from JD
5. `candidate_evidence`: 4-8 bullets with measurable outcomes from user history

## Candidate Baseline (Regis Kian)

- 6+ years mobile engineering (iOS + Flutter)
- Banco Itau scale: 15M+ users
- Test coverage 0% -> 60%, bugs down 70%
- Resolved critical build issue mitigating $50k/day losses
- CI/CD acceleration and modular architecture work
- Cross-platform architecture and native bridge experience

## Generation Rules

- Tone: concise, senior, impact-first
- Length: 170-260 words
- Structure:
  1) Role + fit statement
  2) 2-3 measurable outcomes tied to JD needs
  3) Why this company
  4) Close with availability and contract model (B2B/EOR)
- Avoid generic claims ("passionate", "hard worker") unless backed by proof
- Reuse JD terminology naturally for ATS alignment

## Output Format

Return exactly:

```markdown
## Cover Letter
<final letter>

## Tailoring Notes
- JD keyword -> mapped evidence
- JD keyword -> mapped evidence
- JD keyword -> mapped evidence
```

## Role-Specific Guidance

### backend-python

- Translate mobile/system experience into backend value: APIs, observability, CI/CD, reliability, architecture
- Highlight Python ecosystem where applicable (FastAPI, Django, async, data tooling) only if user confirms real usage
- Emphasize distributed systems, performance, and production quality

### ios

- Prioritize Swift, UIKit/SwiftUI, architecture, testing, StoreKit, Apple ecosystem quality
- Show scale and business outcomes (retention, reliability, release speed)

### flutter

- Prioritize cross-platform architecture, modularization, state management, native bridges, delivery speed
- Show enterprise-grade quality (linting, coverage, CI/CD, observability)

## Safety / Integrity

- Never invent employers, years, or metrics
- If evidence is missing, write a strong version with explicit neutral language
- If JD is vague, optimize for the most repeated requirements
