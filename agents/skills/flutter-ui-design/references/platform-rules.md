# Flutter Platform Rules

Systematic quality rules for Flutter iOS/Android development. Adapted from iOS HIG and Material Design 3 guidelines. Follow Priority 1 → 10.

---

## 1. Accessibility (CRITICAL)

**Semantics widget — use it everywhere interactive:**
```dart
Semantics(
  label: 'Close dialog',
  button: true,
  child: IconButton(icon: Icon(Icons.close), onPressed: onClose),
)
```

**Rules:**
- `semanticsLabel` on all `Image` widgets that convey meaning
- `ExcludeSemantics` on purely decorative widgets
- `MergeSemantics` to group related elements into a single focusable node
- Tab/focus order must match visual top-to-bottom, left-to-right order
- Never convey meaning by color alone — add icon or text alongside color indicator
- Support `MediaQuery.textScaleFactor` — never use fixed-height containers around text
- Ensure all interactive elements have `tooltip` or semantic label (icon-only buttons)
- `Focus` widget + keyboard support for desktop/tablet Flutter targets
- Test with TalkBack (Android) and VoiceOver (iOS) before release

**Anti-patterns:**
- `GestureDetector` without a `Semantics` wrapper (invisible to screen readers)
- Decorative images with meaningful `semanticsLabel` (confuses screen readers)
- Text widgets with hardcoded sizes that don't respect `textScaleFactor`

---

## 2. Touch & Interaction (CRITICAL)

**Minimum touch target:**
```dart
// Built-in constant — use it
const double minSize = kMinInteractiveDimension; // 48dp Material / maps to 44pt iOS

// Expanding small icons:
GestureDetector(
  behavior: HitTestBehavior.opaque,
  child: Padding(
    padding: EdgeInsets.all(12), // expands hit area without visual change
    child: Icon(Icons.info, size: 20),
  ),
)
```

**Rules:**
- All `InkWell`, `GestureDetector`, `TextButton`, `IconButton` targets ≥48dp (Material) / ≥44pt (iOS Cupertino)
- Minimum 8dp gap between adjacent touch targets
- Never rely on hover for primary interactions (mobile-first)
- Disable buttons during async operations and show loading indicator
- Use `InkWell` (Material ripple) or `GestureDetector` with `onTapDown`/scale feedback (Cupertino)
- Provide haptic feedback for confirmations: `HapticFeedback.mediumImpact()`
- Visual press feedback within 100ms — use `InkWell` or custom `AnimatedScale`
- Don't block system gestures (iOS swipe-back, Android predictive back)
- Swipe-back on iOS: ensure `Navigator` doesn't swallow the gesture

**Cupertino pattern:**
```dart
CupertinoButton(
  padding: EdgeInsets.all(12),
  onPressed: onAction,
  child: Icon(CupertinoIcons.heart),
)
```

---

## 3. Performance (HIGH)

**`const` constructors — use aggressively:**
```dart
const Text('Hello')          // ✅ rebuilt zero times
const SizedBox(height: 16)   // ✅
const Divider()              // ✅
```

**List performance:**
```dart
ListView.builder(             // ✅ lazy, O(1) memory
  itemCount: items.length,
  itemBuilder: (context, i) => ItemWidget(item: items[i]),
)
// NOT:
ListView(children: items.map((i) => ItemWidget(item: i)).toList()) // ❌ eager
```

**Rules:**
- `RepaintBoundary` around independently animating subtrees
- Cache `MediaQuery.of(context)` in a local variable — never call inside loops
- Use `cached_network_image` for all remote images (never raw `Image.network` without cache)
- Declare image dimensions or use `AspectRatio` to prevent layout jump
- Avoid `Opacity` widget for animation — use `AnimatedOpacity` or `flutter_animate` (opacity is a paint operation, not a layout one)
- Never animate `width`/`height` directly — use `AnimatedContainer` sparingly or prefer transform
- Use `SliverList`/`SliverGrid` inside `CustomScrollView` for complex scrolling layouts
- Profile with Flutter DevTools — no jank above 16ms per frame target
- `precacheImage` for images shown immediately on screen load

**Anti-patterns:**
- `setState` in `initState` without `WidgetsBinding.instance.addPostFrameCallback`
- Calling `setState` in build methods
- Deeply nested widget trees without decomposition — split into named widgets

---

## 4. Style & Theme (HIGH)

**ThemeData is your design system:**
```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF1A1A2E),
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.dmSansTextTheme(),
  cardTheme: CardTheme(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
)
```

