# Clean Architecture + SOLID for Flutter

## Layer Rules (hard constraints)

| Layer | Can import | Cannot import |
|-------|-----------|---------------|
| `domain/` | Nothing (pure Dart only) | `data/`, `presentation/`, Flutter SDK |
| `data/` | `domain/` | `presentation/` |
| `presentation/` | `domain/` (abstractions only) | `data/` directly |
| `di/` | Everything | — (this is the only place data meets domain) |

Violation of these rules = architecture failure. Analyzer linting should catch cross-layer imports.

---

## ISP — Interface Segregation (one abstract per capability)

**Wrong — fat interface:**
```dart
abstract class DataSource {
  Future<User> getUser(String id);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearCache();
}
```

**Correct — segregated:**
```dart
// domain/datasources/user_datasource.dart
abstract class UserDataSource {
  Future<User> getUser(String id);
}

// domain/datasources/token_datasource.dart
abstract class TokenDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
}

// domain/datasources/cache_datasource.dart
abstract class CacheDataSource {
  Future<void> clear();
}
```

Rule: if a class implementing the interface would leave any method `throw UnimplementedError`, the interface is too fat — split it.

---

## DIP — Dependency Inversion (use cases depend on abstractions)

**Wrong:**
```dart
class GetUserUseCase {
  final FirebaseUserAdapter _adapter; // ← concrete, in data layer
  GetUserUseCase(this._adapter);
}
```

**Also Wrong (Repository Pattern - over-engineering for simple cases):**
```dart
// Unnecessary repository layer for simple CRUD
class UserRepository {
  final UserDataSource _dataSource;
  Future<User> getUser(String id) => _dataSource.getUser(id); // Just passes through!
}

class GetUserUseCase {
  final UserRepository _repository; // ← unnecessary abstraction
  Future<User> call(String id) => _repository.getUser(id); // Just passes through!
}
```

**Correct (Use Case → Datasource):**
```dart
// domain/datasources/user_datasource.dart
abstract class UserDataSource {
  Future<User> getUser(String id);
}

// data/usecases/get_user_usecase.dart
class GetUserUseCase {
  final UserDataSource _dataSource; // ← datasource interface
  const GetUserUseCase(this._dataSource);
  
  // Use case can contain business logic
  Future<User> call(String id) async {
    if (id.isEmpty) throw ArgumentError('ID cannot be empty');
    return await _dataSource.getUser(id);
  }
}
```

Wiring only in `di/`:
```dart
// di/injector.dart
GetIt.instance.registerLazySingleton<UserDataSource>(
  () => FirebaseUserAdapter(), // concrete implementation
);
GetIt.instance.registerFactory(
  () => GetUserUseCase(GetIt.instance<UserDataSource>()),
);
```

**When to use Repository Pattern:**
- ONLY when aggregating data from MULTIPLE sources (local + remote + cache)
- ONLY when you need to swap data sources at runtime
- NOT for simple CRUD operations (Use Case → Datasource is enough)

**Example where Repository makes sense:**
```dart
class MovieRepository {
  final LocalDataSource _local;
  final RemoteDataSource _remote;
  
  Future<Movie> getMovie(int id) async {
    try {
      return await _local.getMovie(id);
    } catch (_) {
      final movie = await _remote.getMovie(id);
      await _local.saveMovie(movie);
      return movie;
    }
  }
}
```

---

## SRP — One reason to change per class

- Use cases do ONE thing: `GetUserUseCase`, `UpdateProfileUseCase` (not `UserUseCase` with 10 methods)
- BLoC handles ONE screen's state: `ProfileBloc`, not `AppBloc`
- Widgets either compose OR display — never both

---

## OCP — Open for extension, closed for modification

Use sealed classes for errors so new error types extend, never modify existing:
```dart
// domain/errors/auth_errors.dart
sealed class AuthError {}
class InvalidCredentialsError extends AuthError {}
class SessionExpiredError extends AuthError {}
class NetworkAuthError extends AuthError {}
```

Switch exhaustiveness in Dart ensures all cases handled at compile time.

---

## Error Hierarchy Pattern (from vin scanner)

```dart
// domain/errors/base_error.dart
sealed class AppError {
  const AppError();
}

// Each feature has its own sealed error
sealed class ScanError extends AppError {}
class CameraPermissionDenied extends ScanError {}
class DetectionFailed extends ScanError { final String reason; const DetectionFailed(this.reason); }
```

---

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Abstract datasource | `<Name>DataSource` | `AuthDataSource` |
| Concrete adapter | `<Impl><Name>Adapter` | `FirebaseAuthAdapter` |
| Use case | `<Verb><Noun>UseCase` | `ValidateTokenUseCase` |
| BLoC | `<Feature>Bloc` | `LoginBloc` |
| Cubit | `<Feature>Cubit` | `ThemeCubit` |
| Event | `<Feature><Action>Event` | `LoginSubmittedEvent` |
| State | `<Feature>State` (sealed) | `LoginState` |
| Screen | `<Feature>Screen` | `LoginScreen` |
| Widget | `<Name>Widget` | `PasswordInputWidget` |
| Model (DTO) | `<Name>Model` | `UserModel` |
| Entity | plain name | `User`, `AuthToken` |
