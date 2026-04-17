# Flutter Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Flutter and Dart-specific content.

## Formatting

- Follow `dart format` defaults (80-char line length)
- Use trailing commas in multi-line parameter/argument lists to improve diffs
- Prefer `const` constructors wherever possible — annotate with `const` keyword

## Immutability

- Prefer immutable widget properties; accept state only in `StatefulWidget` when necessary
- Use `final` for all widget fields and local variables that don't reassign
- Use `const` for widget instantiation to enable widget tree short-circuiting

## Naming

- Files: `snake_case.dart`
- Classes/Widgets: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` (Dart convention; avoid `SCREAMING_SNAKE`)
- Private members: prefix with `_`
- BLoC/Cubit classes: `<Feature>Bloc`, `<Feature>Cubit`, `<Feature>State`, `<Feature>Event`

## Null Safety

- Enable sound null safety (Dart 3+); never disable with `//!`
- Use `?` only when null is a meaningful value, not as a convenience
- Prefer `late` over nullable for fields initialized before first use
- Use `??` for defaults, `?.` for safe calls — avoid `!` unless you have proven non-null

## Logging

- Use `debugPrint` instead of `print` for all debug output
- Never leave `print` statements in production code
- Use `FlutterError.reportError` for framework-level error reporting

## Widget Structure

- One public widget per file
- Keep `build` methods short — extract sub-widgets or helper methods
- Prefer stateless widgets; lift state up to the nearest ancestor that needs it
- Use `Key` parameters on list items and dynamically created widgets
