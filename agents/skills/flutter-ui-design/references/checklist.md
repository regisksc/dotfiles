# Flutter UI Pre-Delivery Checklist

Full checklist before shipping any Flutter screen or app. Work top-to-bottom — higher sections have more impact.

---

## Accessibility (CRITICAL)

- [ ] All `IconButton` and icon-only tappable elements have `tooltip` or `Semantics(label: ...)`
- [ ] Meaningful `Image` widgets have `semanticsLabel`
- [ ] Decorative images have `excludeFromSemantics: true` or `ExcludeSemantics` wrapper
- [ ] `MergeSemantics` used to group related labels (e.g., icon + price)
- [ ] Focus/tab order matches visual top-to-bottom, left-to-right layout
- [ ] Color is not the only indicator for state or meaning (add icon or text)
- [ ] Text respects `MediaQuery.textScaleFactor` — no hardcoded-height containers around text
- [ ] Tested with TalkBack (Android) and VoiceOver (iOS) at least once
- [ ] `Semantics(button: true)` on custom tappable widgets that aren't `Button` descendants

---

## Touch & Interaction (CRITICAL)

- [ ] All tappable elements ≥48dp (Material) / ≥44pt (Cupertino)
- [ ] Small icons have expanded hit area via `Padding` inside `GestureDetector` with `HitTestBehavior.opaque`
- [ ] Minimum 8dp gap between adjacent touch targets
- [ ] Visual press feedback on all tappable elements (ripple, opacity, or scale)
- [ ] Async actions: button disabled + `CircularProgressIndicator` shown during loading
- [ ] `HapticFeedback.mediumImpact()` on confirmations and important actions
- [ ] iOS swipe-back gesture not blocked by `Navigator` setup
- [ ] Android predictive back handled via `PopScope` where needed

---

## Performance (HIGH)

- [ ] `const` applied to all stateless widgets and immutable subtrees
- [ ] `ListView.builder` (not `ListView` with children list) for lists with 10+ items
- [ ] `SliverList`/`SliverGrid` used in complex scrolling layouts
- [ ] `RepaintBoundary` wrapping independently animating subtrees
- [ ] `MediaQuery.of(context)` cached in local variable — not called inside loops or deep trees
- [ ] All remote images use `cached_network_image` (never raw `Image.network` without cache)
- [ ] Image dimensions declared or `AspectRatio` used to prevent layout jump
- [ ] No `setState` in `initState` (use `addPostFrameCallback` instead)
- [ ] Flutter DevTools profiler run — no frames exceeding 16ms budget

---

## Design System & Theme (HIGH)

- [ ] Zero hardcoded hex colors in widgets — all via `Theme.of(context).colorScheme.*`
- [ ] Zero hardcoded `TextStyle` in widgets — all via `Theme.of(context).textTheme.*` with `.copyWith()` for overrides
- [ ] Single `ThemeData` light + single `ThemeData` dark (not derived from each other)
- [ ] Consistent border radius scale applied (not arbitrary values per widget)
- [ ] `CardTheme`, `InputDecorationTheme`, `AppBarTheme` set at theme level
- [ ] Icon family is consistent throughout (same package, same stroke width)
- [ ] No emoji used as structural or navigation icons

---

## Layout & Responsive (HIGH)

- [ ] `SafeArea` on all top-level `Scaffold` screens
- [ ] No content hidden behind notch, Dynamic Island, status bar, or gesture bar
- [ ] Fixed bottom bars use `Scaffold.bottomNavigationBar` (auto-insets scroll content)
- [ ] No horizontal overflow — verified on 375pt wide (small phone)
- [ ] Landscape orientation tested and layout remains usable
- [ ] Large screen (tablet) layout verified — no edge-to-edge text paragraphs
- [ ] 4/8dp spacing grid maintained across all components, sections, and pages
- [ ] No hardcoded device-specific dimensions (no `Container(height: 812)`)

---

## Typography & Color (MEDIUM)

- [ ] Body text ≥16sp
- [ ] Body line height 1.5–1.75 (`height` property on `TextStyle`)
- [ ] Display font is distinctive — NOT default Roboto or system font
- [ ] Font weight hierarchy: display 600-700+, body 400, labels/captions 400-500
- [ ] Color contrast ≥4.5:1 for body text in light mode
- [ ] Color contrast ≥4.5:1 for body text in dark mode (tested separately)
- [ ] Secondary/muted text ≥3:1 contrast
- [ ] Prices, counters, timers use tabular figures (`FontFeature.tabularFigures()`)
- [ ] Semantic color tokens used for error, success, warning states (not raw colors)

---

## Animation (MEDIUM)

- [ ] All micro-interactions 150–300ms duration
- [ ] Page transitions 300–400ms max
- [ ] Only `transform` and `opacity` animated (never `width`/`height`/`padding`)
- [ ] Enter uses `Curves.easeOut`, exit uses `Curves.easeIn`
- [ ] List item entrance is staggered (30–50ms per item)
- [ ] Every animation has a reason — no purely decorative motion
- [ ] `MediaQuery.of(context).disableAnimations` respected — skip or instant-complete animations when true
- [ ] Animations are interruptible — UI stays responsive during transitions
- [ ] `Hero` widget used for shared element transitions between screens

---

## Forms & Feedback (MEDIUM)

- [ ] Every input has a visible `labelText` (not placeholder-only)
- [ ] Error messages appear below the related field
- [ ] `keyboardType` matches input type (email, phone, number, URL)
- [ ] `autofillHints` set for all standard fields
- [ ] `TextInputAction.next` chains fields; `.done` on last field
- [ ] First invalid field auto-focused after failed submit
- [ ] Password fields have show/hide toggle
- [ ] Destructive actions confirmed with `showDialog` / `CupertinoAlertDialog`
- [ ] `ScaffoldMessenger.showSnackBar` toasts auto-dismiss in 3–5s
- [ ] Multi-step flows show step indicator or progress bar

---

## Navigation (HIGH)

- [ ] `BottomNavigationBar` / `NavigationBar` has ≤5 items with visible labels
- [ ] Current tab visually highlighted (selected state)
- [ ] Back navigation restores scroll position and filter state
- [ ] All key screens reachable via deep link (`go_router` path defined)
- [ ] `Drawer` used for secondary navigation (not primary actions)
- [ ] Modals not used as primary navigation flows
- [ ] `PopScope` handling in place for modals/sheets with unsaved changes

---

## Aesthetics (Design Quality)

- [ ] Display font is NOT Roboto, Inter, or default system font
- [ ] Primary brand color is NOT system default blue or Material purple
- [ ] No purple gradient on white background
- [ ] Cards/surfaces are distinguishable from background (elevation, border, or tint)
- [ ] App has ONE memorable visual element (font pairing, transition, color, texture)
- [ ] Motion exists and feels intentional — not just `AnimatedOpacity` added as afterthought
- [ ] Spacing has rhythm — not uniform `padding: EdgeInsets.all(16)` everywhere
- [ ] Each main screen has a distinct visual emphasis point
- [ ] Dark mode tested visually — not just contrast ratios (check overall feel)
- [ ] Anti-generic checklist in `aesthetics.md` passed

---

## Dark Mode (Separate Verification)

- [ ] Light and dark `ThemeData` both defined — dark is NOT derived from light at runtime
- [ ] All surfaces, cards, and inputs look intentional in dark mode (not just inverted)
- [ ] Dividers and borders visible in both modes
- [ ] Modal/sheet scrim opacity is 40–60% black in dark mode
- [ ] Interactive state colors (hover/pressed/disabled) distinguishable in both modes
- [ ] Charts and data visualizations tested in dark mode
