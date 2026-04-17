# Flutter UI Aesthetics Guide

Design thinking and creative direction for Flutter apps. The goal is to produce interfaces that are memorable, intentional, and distinctly designed — not generic.

---

## Phase 1: Design Thinking

Before writing a single widget, answer these questions. Skipping this is why apps look generic.

### Define the Context

**User**: Who uses this? Age group, digital literacy, usage context (commute, focused work, leisure, emergencies)?

**Moment**: When do they open it? Morning routine? Mid-task? Bored? Stressed? The emotional context changes everything — a meditation app and a trading app need fundamentally different rhythms.

**Problem**: What's the core value in one sentence? This should inform visual hierarchy.

### Commit to an Aesthetic Direction

Pick one direction and execute it with precision. Mixing aesthetics produces mediocrity.

| Direction | Characteristics | Flutter Fit |
|-----------|----------------|-------------|
| **Brutally Minimal** | Heavy whitespace, single accent, quiet type, nothing decorative | Productivity, focus, professional tools |
| **Warm Editorial** | Serif display font, cream/warm tones, generous padding, slow motion | Lifestyle, journaling, reading, wellness |
| **Playful/Toy-like** | Large rounded corners, bold fills, bouncy physics, bright palette | Kids, games, habit trackers, social |
| **Luxury/Refined** | Dark surfaces, muted gold/silver, ultra-thin weights, slow fade transitions | Finance, premium subscriptions, fashion |
| **Vibrant/Energetic** | Saturated palette, bold display type, kinetic page transitions | Fitness, music, entertainment, sports |
| **Industrial/Utilitarian** | Monospaced type, tight grid, high contrast, no decoration | Dev tools, dashboards, data-heavy apps |
| **Organic/Natural** | Earth tones, soft gradients, fluid shapes, gentle spring physics | Health, nature, food, sustainability |
| **Retro-Futuristic** | Neon on dark, sharp geometric, scanline textures, typewriter feel | Gaming, tech, sci-fi adjacent products |

### The Differentiation Rule

Every app needs ONE thing users will remember. It could be:
- An unusual font pairing that becomes the brand
- A signature transition or gesture
- A background treatment (gradient mesh, noise texture, geometric pattern)
- An unexpected color combination that's cohesive
- A micro-interaction that surprises and delights

Identify this before coding. Build the whole app around it.

---

## Typography in Flutter

Typography is the fastest way to elevate or destroy an app's perceived quality.

### Google Fonts Setup
```dart
// pubspec.yaml
dependencies:
  google_fonts: ^6.0.0

// In ThemeData
ThemeData(
  textTheme: GoogleFonts.dmSansTextTheme(
    Theme.of(context).textTheme,
  ),
)

// Inline override for display text
GoogleFonts.playfairDisplay(
  fontSize: 40,
  fontWeight: FontWeight.w700,
  letterSpacing: -1.5,
)
```

### Strong Font Pairings for Flutter

| Direction | Display | Body | Feel |
|-----------|---------|------|------|
| Minimal/Premium | Cormorant Garamond | DM Sans | Refined, editorial |
| Playful | Fredoka One | Nunito | Friendly, approachable |
| Technical | Space Mono | Inter | Developer, precise |
| Luxury | Bodoni Moda | Lato | High-fashion, bold |
| Warm | Merriweather | Source Sans 3 | Trustworthy, readable |
| Energetic | Bebas Neue | Barlow | Athletic, punchy |
| Modern | Cabinet Grotesk | Satoshi | Startup, clean |
| Retro | VT323 | IBM Plex Mono | Nostalgic, digital |

### Typography Rules
- Body minimum 16sp — iOS will auto-zoom below 16px equivalent
- `height: 1.5` on body, `height: 1.2` on headlines
- Use `letterSpacing: -0.5` to `-2.0` on large display text (positive spacing on body feels amateur)
- Weight hierarchy: Display 700-900 / Title 600-700 / Body 400 / Caption 400 with color change
- Never use the same font for display and body — the contrast creates hierarchy
- Map fonts to `textTheme` roles so they propagate automatically throughout the app

---

## Color Strategy in Flutter

### ColorScheme.fromSeed — the right starting point
```dart
ColorScheme.fromSeed(
  seedColor: const Color(0xFF1B1F3A), // your brand anchor
  brightness: Brightness.light,
)
```

Material 3's tonal system generates a full palette from one seed. Use it.

### Custom Color System Pattern
```dart
// Define semantic constants
abstract class AppColors {
  static const brandDeep = Color(0xFF1B1F3A);
  static const accent = Color(0xFFE8C547);
  static const surfaceWarm = Color(0xFFF8F5EF);
  static const textPrimary = Color(0xFF141414);
  static const textMuted = Color(0xFF8A8A8A);
}

// Map to ColorScheme in ThemeData — never use raw AppColors in widgets
```

