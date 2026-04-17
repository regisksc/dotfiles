---
name: mobile-ui
description: Designs, redesigns, audits, and guides implementation of mobile-first app interfaces. Use when screen quality, interaction quality, visual identity, AI-native patterns, or premium perceived value matter and generic UI decisions would produce cheap, inconsistent, or forgettable results.
---

# Mobile UI

Design mobile interfaces that feel intentional, premium, familiar, and product-specific.

This skill is for mobile-first product UI, not generic page styling. Use it when the work changes how an app screen looks, feels, guides, or responds.

## Overview

Strong mobile UI comes from four things working together:

1. Identity: the app looks like itself, not a template
2. Familiarity: the interaction model feels obvious to the target user
3. Consistency: spacing, type, color, and behavior feel like one product
4. Helpfulness: the UI reduces cognitive load instead of adding decoration

If one of those is missing, the app usually feels cheap, AI-generated, or forgettable.

## When to Use

- Designing a mobile app from scratch
- Designing a new mobile screen or flow
- Redesigning an app that feels generic, cheap, or inconsistent
- Auditing mobile UI quality before shipping
- Designing AI-native mobile chat experiences with inline components
- Building a mobile design system or screen kit
- Translating product positioning into mobile interface decisions

Do not use this for:

- Pure backend or API work
- Non-visual scripting tasks
- Desktop-only interface work unless the mobile pattern is still the source of truth
- Tiny cosmetic edits that do not change interaction quality or design direction

## Mode Router

Choose one mode before designing:

| Situation | Mode | Primary output |
| --- | --- | --- |
| Brand new app or flow | New Design | Direction, system, and screen structure |
| Existing app looks generic or low-value | Redesign | Upgrade plan plus new visual/UX direction |
| Existing screens need evaluation | Audit | Findings-first review and prioritized fixes |
| AI chat should do more than return text | Generative UI | Inline component interaction model |
| Multiple screens need cohesion | Design System | Shared tokens, patterns, and rules |
| Design must be handed to implementation | Handoff | Exact component, state, and behavior guidance |

## Execution Checklist

1. Identify the mode.
2. Define the user, job-to-be-done, and emotional target.
3. Lock the design direction before choosing components.
4. Preserve familiar interaction patterns unless there is a strong reason to break them.
5. Define the visual system: typography, color, spacing, radius, elevation, icon style.
6. Design the screen around one primary action and one dominant visual hierarchy.
7. Add states: loading, empty, success, error, disabled, pressed.
8. Audit for identity, familiarity, consistency, accessibility, and trust.
9. If implementation is requested, hand off exact component behavior and token usage.

## Clarification Rule

Ask a clarifying question only when the missing input would materially change the design direction.

If the missing input is not critical:

- state the assumption briefly
- proceed with the most defensible mobile-first direction

Critical unknowns usually include:

- product type
- target user
- platform target when platform conventions matter
- whether the task is new design, redesign, audit, or generative UI

## Output By Mode

Use a stable structure for each mode.

### New Design

Return:

1. design direction
2. primary user and job-to-be-done
3. screen hierarchy
4. component list
5. visual system notes
6. interaction and state notes

### Redesign

Return:

1. current quality diagnosis
2. redesign direction
3. priority changes
4. screen/system fixes
5. implementation handoff notes if needed

### Audit

Return:

1. findings first
2. why each issue weakens value or usability
3. priority
4. concrete fix direction

### Generative UI

Return:

1. chat interaction model
2. inline component types
3. compact vs expanded behavior
4. loading, fallback, and update rules
5. user-control rules

### Design System

Return:

1. token set
2. component rules
3. screen consistency rules
4. anti-drift constraints

### Handoff

Return:

1. screen purpose
2. component/state list
3. hierarchy and spacing notes
4. token usage
5. accessibility requirements
6. platform-specific notes

## New Design Mode

Start here for a new screen, flow, or app.

### Step 1: Lock the direction

Define these before layout work:

- Product type
- Primary user
- Core action for this screen
- Emotional target: calm, premium, energetic, playful, serious, safe, etc.
- Memorable element: the one visual or interaction trait users should remember

Do not start with random cards, gradients, or component libraries.

### Step 2: Apply the core mobile triad

Use these principles together:

- **Identity**: use distinctive brand cues such as type, accent, material treatment, illustration style, icon rhythm, or signature component shapes
- **Familiarity**: borrow interaction models the user already understands; do not innovate on basic navigation, chat, search, or forms without a strong reason
- **Consistency**: keep spacing, color roles, typography, icon style, and motion coherent across screens

### Step 3: Build the screen hierarchy

For each screen, define:

- one primary action
- one dominant content block
- supporting content in descending visual priority
- thumb-zone placement for key actions
- collapsed vs expanded states for dense information

Prefer calm hierarchy over feature dumping.

