---
name: flutter-shell
description: Use after a scope has been approved to build the minimum running app skeleton — navigation structure, theme, Riverpod providers wired with stub state, placeholder screens. No real feature logic yet. App must run on device. Registers the artifact in .sessions/INDEX.md.
version: 0.0.2
---

# Flutter Shell

Builds the minimum viable running skeleton. Every feature will be layered on top of this.

**Precondition:** `.sessions/INDEX.md` must have a `scope` entry. If not, run `/flutter-scope` first.

---

## Step 0 — Read index and scope

Read `.sessions/INDEX.md`. Find the latest `scope` row. Read that artifact file in full — specifically:
- **Functional Requirements** → screen map, providers needed, data layer
- **UX / UI Direction** → tone, color direction, typography, motion character, layout, interaction patterns

This section drives every design decision in this skill. Do not guess or default — use what scope says.

```bash
date +"%Y-%m-%dT%H:%M"
```

---

## Step 1 — Directory structure

Create only the directories actually needed by this scope:

```
lib/src/
  core/
    theme/         ← ThemeData, color tokens, text styles
    router/        ← GoRouter configuration
  domain/
    entities/      ← Pure Dart classes, zero Flutter imports
    repositories/  ← Abstract interfaces only
    failures/      ← Sealed failure hierarchy
  data/
    repositories/  ← Stub implementations (empty/placeholder data)
    datasources/   ← Abstract + stub implementations
  presentation/
    screens/       ← One file per screen
    widgets/       ← Shared chrome only (bottom nav, app bar)
    providers/     ← Riverpod providers
```

Skip any layer the scope doesn't need (e.g. no `datasources/` if data is local in-memory).

---

## Step 2 — Design system

Read the **UX / UI Direction** section from the scope artifact. Then:

1. Invoke `frontend-design` — pass the color direction, typography, and layout intent from scope. It returns concrete design tokens: hex values, font choices, spacing scale, elevation, border radii.

2. Invoke `ui-ux-pro-max` — pass the motion character, interaction patterns, and accessibility intent from scope. It returns: animation durations/curves, gesture patterns, state design guidelines, and accessibility checklist for this app.

Write `lib/src/core/theme/app_theme.dart` using the tokens from `frontend-design`. Structure:

```dart
/// Design system for [AppName].
///
/// Derived from scope ID [scope-ID] UX/UI Direction.
/// Tone: [one line from scope]
/// Do not add hardcoded colors or text styles outside this file.
abstract final class AppColors {
  // [tokens from frontend-design output]
}

abstract final class AppTextStyles {
  // [text styles from frontend-design output]
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppTheme {
  static ThemeData get dark => ThemeData(/* ... */);
}
```

Write `lib/src/core/theme/app_motion.dart` for the motion constants from `ui-ux-pro-max`:

```dart
/// Motion constants derived from scope UX/UI Direction.
/// Character: [motion character from scope]
abstract final class AppMotion {
  static const fast = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
  static const curve = Curves.easeOutCubic; // or as specified
}
```

Wire `AppTheme.dark` into `MaterialApp.router`.

---

## Step 3 — Navigation (GoRouter)

```dart
/// App router. Single source of truth for all routes.
/// Add new routes here when adding features — never create ad-hoc navigators.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [ /* routes from scope */ ],
  );
});
```

---

## Step 4 — Placeholder screens

One `StatelessWidget` per screen. No business logic:

```dart
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Workouts')));
  }
}
```

**Rule:** No widget-returning methods. Sub-elements that will become real widgets must be `StatelessWidget` stubs from the start.

---

## Step 5 — Riverpod providers (stub state)

```dart
/// Provides the list of [Entity].
///
/// Returns an empty list initially.
/// Real implementation added in [feature-name] feature (scope ref: [scope-ID]).
@riverpod
Future<List<Entity>> entities(Ref ref) async => [];
```

---

## Step 6 — Wire main.dart

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
```

---

## Step 7 — Verify and commit

```bash
fvm flutter analyze    # zero errors, zero warnings
fvm flutter test       # passes (no tests yet is acceptable)
fvm flutter format .
git add lib/ pubspec.yaml
git commit -m "chore: app shell"
```

Fix any failures before committing.

---

## Step 8 — Write artifact and update index

Write `.sessions/[ID]-[TIMESTAMP]-shell.md`:

```markdown
---
id: [ID]
timestamp: [TIMESTAMP]
type: shell
slug: shell
parent_ids: [[scope-ID]]
summary: [N screens, navigation structure, theme color, N providers wired]
---

## Context Recovery

**Scope:** [scope summary] (see ID [scope-ID])
**This artifact:** Navigation shell — the running skeleton all features build on.

To recover this state: run `fvm flutter run`. The app shows placeholder screens
with the navigation structure and theme, no real feature logic.

---

## What was built

### Screens
[List of screen names and their routes]

### Theme
[Accent color, background, surface values used]

### Providers (stub)
[List of providers created and their intended purpose]

### Architecture
[Directory structure created — note any layers skipped and why]

---

## Feature Kickoff Summary

> This section is read by flutter-feature at Step 0.
> It gives the feature skill everything it needs to start without re-reading the full scope.

### Design tokens in use
- Background: `AppColors.background` = [hex]
- Surface: `AppColors.surface` = [hex]
- Accent: `AppColors.accent` = [hex]
- Primary text: `AppColors.onBackground` = [hex]
- Secondary text: `AppColors.onSurface` = [hex]
- Standard motion: `AppMotion.standard` = [Xms], curve: [curve name]

### Theme files
- `lib/src/core/theme/app_theme.dart` — colors, text styles, ThemeData
- `lib/src/core/theme/app_motion.dart` — durations and curves

### Router
- File: `lib/src/core/router/app_router.dart`
- Routes: [list each path → screen class]

### Stub providers
[Provider name → file path → what it will hold when real]

### Architecture layers created
[Which of domain/data/presentation dirs exist and what's in each]

### UX constraints for features
- Spacing scale: `AppSpacing.[xs/sm/md/lg/xl]` — always use these, never hardcode
- Touch targets: ≥ 48dp on all interactive elements
- Motion: use `AppMotion.*` constants — no hardcoded durations
- Lists: always `ListView.builder` / `GridView.builder`
- No widget-returning methods — extract `StatelessWidget`s
```

Append to `.sessions/INDEX.md`:
```
| [ID] | [TIMESTAMP] | shell | shell | [N screens, theme, N providers] | .sessions/[filename] |
```

---

## Step 9 — Checkpoint

```
Shell complete → .sessions/[filename] (ID: [ID])

Run the app:  fvm flutter run

You should see:
- [list screens and navigation from scope]
- Dark theme with [accent] accent
- Navigation working between placeholder screens

Does the structure match what you had in mind?
```

**Wait for confirmation before proceeding.**

**Next skill:** `/flutter-feature` — pass the first feature from `BACKLOG.md`.