### Palette Principles
- **Dominant + Accent**: One strong base color (60%), one accent for CTAs (10%), neutrals fill the rest (30%). Even distribution looks amateur.
- **Dark mode is a separate design**: Don't invert. Design with different lightness/saturation. Desaturate slightly, lighten text, deepen surfaces.
- **Contrast floors**: 4.5:1 body text, 3:1 large text, 3:1 UI components (borders, icons). Test both modes.
- **Avoid red/green pairs alone** for data states — add shape or text alongside color.

### Background & Depth Techniques in Flutter

**Gradient mesh background:**
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1B1F3A), Color(0xFF0D1117)],
    ),
  ),
)
```

**Noise/grain texture overlay:**
```dart
// Use a subtle PNG noise texture as an overlay with low opacity
Opacity(
  opacity: 0.04,
  child: Image.asset('assets/noise.png', fit: BoxFit.cover),
)
```

**Blur effect (glassmorphism):**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(16),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: YourContent(),
    ),
  ),
)
```

**Custom painter for geometric/decorative backgrounds:**
```dart
CustomPaint(
  painter: GridPatternPainter(color: Colors.white.withOpacity(0.05)),
  child: YourScreen(),
)
```

---

## Motion Design in Flutter

Motion communicates — it's not decoration. Every animation should have a reason.

### flutter_animate — the standard
```dart
// Staggered list entrance
...items.asMap().entries.map((e) =>
  ItemWidget(item: e.value)
    .animate(delay: (50 * e.key).ms)
    .fadeIn(duration: 300.ms, curve: Curves.easeOut)
    .slideY(begin: 0.08, end: 0)
)

// Page hero entrance
Column(children: [
  TitleText().animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),
  SubtitleText().animate(delay: 100.ms).fadeIn(duration: 300.ms),
  CTAButton().animate(delay: 200.ms).fadeIn(duration: 300.ms).scale(begin: Offset(0.95, 0.95)),
])
```

### Timing Reference

| Type | Duration | Curve |
|------|----------|-------|
| Micro-interaction (tap, toggle) | 150ms | `easeOut` |
| Modal/sheet enter | 300ms | `easeOut` |
| Modal/sheet exit | 200ms | `easeIn` |
| Page transition | 350ms | `easeInOut` |
| List item stagger | +40ms per item | `easeOut` |
| Complex orchestration | 400ms max | spring/physics |

### Spring Physics (natural feel)
```dart
// flutter_animate spring
.animate().scale(
  duration: 600.ms,
  curve: Curves.elasticOut,
)

// Custom spring simulation
SpringSimulation(
  SpringDescription(mass: 1, stiffness: 180, damping: 20),
  0, 1, 0,
)
```

### Page Transitions with go_router
```dart
GoRoute(
  path: '/detail',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: DetailScreen(),
    transitionsBuilder: (context, animation, _, child) {
      return SlideTransition(
        position: Tween(begin: Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  ),
)
```

### Reduced Motion — always respect
```dart
final reduceMotion = MediaQuery.of(context).disableAnimations;

if (reduceMotion) {
  // Show final state immediately, no animation
} else {
  // Animate
}
```

---

## Spatial Composition Principles

**Break the grid occasionally**: Predictable layouts are forgettable. Offset an image, let a headline overflow its column, stack elements with a slight diagonal.

**Use negative space with intent**: Empty space is not wasted space — it creates breathing room and draws attention to what matters. Especially powerful in minimal directions.

**Asymmetry over perfect centering**: Centered layouts with equal padding on all sides signal template thinking. Try `padding: EdgeInsets.fromLTRB(24, 48, 24, 16)` with intentional imbalance.

**Layering and depth**: Use `Stack` to overlap elements. Cards peeking behind header images. Text overlaid on photos with gradient scrim. Depth creates richness.

**Consistent rhythm, not uniformity**: Spacing should feel like a rhythm — sections breathe differently than items within a section. Use 8dp within components, 24dp between sections, 48dp between major areas.

---

## The Anti-Generic Checklist

Before calling a design done, verify:

- [ ] Display font is NOT Roboto, Inter, or a system font default
- [ ] Primary color is NOT system blue or Material default purple
- [ ] There is NO purple gradient on a white background
- [ ] Cards are NOT white on white — they have elevation, border, or a tinted surface
- [ ] There is at least ONE memorable visual element specific to this app
- [ ] Motion exists and feels intentional, not just `AnimatedOpacity` slapped on
- [ ] Spacing is not uniform padding(16) everywhere — it has rhythm
- [ ] Emoji are not used as icons
- [ ] Each main screen has a distinct visual emphasis point
