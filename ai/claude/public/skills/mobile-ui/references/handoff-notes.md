# Handoff Notes

Use these rules when translating mobile UI decisions into implementation guidance.

## Universal Handoff Contract

Always specify:

1. screen purpose
2. primary action
3. components on the screen
4. visual hierarchy
5. state list
6. token usage
7. accessibility requirements
8. interaction notes

## Flutter

- keep colors and type in theme tokens
- avoid hardcoded style values in widgets
- note platform adaptation when iOS and Android differ
- state whether the screen should feel more Cupertino, Material, or custom

## React Native / Expo

- specify spacing, type, and color tokens explicitly
- note sheet, modal, and keyboard behaviors
- call out safe-area handling and touch target expectations

## SwiftUI

- define which pieces are system-native vs custom-styled
- preserve platform familiarity where possible
- use semantic colors and dynamic type expectations in the handoff

## Responsive Web Used As Mobile Prototype

- treat mobile viewport as source of truth
- specify compact and expanded states
- define when the screen becomes a sheet, drawer, or full page

## Generative UI Handoff

For chat plus inline components, specify:

1. which intents produce which components
2. compact state vs expanded state
3. loading skeleton behavior
4. update-in-place behavior
5. fallback-to-text behavior
6. user controls: edit, dismiss, save, expand, retry
