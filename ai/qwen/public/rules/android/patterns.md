# Android Patterns

> This file extends [common/patterns.md](../common/patterns.md) and [kotlin/patterns.md](../kotlin/patterns.md) with Android-specific Compose and architecture content.

## ViewModel + UiState

```kotlin
data class UserUiState(
    val isLoading: Boolean = false,
    val user: User? = null,
    val error: String? = null,
)

@HiltViewModel
class UserViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow(UserUiState())
    val uiState: StateFlow<UserUiState> = _uiState.asStateFlow()

    fun loadUser(id: String) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getUserUseCase(id)
                .onSuccess { user -> _uiState.update { it.copy(isLoading = false, user = user) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }
}
```

## Composable Screen

```kotlin
@Composable
fun UserScreen(
    viewModel: UserViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit,
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    UserScreenContent(
        uiState = uiState,
        onRetry = { viewModel.loadUser(id) },
        onNavigateBack = onNavigateBack,
    )
}

@Composable
private fun UserScreenContent(
    uiState: UserUiState,
    onRetry: () -> Unit,
    onNavigateBack: () -> Unit,
) {
    when {
        uiState.isLoading -> CircularProgressIndicator()
        uiState.error != null -> ErrorView(message = uiState.error, onRetry = onRetry)
        uiState.user != null -> UserDetail(user = uiState.user)
    }
}
```

## Navigation with Compose

```kotlin
@Composable
fun AppNavHost(navController: NavHostController) {
    NavHost(navController, startDestination = Routes.HOME) {
        composable(Routes.HOME) {
            HomeScreen(onUserClick = { id -> navController.navigate(Routes.user(id)) })
        }
        composable(
            route = Routes.USER,
            arguments = listOf(navArgument("id") { type = NavType.StringType }),
        ) {
            UserScreen(onNavigateBack = navController::popBackStack)
        }
    }
}

object Routes {
    const val HOME = "home"
    const val USER = "user/{id}"
    fun user(id: String) = "user/$id"
}
```

## Hilt Dependency Injection

```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideRetrofit(): Retrofit = Retrofit.Builder()
        .baseUrl(BuildConfig.API_BASE_URL)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    @Provides
    @Singleton
    fun provideUserService(retrofit: Retrofit): UserService =
        retrofit.create(UserService::class.java)
}
```
