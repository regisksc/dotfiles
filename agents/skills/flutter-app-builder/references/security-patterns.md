# Security Patterns for Flutter

Reference for the cross-cutting security concern enforced throughout flutter-app-builder phases.

---

## OWASP Mobile Top 10 — Flutter Checklist

Run this as a gate in Phase 5 (Swarm Review) before `gsd:ship`.

| # | Risk | Flutter check |
|---|------|---------------|
| M1 | Improper Credential Usage | No hardcoded tokens, passwords, or API keys in source |
| M2 | Inadequate Supply Chain Security | `flutter pub outdated`; pin versions in `pubspec.lock` |
| M3 | Insecure Authentication/Authorization | JWT validated server-side; no role logic in client |
| M4 | Insufficient Input/Output Validation | All `TextFormField` have validators; no raw SQL/HTML |
| M5 | Insecure Communication | HTTPS only; no `badCertificateCallback: (_,_,_) => true` |
| M6 | Inadequate Privacy Controls | No PII in logs, analytics, or crash reports |
| M7 | Insufficient Binary Protections | `--obfuscate --split-debug-info` in release builds |
| M8 | Security Misconfiguration | ATS enforced (iOS); `cleartext` blocked (Android) |
| M9 | Insecure Data Storage | Credentials in `FlutterSecureStorage`; no `SharedPreferences` for tokens |
| M10 | Insufficient Cryptography | No custom crypto; use platform Keychain/Keystore via `flutter_secure_storage` |

---

## Phase 2 — Scaffold Requirements

Wire security infrastructure before any feature code:

```yaml
# pubspec.yaml — required security dependencies
dependencies:
  flutter_secure_storage: ^9.0.0   # Keychain/Keystore-backed storage

dev_dependencies:
  # no test-only security deps needed — use integration tests for storage behavior
```

```bash
# android/app/build.gradle.kts — release build flags
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    }
}
```

```bash
# iOS + Android release build commands — always use these
flutter build apk --release --obfuscate --split-debug-info=build/symbols/
flutter build ios --release --obfuscate --split-debug-info=build/symbols/
```

Add `build/symbols/` to `.gitignore`.

---

## Phase 3 — Architecture Requirements

### Secure storage abstraction

```dart
// domain/datasources/secure_storage_datasource.dart
abstract class SecureStorageDatasource {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}
```

```dart
// data/datasources/secure_storage_datasource_impl.dart
class SecureStorageDatasourceImpl implements SecureStorageDatasource {
  const SecureStorageDatasourceImpl(this._storage);
  final FlutterSecureStorage _storage;

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);

  @override
  Future<void> deleteAll() => _storage.deleteAll();
}
```

**Rule:** Sensitive data (tokens, credentials) flows through `SecureStorageDatasource` only — never `SharedPreferences` or `Hive` unencrypted.

### No secrets in source

Use `--dart-define` for build-time injection:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
flutter build apk --dart-define=API_BASE_URL=https://api.example.com
```

```dart
// Access in code
const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
```

Prefer `.env`-style files with `--dart-define-from-file=.env.json` (Flutter 3.7+).

---

## Phase 4 — TDD Security Tests (mandatory for auth features)

See `tdd-patterns.md` → **Security-Relevant Test Cases** section.

Additional mandatory test: verify tokens are NOT stored in `SharedPreferences`:

```dart
test('login does not write token to SharedPreferences', () async {
  // Use a real FlutterSecureStorage mock and a SharedPreferences spy
  // Assert: SharedPreferences.setString was never called with token key
});
```

---

## Phase 5 — Swarm Review Security Agent Prompt

```
You are a mobile security reviewer. Audit the Flutter codebase in [path] against
OWASP Mobile Top 10.

Focus:
1. Insecure data storage — search for SharedPreferences writes of tokens/passwords
2. Cleartext traffic — check AndroidManifest.xml and Info.plist for cleartext exceptions
3. Hardcoded secrets — search for API keys, tokens, passwords in Dart source
4. Missing obfuscation — verify build scripts include --obfuscate flag
5. PII in logs — search debugPrint calls for email, token, password patterns
6. Custom TLS bypass — search for badCertificateCallback returning true

Return: structured list of CRITICAL / HIGH / MEDIUM findings with file:line references.
```

---

## Android — Network Security Config

`android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
```

`AndroidManifest.xml`:
```xml
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

## iOS — ATS

`ios/Runner/Info.plist` — do NOT add `NSAllowsArbitraryLoads`. Default ATS enforcement is sufficient when all traffic uses HTTPS.

---

## ProGuard Rules

`android/app/proguard-rules.pro`:

```
# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep data classes used in JSON serialization
-keep class com.example.app.data.model.** { *; }
```

---

## Quick Reference: Sensitive Keys

Standard key names for `FlutterSecureStorage`:

```dart
abstract class StorageKeys {
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const userId = 'user_id';
}
```

Never use these as `SharedPreferences` keys.
