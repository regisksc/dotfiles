# Android Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) and [kotlin/coding-style.md](../kotlin/coding-style.md) with Android-specific content.

## Project Structure

Follow Clean Architecture with feature modules:

```
app/
├── src/main/
│   ├── AndroidManifest.xml
│   └── kotlin/com/example/app/
│       ├── core/          # DI, network, database, utils
│       ├── data/          # Repositories, data sources, DTOs
│       ├── domain/        # Use cases, domain models, interfaces
│       └── ui/            # Composables, ViewModels, navigation
```

## Compose UI

- Use `@Composable` functions starting with uppercase (`UserCard`, not `userCard`)
- Extract reusable composables into separate files under the `ui/components/` package
- Use `Modifier` as first parameter after required params; provide default `Modifier = Modifier`
- Mark preview composables with `@Preview(showBackground = true)`
- Use `stringResource`, `dimensionResource`, `colorResource` — never hardcode UI values

## Naming

- ViewModels: `<Feature>ViewModel`
- UI State: `<Feature>UiState` (sealed class or data class)
- Composable screens: `<Feature>Screen`
- Navigation routes: constants in a `Routes` object

## Logging

- Use `Log.d`, `Log.e`, `Log.w` with a `TAG` constant — never `println`
- Define `private const val TAG = "ClassName"` at file level
- Strip logs in release via ProGuard or use Timber in debug builds only
