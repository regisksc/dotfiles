---
name: flutter-ui-design
description: This skill should be used when the user asks to "build a Flutter app", "design a Flutter screen", "create a Flutter UI", "review a Flutter interface", "audit Flutter app design", "start a Flutter app from scratch", "improve Flutter aesthetics", "check Flutter accessibility", "make Flutter app look professional", "refactor Flutter UI", or any task involving Flutter UI/UX design, visual polish, or platform quality for iOS and Android mobile.
version: 0.1.0
---

# Flutter UI Design

Unified design intelligence for Flutter app development — merging bold aesthetic direction with systematic platform quality rules for iOS and Android.

Two modes:

- **Build mode**: Starting a new screen, feature, or app from scratch
- **Review mode**: Auditing or improving an existing Flutter codebase

---

## Build Mode: Design Thinking First

Before writing any Flutter code, commit to a **clear aesthetic direction**. Generic apps fail not from bad code — but from lack of design intent.

Define these upfront:

**Purpose**: What problem does this app/screen solve? Who uses it, and in what context (commute, desk, focused task, leisure)?

**Tone**: Pick a direction and execute it with precision. Examples:
- Brutally minimal — high whitespace, one accent, quiet type
- Warm/editorial — serif display font, cream tones, generous padding
- Playful/toy-like — rounded shapes, bold fills, bouncy animations
- Luxury/refined — dark surfaces, muted gold, thin weights, slow motion
- Vibrant/energetic — saturated palette, bold headlines, kinetic transitions
- Industrial/utilitarian — monospaced type, grid density, raw contrast
- Organic/natural — earth tones, soft gradients, fluid shapes

**Differentiation**: What is the ONE visual element users will remember?

**Platform target**: iOS only, Android only, or both? Determines widget strategy (Cupertino vs Material vs fully custom).

See `references/aesthetics.md` for detailed guidance on typography, color systems, motion, and creative execution in Flutter.

---

## Flutter Design System Setup

Establish a design system before building any screens. This replaces ad-hoc styling with a consistent token system.

