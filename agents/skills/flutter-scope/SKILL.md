---
name: flutter-scope
description: Use when you have a feature or app description and need to produce a development plan before writing code. Researches design references, asks one batch of clarifying questions, then produces a complete scope covering functional requirements, non-functional requirements, and UX/UI direction. Output is consumed by flutter-shell.
version: 0.0.3
---

# Flutter Scope

Turns raw requirements into an approved, complete scope document covering what to build,
how it should behave, and how it should look and feel. Shell reads this directly.

**Input:** Raw description of what needs to be built.
**Output:** Indexed artifact in `.sessions/` + `BACKLOG.md`.

---

## Step 0 — Read the index

Read `.sessions/INDEX.md` to determine the next sequential ID.
Count existing rows (excluding header and the Recovery rules table). Next ID = count + 1, zero-padded to 3 digits.

```bash
date +"%Y-%m-%dT%H:%M"
```

---

## Step 1 — Read the input

Take whatever description was provided verbatim. Do not paraphrase.

---

## Step 2 — Ask one batch of clarifying questions

Present ALL questions in a single numbered list. The user answers once.
Do not drip-feed questions across turns. Skip any already answered in the input.

**Functional:**
1. What are the 3–5 core user actions? (e.g. "log a workout", "view history")
2. What interaction states must each screen handle? (loading / error / empty / success / partial)
3. Is data local (in-memory / SQLite / Hive) or remote (REST / Firebase / GraphQL)? Read-only or read-write?
4. How many screens? Bottom nav / drawer / tab structure / deep links?
5. Any auth or user identity involved?

**Non-functional:**
6. Performance expectations? (e.g. list must scroll at 60fps with 1000+ items, offline-first)
7. Accessibility requirements? (e.g. screen reader support, minimum contrast, dynamic text)
8. Target devices — phone only, or adaptive for tablet / landscape / desktop?

**UX / UI:**
9. What is the emotional tone? (e.g. calm and minimal / energetic and bold / premium and dark)
10. Any apps, products, or design references the UI should feel close to?
11. Any specific animations, gestures, or micro-interactions required?
12. Dark mode only, light only, or both?

**Session:**
13. How much time is available? (drives feature count for Sprint 1)

---

## Step 3 — Design reference research

Using the answers to questions 9–11, fetch visual references before producing the scope.

Invoke `mcp__plugin_context-mode_context-mode__ctx_fetch_and_index` on 2–3 relevant URLs:
- Dribbble or Behance search for the app category + tone (e.g. "fitness app dark UI")
- A direct competitor or reference app's marketing page if named
- Material Design 3 or Apple HIG page relevant to the primary interaction pattern

Extract from each:
- Dominant color approach (dark/light, accent strategy)
- Typography feel (geometric sans / humanist / display)
- Motion character (snappy / fluid / subtle)
- Layout density (card-heavy / list-heavy / full-bleed)
- Key interaction patterns (swipe gestures / FAB / bottom sheet / tab switching)

This informs the UX/UI section of the scope — do not skip it.

---

## Step 4 — Produce the plan

Run in parallel:
- **Thread A:** Invoke `superpowers:brainstorming` — functional feature list with acceptance criteria (200 lines max, no file paths or implementation details)
- **Thread B:** Invoke `frontend-design` — translate tone, references, and device targets into a concrete design direction (color palette, type scale, spacing system, motion principles)

Then invoke `ui-ux-pro-max` — validate the design direction against UX best practices for the platform (iOS/Android conventions, accessibility, touch targets, state design).

Synthesize all three outputs into the scope artifact.

---

## Step 5 — Write the scope artifact

Write `.sessions/[ID]-[TIMESTAMP]-scope-[slug].md`:

```markdown
---
id: [ID]
timestamp: [TIMESTAMP]
type: scope
slug: [slug]
parent_ids: []
summary: [app purpose, N features, design tone]
---

## Context Recovery

Root artifact for this session. All subsequent artifacts reference this ID.
To resume: read this file, then check INDEX.md for what was built after it.

**App:** [one sentence]
**Features planned:** [N]
**Build order:** shell → [Feature A] → [Feature B] → ...

---

## Functional Requirements

### Purpose
[One sentence: what this app does and for whom]

### Core user actions
[Numbered list of the 3–5 primary actions]

### Screen map
[Screen names, relationships, navigation structure]

### Features

#### [Feature Name]
- Acceptance criteria (user-facing, bullet list)
- Interaction states: loading / error / empty / success
- Dependencies: [none | Feature X]
- Complexity: [S / M / L]

[repeat]

---

## Non-Functional Requirements

- **Performance:** [e.g. lists must render at 60fps, offline-first with sync]
- **Accessibility:** [e.g. WCAG AA contrast, screen reader labels, dynamic text support]
- **Devices:** [e.g. phone only / adaptive tablet / landscape]
- **Data:** [e.g. local SQLite, remote REST with 30s timeout, optimistic updates]
- **Auth:** [none / local / remote]

---

## UX / UI Direction

> This section is the primary input for flutter-shell's design step.
> Shell reads it verbatim to drive theme, motion, and layout decisions.

### Emotional tone
[e.g. "Premium and calm — dark surfaces, restrained use of accent, generous whitespace"]

### Design references
[List of references found in Step 3 with key takeaways per reference]

### Color direction
- Background: [description, not hex yet — shell derives tokens]
- Surface: [description]
- Accent: [description — e.g. "single vibrant purple, used sparingly"]
- Text: [e.g. "high-contrast white primary, muted secondary"]

### Typography
[Font personality, weight usage, scale intent — e.g. "geometric sans, heavy display for numbers, regular for body"]

### Motion character
[e.g. "Snappy entry animations (200ms), fluid shared element transitions, subtle haptic-aligned feedback"]

### Layout
[e.g. "Card-based with 16dp gutters, full-bleed hero images, bottom sheet for actions"]

### Key interaction patterns
[e.g. "Swipe to dismiss, long-press for context menu, FAB for primary action"]

### Accessibility intent
[e.g. "All interactive elements labeled, minimum 4.5:1 contrast, touch targets ≥ 48dp"]

---

## State Management Plan

[Riverpod providers needed at high level — names and what they hold]
```

Also write `BACKLOG.md`:

```markdown
# Backlog
<!-- scope-ref: [ID] -->

## Shell (first)
- [ ] Navigation structure
- [ ] Design system (from scope UX/UI Direction)
- [ ] Placeholder screens
- [ ] Riverpod providers (stub state)

## Sprint 1
- [ ] [Feature A — S]
- [ ] [Feature B — M]

## Later
- [ ] [Feature C — L]
```

Ordering rules: shell first, no-dependency features before dependent ones, cap Sprint 1 at 2 features if session < 60 min.

---

## Step 6 — Update the index

```
| [ID] | [TIMESTAMP] | scope | [slug] | [summary] | .sessions/[filename] |
```

---

## Step 7 — Present and wait for approval

```
Scope ready → .sessions/[filename] (ID: [ID])

Tone: [one line]
Design ref: [one line]
Shell: navigation + design system
Sprint 1: [Feature A], [Feature B]
Later: [Feature C]

Does this match your vision?
```

**Do not proceed until explicitly approved.** Partial feedback = revise and re-ask.

---

## Done

**Next skill:** `/flutter-shell` — it reads this artifact directly.
