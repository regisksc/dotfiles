# iOS Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) and [swift/coding-style.md](../swift/coding-style.md) with iOS-specific content.

## Project Structure

Follow Clean Architecture with feature folders:

```
Sources/
├── App/               # App entry, root view, DI container
├── Core/              # Network, persistence, DI, utilities
├── Domain/            # Models, repository protocols, use cases
└── Features/
    └── <Feature>/
        ├── Data/      # Repository implementations, DTOs
        ├── Domain/    # Feature-specific use cases
        └── UI/        # Views, ViewModels, Previews
```

## SwiftUI

- Keep `View` `body` properties short — extract subviews as computed properties or separate `View` types
- Use `@ViewBuilder` for conditional view composition
- Mark all preview providers with `#Preview` (Xcode 15+) or `PreviewProvider`
- Use `@Environment(\.dismiss)` instead of `presentationMode` (iOS 15+)

## Naming

- Views: `<Feature>View`, `<Feature>Screen`
- ViewModels: `@Observable class <Feature>ViewModel` or `@MainActor class <Feature>ViewModel: ObservableObject`
- Protocols: `<Noun>Repository`, `<Verb>UseCase`
- Constants: `enum Constants` or `private let` at file scope

## Logging

- Use `os.Logger` for structured logging; never use `print` in production
- Define a logger per subsystem:

```swift
import OSLog

private let logger = Logger(subsystem: "com.example.app", category: "UserFeature")
logger.debug("Loading user \(id)")
logger.error("Failed to load user: \(error.localizedDescription)")
```