**Rules:**
- One `ThemeData` for light, one for dark — never derive dark from light at runtime
- Define `CardTheme`, `InputDecorationTheme`, `AppBarTheme` at the theme level, not per-widget
- Consistent border radius scale — define as constants, e.g. `kRadiusSm = 8.0`, `kRadiusMd = 12.0`, `kRadiusLg = 20.0`
- Use `Theme.of(context).colorScheme` everywhere — never `Colors.blue` etc.
- Elevation: use consistent scale (0, 1, 3, 6, 8) — don't use arbitrary shadow values
- Icon style consistency: one icon family, one stroke weight throughout
- Platform-adaptive: consider `Theme.of(context).platform` to serve Cupertino widgets on iOS

**iOS (Cupertino) specifics:**
- Use `CupertinoNavigationBar` / `CupertinoTabBar` on iOS builds
- `CupertinoSwitch`, `CupertinoSlider`, `CupertinoActivityIndicator` for native feel
- Use `CupertinoPageRoute` for native swipe-back transitions

**Material 3 specifics:**
- Use `FilledButton`, `OutlinedButton`, `TextButton` (not deprecated `RaisedButton`)
- `NavigationBar` (M3) replaces `BottomNavigationBar` for Material apps

---

## 5. Layout & Responsive (HIGH)

**SafeArea — always:**
```dart
Scaffold(
  body: SafeArea(
    child: YourContent(),
  ),
)
```

**Responsive pattern:**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return TabletLayout();
    }
    return PhoneLayout();
  },
)
```

**Rules:**
- `SafeArea` on all top-level screens — never place content under notch, Dynamic Island, or gesture bar
- Use `MediaQuery.of(context).padding` to account for system bars in custom layouts
- Mobile-first: design for 375pt wide, then scale up
- No horizontal overflow — test with `flutter run --profile` on real device
- Use `LayoutBuilder` over `MediaQuery.of(context).size` for component-level responsiveness
- `OrientationBuilder` for landscape layout variants
- Spacing follows 4/8dp grid: `EdgeInsets.all(8)`, `SizedBox(height: 16)`, etc.
- Fixed bottom bars: use `Scaffold.bottomNavigationBar` so content auto-insets
- Scrollable content behind fixed bars: use `Scaffold` properties, not manual padding hacks
- `Expanded` and `Flexible` over hardcoded sizes inside `Row`/`Column`

**Anti-patterns:**
- `Container(height: 812)` — never hardcode device-specific dimensions
- `MediaQuery.of(context)` deep in widget trees — pass constraints down or use `LayoutBuilder`
- `SingleChildScrollView` wrapping a `Column` with `Expanded` children

---

## 6. Typography & Color (MEDIUM)

**Google Fonts — always a distinctive pairing:**
```dart
// Display / headings
GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w700)

// Body
GoogleFonts.dmSans(fontSize: 16, height: 1.5)
```

**Rules:**
- Body text minimum 16sp — iOS auto-zoom triggers below 16px equivalent
- Line height 1.5–1.75 for body text (`height` property on `TextStyle`)
- Font weight hierarchy: headings 600–700, body 400, labels 500
- Use `Theme.of(context).textTheme` roles: `displayLarge`, `titleMedium`, `bodyMedium`, `labelSmall`
- Never use `Text` with hardcoded `TextStyle` — extend theme styles: `Theme.of(context).textTheme.bodyMedium!.copyWith(...)`
- Color semantic tokens: `colorScheme.primary`, `colorScheme.surface`, `colorScheme.onSurface`, `colorScheme.error`
- Dark mode: use `ColorScheme.fromSeed(..., brightness: Brightness.dark)` — never invert light palette
- Contrast minimum 4.5:1 for body text, 3:1 for large text (>18sp regular or >14sp bold)
- Use tabular figures (`fontFeatures: [FontFeature.tabularFigures()]`) for prices, timers, counters

**Anti-patterns:**
- `Color(0xFF1A1A2E)` hardcoded in widget — use token
- `TextStyle(fontSize: 14, color: Colors.grey)` inline — use theme
- Same font size for headings and body

---

## 7. Animation (MEDIUM)

**flutter_animate — preferred for most animations:**
```dart
Text('Hello')
  .animate()
  .fadeIn(duration: 300.ms, curve: Curves.easeOut)
  .slideY(begin: 0.1, end: 0)
