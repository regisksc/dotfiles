# Patterns

Use these patterns to make mobile UI more useful and less generic.

## Pattern 1: Chat Plus Generative UI

Use when:
- the app is AI-native
- the user needs inspect/choose/edit workflows inside chat

Rules:
- keep chat as the primary canvas
- insert components only when structure helps more than text
- use skeletons for loading when components materialize
- prefer compact cards that expand into sheets or full-screen detail views
- preserve conversational continuity when components update in place

Good component types:
- search results
- charts
- itineraries
- comparison cards
- slot pickers
- form fragments
- task lists

## Pattern 2: Assisted Onboarding

Use when:
- user context matters early
- the product is AI-assisted or adaptive

Rules:
- ask only what unlocks immediate value
- make the onboarding conversational or guided, not bureaucratic
- personalize after collecting minimal useful data
- avoid giant upfront questionnaires

## Pattern 3: Suggested Prompts And Suggestions

Use when:
- users benefit from seeing what good requests look like

Rules:
- show suggestions that teach the product's power
- write them in the user's language, not internal jargon
- make suggestions actionable and contextual

## Pattern 4: Inline Learning

Use when:
- the quality of user inputs determines output quality

Rules:
- teach users how to interact while they are using the product
- do not send them to separate tutorials unless necessary
- embed examples, hints, or improved prompts where the user already is

## Pattern 5: Proactive Personalization

Use when:
- the app can infer better defaults from user behavior or context

Rules:
- personalize without forcing large setup flows
- make the personalization visible enough that it feels helpful, not mysterious
- always preserve override and edit control

## Pattern 6: Feedback Loops

Use when:
- the product depends on user preference quality or AI output quality

Rules:
- add thumbs up/down or lightweight feedback at the moment of use
- tie feedback to a visible object: response, component, recommendation, result
- use short prompts that explain why feedback helps

## Pattern 7: Redesigning Generic AI UI

If the screen feels generic:

1. reduce visual variation
2. choose one memorable cue
3. standardize the spacing/radius/type system
4. make one action obviously primary
5. remove decorative noise that does not improve comprehension

## Pattern 8: Trust-Sensitive Surfaces

Use for finance, health, admin, legal, or productivity tools.

Rules:
- calm color strategy
- explicit data freshness or confidence indicators
- deliberate confirmations for sensitive actions
- stable layout with low surprise factor
- copy that is clear and confident rather than playful by default
