# iOS Patterns

> This file extends [common/patterns.md](../common/patterns.md) and [swift/patterns.md](../swift/patterns.md) with iOS SwiftUI and architecture patterns.

## ViewModel (Observable)

```swift
import Observation

@Observable
final class UserViewModel {
    private(set) var user: User?
    private(set) var isLoading = false
    private(set) var error: String?

    private let getUserUseCase: GetUserUseCase

    init(getUserUseCase: GetUserUseCase) {
        self.getUserUseCase = getUserUseCase
    }

    @MainActor
    func loadUser(id: String) async {
        isLoading = true
        error = nil
        do {
            user = try await getUserUseCase.execute(id: id)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
```

## View + ViewModel Binding

```swift
struct UserScreen: View {
    @State private var viewModel = UserViewModel(getUserUseCase: DefaultGetUserUseCase())
    let userId: String

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.error {
                ErrorView(message: error, onRetry: { Task { await viewModel.loadUser(id: userId) } })
            } else if let user = viewModel.user {
                UserDetailView(user: user)
            }
        }
        .task { await viewModel.loadUser(id: userId) }
    }
}
```

## Repository Pattern

```swift
protocol UserRepository {
    func getUser(id: String) async throws -> User
    func getUsers() async throws -> [User]
}

final class DefaultUserRepository: UserRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getUser(id: String) async throws -> User {
        try await apiClient.request(.getUser(id: id))
    }
}
```

## Dependency Container

```swift
@MainActor
final class AppContainer {
    static let shared = AppContainer()

    lazy var apiClient: APIClient = DefaultAPIClient()
    lazy var userRepository: UserRepository = DefaultUserRepository(apiClient: apiClient)
    lazy var getUserUseCase: GetUserUseCase = DefaultGetUserUseCase(repository: userRepository)
}
```

## Navigation

```swift
enum AppRoute: Hashable {
    case userDetail(id: String)
    case settings
}

struct AppNavigationStack: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(onUserTap: { id in path.append(AppRoute.userDetail(id: id)) })
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .userDetail(let id): UserScreen(userId: id)
                    case .settings: SettingsView()
                    }
                }
        }
    }
}
```
