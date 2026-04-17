# Android Security

> This file extends [common/security.md](../common/security.md) and [kotlin/security.md](../kotlin/security.md) with Android Compose-specific content.

## Secrets Management

- Never put API keys in `AndroidManifest.xml` or `build.gradle`
- Inject secrets via `BuildConfig` fields using `buildConfigField` in `build.gradle.kts`
- Store credentials in `EncryptedSharedPreferences` or the Android Keystore

```kotlin
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val prefs = EncryptedSharedPreferences.create(
    context,
    "secure_prefs",
    masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM,
)
```

## Network Security

Add `res/xml/network_security_config.xml`:

```xml
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set>
            <pin digest="SHA-256">YOUR_BASE64_PIN</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

Reference in `AndroidManifest.xml`:

```xml
<application android:networkSecurityConfig="@xml/network_security_config" ...>
```

## ProGuard / R8

```
# Keep data classes used in JSON serialization
-keep class com.example.app.data.model.** { *; }

# Keep Hilt generated code
-keep class dagger.hilt.** { *; }
-keep @dagger.hilt.android.HiltAndroidApp class * { *; }
```

## Deep Link Validation

```kotlin
// Always validate deep link parameters before use
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val userId = intent?.data?.getQueryParameter("user_id")
        ?.takeIf { it.matches(Regex("[a-zA-Z0-9-]+")) }
        ?: return finish()
}
```