## Redesign Mode

Use this when the app feels cheap, bland, or AI-generated.

Diagnose in this order:

1. No identity: looks like every other AI app
2. Weak familiarity: requires unnecessary learning effort
3. Broken consistency: each screen feels unrelated
4. Poor hierarchy: everything screams at once
5. Surface clutter: too many cards, colors, shadows, or effects

Typical redesign moves:

- reduce the palette
- reduce component variation
- standardize spacing and radius
- choose one icon family
- make one focal point per screen
- remove decorative noise that does not help comprehension
- replace vague labels with confident, product-specific copy

## Audit Mode

Use findings-first review.

Review in this order:

1. Identity: would a screenshot feel product-specific?
2. Familiarity: would the target user know what to do quickly?
3. Consistency: do screens share the same system?
4. Hierarchy: is the primary action obvious?
5. Accessibility: contrast, tap targets, readable type, state clarity
6. Trust: does the product feel calm, deliberate, and credible?
7. State coverage: empty, loading, error, success, disabled, editing

Output:

- findings first
- severity or priority
- exact UI problems
- concrete fixes

## Generative UI Mode

Use this when the app has chat and should render useful UI inline instead of only text.

Core rule:

- text explains
- components help the user inspect, choose, edit, compare, or act

Design the chat as the primary canvas, then insert structured blocks only when they reduce effort.

Good inline components:

- result cards
- comparison cards
- editable plans or itineraries
- charts and summaries
- slot pickers
- checklists
- file previews
- maps
- forms for a narrow next action

Required behaviors:

- compact by default
- expandable when deeper interaction is needed
- editable in place or through a bottom sheet
- clearly labeled so the user knows why the component appeared
- reversible or dismissible when appropriate
- graceful fallback to text when data is weak or unavailable

Avoid turning the chat into a dashboard. Components should appear only when they reduce cognitive load.

## Design System Mode

When multiple screens need cohesion, define the mobile system first.

Lock these tokens:

- typography scale
- neutral scale and accent colors
- semantic colors: primary, secondary, success, warning, error, surface, on-surface
- spacing scale
- radius scale
- elevation/shadow rules
- icon set and stroke style
- motion duration and easing

Never let each screen invent its own rules.

## Handoff Mode

If implementation is requested, hand off exact behavior.

Include:

1. screen purpose
2. primary action
3. component list
4. state list
5. token usage
6. spacing and hierarchy notes
7. interaction details
8. accessibility requirements
9. platform-specific notes if Flutter, React Native, SwiftUI, or responsive web is involved

The handoff should make generic implementation harder than faithful implementation.

## Practical Rules

### Visual quality

- Commit to a clear aesthetic direction
- Use distinctive typography intentionally, not randomly
- Use a restrained palette with one clear accent strategy
- Use whitespace and hierarchy to create luxury before adding effects
- Make important values larger than their labels

### UX quality

- Put primary actions inside comfortable reach
- Prefer direct manipulation over extra navigation
- Use familiar mental models for chat, onboarding, search, filters, and settings
- Minimize learning cost in the first session
- Treat empty states as guidance, not dead ends

### Perceived value

- Premium comes from discipline, not visual noise
- A screen should feel confident in under two seconds
- Calm motion beats flashy motion in trust-sensitive products
- In finance, health, admin, and AI productivity, clarity is part of the brand

## Anti-Patterns

- Generic purple-gradient AI look
- Random spacing values and mixed radii
- Multiple icon families in the same app
- Every screen using the same card stack regardless of context
- Over-innovating on basic UX and increasing learning cost
- Dense dashboards where no action is clearly primary
- Chat interfaces that render text only when structure would be better
- Generative UI that produces components without context, controls, or fallback behavior
- Premium claims with cheap details: bad type, weak hierarchy, inconsistent color roles, noisy shadows

## Quick Reference

| If the problem is... | Usually fix by... |
| --- | --- |
| App feels generic | Strengthen identity and memorable cues |
| App feels confusing | Increase familiarity and simplify hierarchy |
| App feels cheap | Improve consistency, restraint, and typography |
| Chat feels limited | Use generative UI for inspect/choose/edit actions |
| Screens drift from each other | Define tokens and component rules first |
| Implementation goes off-style | Write a stronger handoff with exact behavior |

## Additional Resources

### Reference Files

- `references/principles.md` - Core mindset, premium-value rules, and distilled design heuristics
- `references/patterns.md` - Reusable mobile UX and AI-native interaction patterns
- `references/review-checklist.md` - Audit checklist for existing mobile UI
- `references/handoff-notes.md` - Platform-aware implementation handoff rules

## Operating Standard

Do not design mobile UI by assembling pretty parts.

Decide the mode, lock the direction, preserve familiarity, enforce consistency, and make the screen useful before making it decorative.
