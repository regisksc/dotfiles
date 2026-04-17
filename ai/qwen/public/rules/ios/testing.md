# iOS Testing

> This file extends [common/testing.md](../common/testing.md) and [swift/testing.md](../swift/testing.md) with iOS SwiftUI testing patterns.

## Test Framework

Use Swift Testing (Xcode 16+) for unit tests; XCTest for UI tests:

```swift
import Testing

@Suite("UserViewModel")
struct UserViewModelTests {
    @Test("loads user on success")
    func loadsUserOnSuccess() async throws {
        let fakeRepo = FakeUserRepository()
        fakeRepo.stubbedUser = .fixture()
        let viewModel = UserViewModel(getUserUseCase: DefaultGetUserUseCase(repository: fakeRepo))

        await viewModel.loadUser(id: "1")

        #expect(viewModel.user == .fixture())
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("sets error on failure")
    func setsErrorOnFailure() async {
        let fakeRepo = FakeUserRepository()
        fakeRepo.shouldThrow = true
        let viewModel = UserViewModel(getUserUseCase: DefaultGetUserUseCase(repository: fakeRepo))

        await viewModel.loadUser(id: "1")

        #expect(viewModel.error != nil)
    }
}
```

## Fakes Over Mocks

```swift
final class FakeUserRepository: UserRepository {
    var stubbedUser: User?
    var shouldThrow = false

    func getUser(id: String) async throws -> User {
        if shouldThrow { throw AppError.notFound }
        return stubbedUser ?? .fixture()
    }

    func getUsers() async throws -> [User] { [] }
}
```

## UI Testing with XCTest

```swift
final class LoginUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    func testLoginFlow() {
        app.textFields["email_field"].tap()
        app.textFields["email_field"].typeText("user@test.com")
        app.secureTextFields["password_field"].tap()
        app.secureTextFields["password_field"].typeText("password")
        app.buttons["login_button"].tap()

        XCTAssertTrue(app.otherElements["home_screen"].waitForExistence(timeout: 5))
    }
}
```

## Test Organization

```
Tests/
├── Unit/
│   ├── ViewModels/
│   ├── UseCases/
│   └── Repositories/
├── Helpers/
│   ├── Fakes/
│   └── Fixtures/
└── Snapshots/      # Optional: swift-snapshot-testing

UITests/
└── Flows/
```
