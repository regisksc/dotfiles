# Flutter Testing

> This file extends [common/testing.md](../common/testing.md) with Flutter and Dart-specific content.

## Test Framework

Use `flutter_test` (built-in), `bloc_test` for BLoC/Cubit, `mocktail` for mocks:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  bloc_test: ^9.0.0
  mocktail: ^1.0.0
```

## Widget Testing

```dart
testWidgets('UserCard displays user name', (tester) async {
  const user = User(id: '1', name: 'Alice', email: 'alice@example.com');

  await tester.pumpWidget(
    const MaterialApp(home: UserCard(user: user)),
  );

  expect(find.text('Alice'), findsOneWidget);
  expect(find.text('alice@example.com'), findsOneWidget);
});
```

## BLoC/Cubit Testing

```dart
blocTest<CounterCubit, int>(
  'emits [1] when increment is called',
  build: () => CounterCubit(),
  act: (cubit) => cubit.increment(),
  expect: () => [1],
);

blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthSuccess] on valid login',
  build: () {
    when(() => mockAuthRepository.login(any(), any()))
        .thenAnswer((_) async => Right(fakeUser));
    return AuthBloc(authRepository: mockAuthRepository);
  },
  act: (bloc) => bloc.add(AuthLoginRequested(email: 'a@b.com', password: 'pw')),
  expect: () => [AuthLoading(), AuthSuccess(fakeUser)],
);
```

## Fakes Over Mocks

Prefer hand-written fakes for repositories:

```dart
class FakeUserRepository implements UserRepository {
  final List<User> users = [];
  Failure? forceFailure;

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    if (forceFailure != null) return Left(forceFailure!);
    final user = users.firstWhere((u) => u.id == id);
    return Right(user);
  }
}
```

## Integration Tests

Use `integration_test` package for end-to-end flows:

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login flow completes', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('email_field')), 'user@test.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

## Test Organization

```
test/
├── unit/
│   ├── blocs/
│   ├── cubits/
│   ├── repositories/
│   └── usecases/
├── widget/
│   └── screens/
└── helpers/
    ├── fakes.dart
    └── fixtures.dart

integration_test/
└── app_test.dart
```

## Test Naming

```dart
// Good
test('getUser returns User when repository succeeds', () {});
testWidgets('LoginScreen shows error on invalid credentials', (t) async {});
blocTest<AuthBloc, AuthState>('emits AuthFailure when login throws', ...);
```
