# FVM + 3-Flavor Setup

## 1. FVM Installation & Project Pin

```bash
# Install FVM if not present
dart pub global activate fvm

# In project root — pin Flutter version
fvm install 3.27.4   # or latest stable
fvm use 3.27.4 --force

# All flutter commands via fvm from here
fvm flutter create --template=app --org com.company appname
cd appname
```

## 2. Flavor Entry Points

Create three entry points in `lib/`:

```dart
// lib/main_dev.dart
import 'package:appname/app/app.dart';
import 'package:appname/di/injector.dart';
import 'package:appname/core/config/flavor_config.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlavorConfig.instance = FlavorConfig(flavor: Flavor.dev, baseUrl: 'https://api.dev.company.com');
  await configureDependencies(FlavorConfig.instance);
  runApp(const App());
}
```

Same pattern for `main_staging.dart` and `main_prod.dart`.

## 3. AppFlavor Enum (core config — NOT domain)

`FlavorConfig` is infrastructure/configuration, not a domain entity. Domain must stay pure Dart with zero environment coupling. Place in `lib/src/core/config/`:

```dart
// lib/src/core/config/flavor_config.dart
enum Flavor { dev, staging, prod }

class FlavorConfig {
  static late FlavorConfig instance;
  final Flavor flavor;
  final String baseUrl;
  const FlavorConfig({required this.flavor, required this.baseUrl});
  bool get isProduction => flavor == Flavor.prod;
}
```

## 4. Android Flavor Configuration

In `android/app/build.gradle`:
```groovy
flavorDimensions "environment"
productFlavors {
    dev {
        dimension "environment"
        applicationIdSuffix ".dev"
        resValue "string", "app_name", "AppName DEV"
    }
    staging {
        dimension "environment"
        applicationIdSuffix ".staging"
        resValue "string", "app_name", "AppName STAGING"
    }
    prod {
        dimension "environment"
        resValue "string", "app_name", "AppName"
    }
}
```

## 5. iOS Flavor Configuration

iOS flavor wiring requires xcconfig files and Xcode scheme creation. These steps cannot be automated from the terminal — they must be done manually or via the Xcode CLI.

### 5a. xcconfig files

Create one xcconfig per flavor under `ios/Flutter/`:

```
ios/Flutter/
├── DevDebug.xcconfig
├── DevRelease.xcconfig
├── StagingDebug.xcconfig
├── StagingRelease.xcconfig
├── ProdDebug.xcconfig
└── ProdRelease.xcconfig
```

Each file includes the Flutter-generated config and sets `FLUTTER_TARGET` and `BUNDLE_ID_SUFFIX`:

```xcconfig
// ios/Flutter/DevDebug.xcconfig
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_dev.dart
BUNDLE_ID_SUFFIX=.dev
APP_DISPLAY_NAME=AppName DEV
```

```xcconfig
// ios/Flutter/StagingDebug.xcconfig
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_staging.dart
BUNDLE_ID_SUFFIX=.staging
APP_DISPLAY_NAME=AppName STAGING
```

```xcconfig
// ios/Flutter/ProdRelease.xcconfig
#include "Generated.xcconfig"
FLUTTER_TARGET=lib/main_prod.dart
BUNDLE_ID_SUFFIX=
APP_DISPLAY_NAME=AppName
```

### 5b. Xcode Scheme creation (manual step — notify user)

In Xcode → Product → Scheme → Manage Schemes:
1. Duplicate the default `Runner` scheme three times
2. Rename to `dev`, `staging`, `prod`
3. For each scheme → Edit Scheme → Build Configuration:
   - `dev`: Debug → `DevDebug`, Release → `DevRelease`
   - `staging`: Debug → `StagingDebug`, Release → `StagingRelease`
   - `prod`: Debug → `ProdDebug`, Release → `ProdRelease`
4. Mark all three schemes as **Shared** (so they appear in version control)

**Claude must tell the user:** "iOS schemes require manual Xcode setup. See `references/fvm-flavors-setup.md` section 6b. I've created the xcconfig files — please complete the scheme wiring in Xcode."

### 5c. Info.plist bundle ID suffix

In `ios/Runner/Info.plist`, set the bundle display name to use the xcconfig variable:

```xml
<key>CFBundleDisplayName</key>
<string>$(APP_DISPLAY_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)$(BUNDLE_ID_SUFFIX)</string>
```

---

## 6. Run Commands

```bash
# Dev
fvm flutter run --flavor dev -t lib/main_dev.dart

# Staging
fvm flutter run --flavor staging -t lib/main_staging.dart

# Prod release build with obfuscation (SECURITY — always)
fvm flutter build appbundle --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info=build/debug-info/

fvm flutter build ipa --flavor prod -t lib/main_prod.dart \
  --obfuscate --split-debug-info=build/debug-info/
```

---

## 7. VSCode — launch.json

Create `.vscode/launch.json` in the project root:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "dev",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_dev.dart",
      "args": ["--flavor", "dev"],
      "flutterMode": "debug"
    },
    {
      "name": "staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_staging.dart",
      "args": ["--flavor", "staging"],
      "flutterMode": "debug"
    },
    {
      "name": "prod (release)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"],
      "flutterMode": "release"
    },
    {
      "name": "prod (profile)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_prod.dart",
      "args": ["--flavor", "prod"],
      "flutterMode": "profile"
    }
  ]
}
```

Commit `.vscode/launch.json` — it is project configuration, not personal IDE settings. Add `.vscode/settings.json` to `.gitignore` if it contains personal overrides.

---

## 8. Environment Template (.env.example)

Create `.env.example` in the project root with provider-agnostic environment variable placeholders:

```bash
# API Configuration
API_BASE_URL=https://api.example.com
API_TIMEOUT_MS=30000

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true

# Push Notifications (provider-agnostic)
PUSH_NOTIFICATIONS_ENABLED=false
PUSH_SERVER_KEY=your_push_server_key_here

# Authentication
AUTH_TOKEN_EXPIRY_SECONDS=3600
REFRESH_TOKEN_ENABLED=true

# Rate Limiting
RATE_LIMIT_REQUESTS_PER_MINUTE=60

# Logging
LOG_LEVEL=debug
LOG_ENABLE_NETWORK_INSPECTOR=false

# Build Metadata
APP_VERSION=1.0.0
BUILD_NUMBER=1
```

**Rule:** Commit `.env.example` to version control. Never commit `.env` or `.env.*` — each developer copies `.env.example` to `.env` locally.

---

## 9. Android Studio — Run Configurations

Android Studio run configurations are stored in `.idea/runConfigurations/`. Create one XML file per flavor:

```xml
<!-- .idea/runConfigurations/dev.xml -->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="dev" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor dev" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_dev.dart" />
    <option name="flutterSdkPath" value="$PROJECT_DIR$/.fvm/flutter_sdk" />
    <method v="2" />
  </configuration>
</component>
```

```xml
<!-- .idea/runConfigurations/staging.xml -->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="staging" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor staging" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_staging.dart" />
    <option name="flutterSdkPath" value="$PROJECT_DIR$/.fvm/flutter_sdk" />
    <method v="2" />
  </configuration>
</component>
```

```xml
<!-- .idea/runConfigurations/prod.xml -->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="prod (release)" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor prod --release" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main_prod.dart" />
    <option name="flutterSdkPath" value="$PROJECT_DIR$/.fvm/flutter_sdk" />
    <method v="2" />
  </configuration>
</component>
```

Commit `.idea/runConfigurations/` — shared run configs belong in version control. Add `.idea/*.xml` (workspace, shelf) to `.gitignore` but keep `runConfigurations/`.

`.gitignore` additions for `.idea/`:

```gitignore
# Android Studio — keep run configs, ignore workspace state
.idea/*.xml
!.idea/runConfigurations/
```

---

## 9. .gitignore additions

```gitignore
# Secrets — never commit
*.keystore
*-key.json
.env
.env.*
google-services.json
GoogleService-Info.plist
build/debug-info/
build/symbols/

# Android Studio workspace state (keep runConfigurations)
.idea/*.xml
!.idea/runConfigurations/

# AI planning docs — LLM-targeted, not for repo history
.planning/
docs/superpowers/
sprints/
design-system/
BACKLOG.md
```
