# Flutter Security

> This file extends [common/security.md](../common/security.md) with Flutter and Dart-specific content.

## Secrets Management

- Never hardcode API keys, secrets, or tokens in Dart source files
- Use `--dart-define` or `--dart-define-from-file` to inject at build time
- Store sensitive user data with `flutter_secure_storage` (Keychain/Keystore backed)

```dart
const secureStorage = FlutterSecureStorage();

// Write
await secureStorage.write(key: 'auth_token', value: token);

// Read
final token = await secureStorage.read(key: 'auth_token');

// Delete on logout
await secureStorage.deleteAll();
```

## Network Security

- Use HTTPS for all API calls; pin certificates for high-security apps
- Validate SSL certificates — never set `badCertificateCallback` to return `true`
- Use `Dio` with interceptors for token refresh; never log full request/response bodies in production

```dart
// Certificate pinning with dio_certificate_pinner
final dio = Dio()
  ..interceptors.add(CertificatePinnerInterceptor(
    allowedSHAFingerprints: ['sha256/YOUR_PIN_HERE'],
  ));
```

## Input Validation

- Validate and sanitize all user input in `TextFormField` validators before submitting
- Use typed models — never pass raw `Map<String, dynamic>` across layers
- Sanitize display of user-generated content to prevent injection in WebView

## Data Protection

- Use `flutter_secure_storage` for tokens and credentials
- Use encrypted databases (`sqflite_sqlcipher`, Drift with encryption) for sensitive local data
- Clear sensitive data from memory when navigating away from auth screens
- Use `AutofillHints` appropriately; disable for sensitive fields when needed

## WebView Security

- Enable `javascriptMode: JavascriptMode.disabled` unless JS is required
- Restrict navigation with `navigationDelegate`
- Never load untrusted URLs from deep links directly into a WebView without validation

## Code Obfuscation

Enable for release builds:

```
flutter build apk --obfuscate --split-debug-info=symbols/
flutter build ios --obfuscate --split-debug-info=symbols/
```

## ProGuard / R8 (Android)

Keep Flutter and plugin rules in `android/app/proguard-rules.pro`:

```
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
```
