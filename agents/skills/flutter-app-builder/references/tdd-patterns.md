# TDD Patterns for Flutter

## Red-Green-Refactor Commit Cycle

Each TDD cycle produces 2-3 atomic commits:

```
test(scope): add <FeatureName> failing tests        ← RED commit
feat(scope): implement <FeatureName>                ← GREEN commit
refactor(scope): clean up <FeatureName>             ← IMPROVE commit (optional)
```

Scopes follow module/feature name (e.g., `auth`, `product`, `cart`, `home`).

---

## File Structure

```
test/
├── unit/
│   ├── data/
│   │   ├── datasources/        # RemoteDataSource tests (mock HTTP)
│   │   └── repositories/       # Repository tests (mock datasources)
│   ├── domain/
│   │   └── usecases/           # UseCase tests (mock repositories)
│   └── presentation/
│       └── blocs/              # BLoC/Cubit tests (bloc_test)
├── widget/
│   └── screens/                # Widget tests (pump + find)
└── helpers/
    ├── fakes/                  # Hand-written fakes (preferred over mocks)
    └── fixtures/               # JSON fixtures for API responses

integration_test/
└── flows/                      # Full E2E flows (real app, real navigation)
```

---

## Mock Conventions

### Prefer fakes over mocks for repositories

```dart
// PREFERRED: hand-written fake
class FakeAuthRepository implements AuthRepository {
  User? stubbedUser;
  Failure? forceFailure;

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (forceFailure != null) return Left(forceFailure!);
    return Right(stubbedUser ?? User.fixture());
  }
}
```

```dart
// ACCEPTABLE for datasource HTTP calls
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

// Setup
when(() => mockDatasource.login(any(), any()))
    .thenAnswer((_) async => UserModel.fromFixture());
```

### Fixture pattern

```dart
// test/helpers/fixtures/user_fixture.dart
extension UserFixture on User {
  static User valid() => const User(
        id: 'test-user-1',
        name: 'Test User',
        email: 'test@example.com',
      );
}
```

Load JSON fixtures from files for API response mocking:

```dart
String fixture(String name) =>
    File('test/helpers/fixtures/$name.json').readAsStringSync();
```

---

## BLoC / Cubit Tests

```dart
blocTest<LoginCubit, LoginState>(
  'emits [LoginLoading, LoginSuccess] on valid credentials',
  build: () {
    when(() => fakeRepo.login(any(), any()))
        .thenAnswer((_) async => Right(UserFixture.valid()));
    return LoginCubit(repository: fakeRepo);
  },
  act: (cubit) => cubit.login(email: 'a@b.com', password: 'pass'),
  expect: () => [LoginLoading(), LoginSuccess(UserFixture.valid())],
);

blocTest<LoginCubit, LoginState>(
  'emits [LoginLoading, LoginFailure] on invalid credentials',
  build: () {
    when(() => fakeRepo.login(any(), any()))
        .thenAnswer((_) async => Left(UnauthorizedFailure()));
    return LoginCubit(repository: fakeRepo);
  },
  act: (cubit) => cubit.login(email: 'bad@b.com', password: 'wrong'),
  expect: () => [LoginLoading(), isA<LoginFailure>()],
);
```

---

## UseCase Tests

```dart
group('LoginUseCase', () {
  late LoginUseCase useCase;
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    useCase = LoginUseCase(repository: fakeRepo);
  });

  test('returns User on success', () async {
    fakeRepo.stubbedUser = UserFixture.valid();

    final result = await useCase(LoginParams(email: 'a@b.com', password: 'pw'));

    expect(result, Right(UserFixture.valid()));
  });

  test('returns Failure when repository fails', () async {
    fakeRepo.forceFailure = UnauthorizedFailure();

    final result = await useCase(LoginParams(email: 'a@b.com', password: 'bad'));

    expect(result, Left(isA<UnauthorizedFailure>()));
  });
});
```

---

## Repository Tests

```dart
group('AuthRepositoryImpl', () {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemote;

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remote: mockRemote);
  });

  test('returns User on 200 response', () async {
    when(() => mockRemote.login(any(), any()))
        .thenAnswer((_) async => UserModel.fromJson(
              json.decode(fixture('user')) as Map<String, dynamic>));

    final result = await repository.login('a@b.com', 'pw');

    expect(result.isRight(), true);
  });

  test('returns ServerFailure on DioException', () async {
    when(() => mockRemote.login(any(), any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: '/login')));

    final result = await repository.login('a@b.com', 'pw');

    expect(result, Left(isA<ServerFailure>()));
  });
});
```

---

## Widget Tests

```dart
testWidgets('LoginScreen shows error message on failure', (tester) async {
  final cubit = MockLoginCubit();
  whenListen(
    cubit,
    Stream.fromIterable([LoginLoading(), LoginFailure('Invalid credentials')]),
    initialState: LoginInitial(),
  );

  await tester.pumpWidget(
    BlocProvider<LoginCubit>.value(
      value: cubit,
      child: const MaterialApp(home: LoginScreen()),
    ),
  );

  await tester.pump();
  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

---

## Security-Relevant Test Cases (mandatory)

For any auth, storage, or input-handling feature:

| Test case | What to verify |
|-----------|---------------|
| Token stored securely | `FlutterSecureStorage.write` called, not `SharedPreferences` |
| Logout clears credentials | `FlutterSecureStorage.deleteAll` called on logout |
| Input validation | Form rejects empty/malformed email, short passwords |
| Auth state expiry | BLoC transitions to unauthenticated on 401 response |
| No PII in logs | `debugPrint` calls do not include tokens, passwords, or email |