```

**Native AnimationController for custom:**
```dart
AnimationController(
  duration: const Duration(milliseconds: 250),
  vsync: this,
)..forward();
```

**Rules:**
- Micro-interactions: 150–300ms duration
- Complex transitions: 300–400ms max
- Enter: `Curves.easeOut`. Exit: `Curves.easeIn`. Never `Curves.linear` for UI
- Exit animations ~60–70% duration of enter (feels snappier)
- Animate only `transform` and `opacity` — never animate `width`/`height`/`padding` directly
- Stagger list item entrance: 30–50ms delay per item
- Shared element transitions: use `Hero` widget for navigating between screens
- Every animation must convey cause-effect — no purely decorative motion
- Respect `MediaQuery.disableAnimations` — wrap in check:
  ```dart
  if (!MediaQuery.of(context).disableAnimations) { /* animate */ }
  ```
- Page transitions: `go_router` supports custom `PageTransitionsBuilder`
- Forward navigation: slide left/up. Back: slide right/down. Maintain spatial continuity

**Anti-patterns:**
- `AnimatedContainer` with duration 0 (defeats purpose)
- Blocking user input during animation — use `IgnorePointer` sparingly
- More than 2 animated elements entering simultaneously without stagger

---

## 8. Forms & Feedback (MEDIUM)

```dart
Form(
  key: _formKey,
  child: Column(children: [
    TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',          // visible label, not placeholder-only
        helperText: 'Used for login',
        errorText: _emailError,      // below field, not only at top
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      validator: (v) => v!.isEmpty ? 'Required' : null,
    ),
  ]),
)
```

**Rules:**
- Visible `labelText` on every input — never placeholder-only
- Error messages below the field, not only at form top
- `keyboardType` matches input (email, phone, number, URL)
- `autofillHints` for all standard fields (email, password, name, phone)
- `TextInputAction.next` chains fields; `TextInputAction.done` on last field
- Auto-focus first invalid field after failed submit
- Confirm before destructive actions with `showDialog` / `CupertinoAlertDialog`
- `ScaffoldMessenger.showSnackBar` for transient feedback (3–5s auto-dismiss)
- Loading state on submit button: disable + show `CircularProgressIndicator`
- Password fields: `obscureText: true` with show/hide toggle
- Multi-step forms: show step indicator (`Stepper` widget or custom)
- `showModalBottomSheet` with `isDismissible: false` for flows with unsaved changes — confirm dismiss

**Anti-patterns:**
- `placeholder`-only input (no label) — fails accessibility
- Showing all form errors at top only with no per-field indication
- No loading state during async submit

---

## 9. Navigation (HIGH)

**go_router — standard:**
```dart
final router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => HomeScreen()),
  GoRoute(path: '/detail/:id', builder: (_, state) => DetailScreen(id: state.pathParameters['id']!)),
]);
```

**Rules:**
- `BottomNavigationBar` / `NavigationBar` (M3): maximum 5 items, always show labels
- `Drawer` for secondary/overflow navigation, never primary actions
- Back navigation must restore scroll position and filter state
- Every key screen reachable via deep link (`go_router` path)
- Current tab visually highlighted (selected state)
- `NavigationBar` for Android (Material), `CupertinoTabBar` for iOS
- iOS swipe-back gesture: never block `Navigator.pop` swipe
- Android predictive back: implement `PopScope` with `canPop` for confirmation dialogs
- Modals (`showModalBottomSheet`, `showDialog`) are NOT navigation — don't use for primary flows
- After route change, ensure `FocusScope.of(context).requestFocus` for accessibility

**Anti-patterns:**
- `BottomNavigationBar` with 6+ items
- Nested `Navigator` stacks without clear back-stack management
- Using `Navigator.pushReplacement` to implement tabs

---

## 10. Data Display (LOW)

**fl_chart for visualizations:**
```dart
LineChart(LineChartData(
  lineBarsData: [LineChartBarData(spots: dataPoints)],
  titlesData: FlTitlesData(/* always label axes */),
  // Always include tooltips
))
```

**Rules:**
- Always label chart axes with units
- Provide `Semantics` wrapper with text summary on charts (screen reader fallback)
- Never use color alone to distinguish data series — add shape, pattern, or label
- Accessible color palettes: avoid red/green only pairs
- `DataTable` with `sortColumnIndex` + `sortAscending` for sortable tables
- Show meaningful empty state when no data (not blank/broken chart)
- Skeleton/shimmer placeholder while chart data loads
- Respect `MediaQuery.disableAnimations` for chart entrance animations
- On small screens: simplify charts (fewer ticks, horizontal bar vs vertical, etc.)
- Touch targets on chart elements ≥44pt (use `touchData` in `fl_chart`)

---

## iOS HIG vs Material Design: Quick Reference

| Concern | iOS (Cupertino) | Android (Material 3) |
|---------|-----------------|----------------------|
| Primary nav | `CupertinoTabBar` (bottom) | `NavigationBar` (bottom) |
| Page transition | Horizontal slide (swipe-back) | Predictive back / fade-through |
| Alert | `CupertinoAlertDialog` | `AlertDialog` |
| Loading | `CupertinoActivityIndicator` | `CircularProgressIndicator` |
| Switch | `CupertinoSwitch` | `Switch` |
| Pull-to-refresh | `CupertinoSliverRefreshControl` | `RefreshIndicator` |
| Action sheet | `CupertinoActionSheet` | `ModalBottomSheet` |
| Haptics | `HapticFeedback.mediumImpact()` | `HapticFeedback.vibrate()` |
