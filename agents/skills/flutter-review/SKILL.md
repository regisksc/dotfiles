---
name: flutter-review
description: Use after completing the shell or any feature to review the current codebase state. Behaves like a PR reviewer — spawns 4 parallel agents, collects all findings, then ranks them by criticality (P0–P3) in a single actionable list. Produces a timestamped artifact in .sessions/. Pass --wrap for final production-readiness review.
version: 0.0.2
---

# Flutter Review

A PR-style review of the current codebase state.
Findings are ranked by criticality across all dimensions so any finding can be acted on by ID.

**Usage:**
- `/flutter-review` — review the most recent iteration
- `/flutter-review --wrap` — full production-readiness review (final pass)

**Enables commands like:**
- "fix all P0s from review 004"
- "what was flagged in the latest review"
- "backtrack to before the P1 SOLID violation was introduced"

---

## Step 0 — Read index

Read `.sessions/INDEX.md`. Identify:
- Latest `feature` or `shell` entry → this is what's being reviewed
- All prior `review` entries → for context on recurring issues

Get next ID and timestamp:
```bash
date +"%Y-%m-%dT%H:%M"
```

`parent_ids` = [ID of the artifact being reviewed] + [IDs of any prior reviews]

---

## Step 1 — Verify first

Before any review agent runs:

```bash
fvm flutter test
fvm flutter analyze
fvm flutter format --set-exit-if-changed .
```

If any fail: **stop, fix, re-run** before proceeding. A review on a broken build is noise.

---

## Step 2 — Dispatch 4 parallel review agents

Invoke `superpowers:dispatching-parallel-agents`. Each agent:
- Reads the file tree under `lib/src/`
- Reads `.sessions/INDEX.md` and the latest scope artifact for acceptance criteria context
- Returns findings as a **structured list only** — no prose, no summaries

Each finding must include:
- Severity: P0 / P1 / P2 / P3
- Dimension: UX | Accessibility | Security | SOLID
- File path (relative to project root)
- Line reference if applicable
- Issue (one sentence, specific)
- Recommended fix (one sentence, actionable)

---

### Agent 1 — UX / UI Quality

Evaluate against Apple-level production standards:

- **Visual hierarchy:** Is the primary action immediately obvious on each screen?
- **Typography:** Consistent type scale, appropriate weights, line-height, no orphaned text
- **Spacing:** Consistent 4/8dp scale. Flag any magic-number `SizedBox` or padding values
- **Color:** Contrast ratios meet WCAG AA (4.5:1 normal, 3:1 large text). No hardcoded `Color(0xFF...)` in widget files
- **Motion:** Transitions communicate state change — flag purely decorative or missing transitions
- **States:** Loading (skeleton/shimmer?), error (message + retry?), empty (designed or blank?)
- **Widget methods:** Flag any `Widget _buildX()` that should be an extracted `StatelessWidget`
- **Performance:** Flag `ListView(children: [...])` that should be `ListView.builder`, `Opacity` animations that should be `FadeTransition`, missing `const` constructors

---

### Agent 2 — Accessibility

- **Semantic labels:** All interactive elements have `Semantics` or `Tooltip`? All `Image` widgets have `semanticLabel`?
- **Touch targets:** All tappable elements ≥ 48×48dp? Check `GestureDetector`, `InkWell`, `IconButton`, `TextButton`
- **Contrast:** Text colors sufficiently contrasted against backgrounds (WCAG AA)
- **Reading order:** Widget tree reflects logical reading order for screen readers
- **Focus management:** After navigation or dialogs, is focus placed correctly?
- **Text scaling:** Do layouts hold at 1.5× and 2× text scale factor?
- **Dynamic content:** Are list items, error messages, and loading states announced to screen readers?

---

### Agent 3 — Security

- **Secrets in source:** Any API keys, tokens, passwords, or credentials hardcoded?
- **Insecure storage:** Is `SharedPreferences` used for sensitive data that requires `flutter_secure_storage`?
- **Input validation:** Are all user inputs validated before processing or display?
- **Network:** All calls HTTPS? Is `badCertificateCallback` returning `true` anywhere?
- **Logging:** Is sensitive data (tokens, emails, PII) passed to `debugPrint`?
- **Deep links:** Are go_router path parameters validated before acting on them?
- **Dependencies:** Any packages in `pubspec.yaml` with known vulnerabilities or no recent updates?

---

### Agent 4 — SOLID + Coherence