**ThemeData — the single source of truth:**
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: yourBrandColor),
  textTheme: GoogleFonts.playfairDisplayTextTheme(),
  useMaterial3: true,
)
```

**Rules:**
- Never hardcode hex colors in widgets — always use `Theme.of(context).colorScheme.*`
- Never hardcode text styles inline — always use `Theme.of(context).textTheme.*`
- Define a radius scale (e.g., 4, 8, 12, 20dp) and apply it consistently via `BorderRadius`
- Define a spacing scale (4/8dp grid) and use it for all padding/margin/gap values

---

## Implementation Priority Order

Follow this priority order when building or reviewing. Higher = more critical impact.

| Priority | Category | Flutter Key Patterns | Severity |
|----------|----------|----------------------|----------|
| 1 | Accessibility | `Semantics`, `semanticsLabel`, `ExcludeSemantics` | CRITICAL |
| 2 | Touch & Interaction | `kMinInteractiveDimension` (44pt/48dp), `InkWell`, `GestureDetector` | CRITICAL |
| 3 | Performance | `const` constructors, `ListView.builder`, `RepaintBoundary` | HIGH |
| 4 | Style & Theme | `ThemeData`, `ColorScheme`, consistent radius/spacing | HIGH |
| 5 | Layout & Responsive | `SafeArea`, `MediaQuery`, `LayoutBuilder`, `OrientationBuilder` | HIGH |
| 6 | Typography & Color | `google_fonts`, semantic text/color tokens, contrast | MEDIUM |
| 7 | Animation | `flutter_animate`, `AnimationController`, 150–300ms | MEDIUM |
| 8 | Forms & Feedback | `Form`, `TextFormField`, `ScaffoldMessenger`, `showDialog` | MEDIUM |
| 9 | Navigation | `go_router`, `BottomNavigationBar` ≤5, `Drawer` for secondary | HIGH |
| 10 | Data Display | `fl_chart`, accessible palettes, `DataTable` | LOW |

Full rules with Flutter widget implementations per category: `references/platform-rules.md`.

---

## Aesthetic Anti-Patterns (Never Do These)

The Flutter equivalent of generic "AI slop":

- **Default Roboto everywhere** — use `google_fonts` with a distinctive pairing
- **Purple gradient on white** — commit to a real palette with semantic purpose
- **White cards on white background** — use elevation, subtle tint, or border
- **System blue as primary** — brand your `ColorScheme`, don't ship defaults
- **Identical screens** — each screen deserves a distinct visual rhythm
- **Cookie-cutter `ListTile` layouts** — customize or compose from primitives
- **No motion whatsoever** — even minimal apps need meaningful page transitions
- **Square everything with no radius system** — commit to a radius scale
- **Emoji as structural icons** — use `flutter_svg`, `Icons.*`, or `phosphor_flutter`
- **Only `showSnackBar` for all feedback** — design feedback into the UI itself

---

## Review Mode: Quick Audit

When reviewing an existing Flutter app, check in this order:

**Critical (fix before shipping):**
- [ ] All tappable elements ≥44pt iOS / ≥48dp Android
- [ ] `SafeArea` on all top-level `Scaffold` screens
- [ ] `Semantics` / `semanticsLabel` on icon-only buttons
- [ ] No hardcoded hex — all colors via `Theme.of(context).colorScheme`
- [ ] Text contrast ≥4.5:1 in both light and dark mode
- [ ] `const` on stateless widgets and immutable subtrees

**High (address before release):**
- [ ] `ListView.builder` / `SliverList` for lists with 10+ items
- [ ] `RepaintBoundary` wrapping independently animating widgets
- [ ] `go_router` or Navigator 2.0 for deep linking support
- [ ] `cached_network_image` for all remote images
- [ ] Dark mode tested independently (not inferred from light theme)

**Aesthetic (raise design quality):**
- [ ] Display font is distinctive, not default Roboto
- [ ] Color palette has hierarchy (dominant + accent, not evenly distributed)
- [ ] Page transitions and micro-interactions exist and feel native
- [ ] Spacing follows a consistent 4/8dp grid
- [ ] The app has one memorable visual element

Full extended checklist: `references/checklist.md`.

---

## Searchable Database

The skill includes a BM25 search engine over 8 curated databases. Use it to get data-driven recommendations before designing.

### Generate a complete Flutter design system (start here):
```bash
python3 scripts/search.py "fitness tracker vibrant ios android" --design-system -p "FitApp"
```
Returns: product type match, style recommendations, color palette, typography pairing.

### Search a specific domain:
```bash
python3 scripts/search.py "<query>" --domain <domain> [-n <max_results>]
```

| Domain | Use For | Example Query |
|--------|---------|---------------|
| `product` | Product type patterns by industry | `"meditation wellness calm"` |
| `style` | UI style options (glassmorphism, minimal, etc.) | `"dark luxury refined"` |
| `color` | Color palettes by product type | `"fintech crypto dark"` |
| `typography` | Font pairings by mood | `"playful energetic bold"` |
| `google-fonts` | Individual Google Font lookup | `"serif variable popular"` |
| `ux` | UX best practices by topic | `"animation accessibility gesture"` |
| `chart` | Chart type recommendations | `"comparison trend over time"` |

### Flutter-specific guidelines:
```bash
python3 scripts/search.py "<query>" --stack flutter
```
Searches `flutter.csv` — 30+ Flutter-specific rules with Dart code examples covering widgets, performance, navigation, theming, accessibility, platform adaptation.

**Examples:**
```bash
python3 scripts/search.py "list performance" --stack flutter
python3 scripts/search.py "safe area layout" --stack flutter
python3 scripts/search.py "haptic feedback touch" --stack flutter
```

### Persist design system to file (for multi-session projects):
```bash
python3 scripts/search.py "ecommerce fashion luxury" --design-system --persist -p "StyleApp"
# Creates design-system/MASTER.md + optionally design-system/pages/home.md
```

---

## Recommended Packages

| Need | Package |
|------|---------|
| Typography | `google_fonts` |
| Animation | `flutter_animate`, `animations` (Material) |
| Navigation | `go_router` |
| Icons | `flutter_svg`, `phosphor_flutter` |
| Image caching | `cached_network_image` |
| Charts | `fl_chart` |
| Lottie | `lottie` |
| Responsive layout | `LayoutBuilder` + `MediaQuery` (built-in) |
| Haptics | `HapticFeedback` (built-in) |
| Blur effects | `BackdropFilter` + `ImageFilter.blur` (built-in) |

---

## Additional Resources

- **`references/platform-rules.md`** — Full rule set for all 10 categories with Flutter widget implementations, iOS HIG, and Material Design specifics
- **`references/aesthetics.md`** — Design thinking process, aesthetic directions, typography, color strategy, and motion design for Flutter
- **`references/checklist.md`** — Complete pre-delivery checklist covering visual, interaction, accessibility, layout, and dark mode
