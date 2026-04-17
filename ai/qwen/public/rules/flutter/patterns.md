# Flutter Patterns

> This file extends [common/patterns.md](../common/patterns.md) with Flutter and Dart-specific content.

## State Management

Prefer BLoC/Cubit for complex features, Provider/Riverpod for simpler cases:

```dart
// Cubit (simple state)
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

// BLoC (event-driven)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }
}
```

## Repository Pattern

```dart
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, List<User>>> getUsers();
}

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required UserRemoteDataSource remote});

  final UserRemoteDataSource _remote;

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    try {
      final user = await _remote.getUser(id);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

## Dependency Injection

Use `get_it` + `injectable` or manual registration:

```dart
final getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<Dio>(() => Dio())
    ..registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(dio: getIt()),
    )
    ..registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(remote: getIt()),
    )
    ..registerFactory(() => UserCubit(repository: getIt()));
}
```

## Navigation

Prefer `go_router` for declarative routing:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/user/:id',
      builder: (context, state) => UserScreen(id: state.pathParameters['id']!),
    ),
  ],
);
```

## Widget Composition

Extract reusable widgets over long `build` methods:

```dart
// Good: small, focused widgets
class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: UserAvatar(url: user.avatarUrl),
          title: Text(user.name),
          subtitle: Text(user.email),
        ),
      );
}
```

## Platform Channels

```dart
const _channel = MethodChannel('com.example.app/native');

Future<String> getNativeValue() async {
  try {
    return await _channel.invokeMethod<String>('getValue') ?? '';
  } on PlatformException catch (e) {
    debugPrint('Platform error: ${e.message}');
    return '';
  }
}
```