- **DIP:** Does `presentation/` import anything from `data/`? All wiring must go through use cases
- **ISP:** Are datasource interfaces fat (many unrelated methods)? Should be one interface per capability
- **SRP:** Files doing more than one job? Screens fetching data directly? Use cases with no business logic (passthrough anti-pattern)?
- **Layer coherence:** Domain entities free of Flutter imports? Use cases in `data/usecases/`, not in domain?
- **Use Case Pattern:** Do use cases contain BUSINESS LOGIC (validation, transformation, compression) or are they just passthrough delegates?
- **File size:** Files > 300 lines that could be extracted?
- **Naming:** Widget names, use case names, datasource names consistent with their role and layer?
- **Dead code:** Unused imports, methods, variables?
- **Comment quality:** Comments explain intent and failure modes — not restate the code?

---

## Step 3 — Synthesize and rank all findings

Collect findings from all 4 agents. Merge into a single ranked table ordered by severity (P0 first), then by dimension.

**Severity definitions:**
- **P0 — Block:** Data exposure risk, auth bypass, crash in happy path, or violation that renders the feature unusable. Fix before the next feature.
- **P1 — Urgent:** Degrades user experience noticeably, SOLID violation that will compound, or security weakness in non-critical path. Fix before `/flutter-review --wrap`.
- **P2 — Soon:** Polish issue, minor architecture drift, accessibility gap that doesn't break the flow.
- **P3 — Note:** Nitpick, future consideration, optional improvement.

---

## Step 4 — Write artifact and update index

Write `.sessions/[ID]-[TIMESTAMP]-review-[reviewed-artifact-slug].md`:

```markdown
---
id: [ID]
timestamp: [TIMESTAMP]
type: review
slug: review-[reviewed-artifact-slug]
parent_ids: [[reviewed-artifact-ID], [prior-review-IDs if any]]
reviewed_artifact: [ID] — [type] — [slug]
summary: [N findings: X P0, X P1, X P2, X P3]
wrap: [true | false]
---

## Context Recovery

**Reviewed:** [artifact type + slug] (ID [reviewed-artifact-ID])
**Session state at review time:** [brief — what features exist, what's running]

To act on findings: reference finding IDs below.
Example: "fix finding R[ID]-001 and R[ID]-002"
Each finding has a file path and recommended fix — actionable without re-reading code.

---

## Verification baseline

- Tests: [X passing / 0 failing]
- Analyze: [clean / N warnings — list them]
- Format: [clean]

---

## Findings (ranked by criticality)

### P0 — Block (fix before next feature)

| # | Dimension | File | Issue | Recommended Fix |
|---|-----------|------|-------|-----------------|
| R[ID]-001 | [Dimension] | [file:line] | [specific issue] | [specific fix] |
| R[ID]-002 | ... | ... | ... | ... |

### P1 — Urgent (fix before final review)

| # | Dimension | File | Issue | Recommended Fix |
|---|-----------|------|-------|-----------------|
| R[ID]-010 | ... | ... | ... | ... |

### P2 — Soon

| # | Dimension | File | Issue | Recommended Fix |
|---|-----------|------|-------|-----------------|
| R[ID]-020 | ... | ... | ... | ... |

### P3 — Notes

| # | Dimension | File | Issue | Recommended Fix |
|---|-----------|------|-------|-----------------|
| R[ID]-030 | ... | ... | ... | ... |

---

## Required before next feature
[List finding IDs that are P0]

## Recurring issues (seen in prior reviews)
[Cross-reference with prior review IDs if the same pattern reappears]
```

If `--wrap` flag is present, add this section:

```markdown
---

## Production Readiness (--wrap)

### Verification
- [ ] `fvm flutter test` — all passing
- [ ] `fvm flutter analyze` — zero warnings
- [ ] `fvm flutter format --set-exit-if-changed .` — clean

### Release config
- [ ] `--obfuscate --split-debug-info=symbols/` in prod build command
- [ ] No debug flags in release entrypoint (`main_prod.dart`)
- [ ] `.env` not committed (only `.env.example`)

### Acceptance criteria coverage
[List each AC from scope — check off those with tests covering them]

### Missing golden tests
[List screens with no golden/snapshot test]

### Unresolved findings from prior reviews
[List any P0/P1 from earlier reviews not yet fixed — with their original IDs]

### Final verdict
**READY TO SHIP** / **NEEDS FIXES** — [list blocking finding IDs]
```

Append to `.sessions/INDEX.md`:
```
| [ID] | [TIMESTAMP] | review | review-[slug] | [N findings: X P0, X P1, X P2, X P3] | .sessions/[filename] |
```

---

## Step 5 — Present summary

```
Review complete → .sessions/[filename] (ID: [ID])

P0 (block):  [N] findings — IDs: R[ID]-001, R[ID]-002
P1 (urgent): [N] findings
P2 (soon):   [N] findings
P3 (notes):  [N] findings

Fix now: [list P0 finding IDs and one-line description each]

[If --wrap]: Final verdict: READY TO SHIP / NEEDS FIXES (R[ID]-001, R[ID]-002)
```

Fix all P0s immediately. P1s before the final review.
P2s and P3s can be addressed at any time or deferred.
