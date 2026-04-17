# Android Testing

> This file extends [common/testing.md](../common/testing.md) and [kotlin/testing.md](../kotlin/testing.md) with Android Compose and ViewModel testing.

## Test Framework

```kotlin
// Unit tests
testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test")
testImplementation("app.cash.turbine:turbine")
testImplementation("io.mockk:mockk")

// UI tests
androidTestImplementation("androidx.compose.ui:ui-test-junit4")
debugImplementation("androidx.compose.ui:ui-test-manifest")
```

## ViewModel Testing

```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class UserViewModelTest {

    private val testDispatcher = UnconfinedTestDispatcher()
    private val getUserUseCase = mockk<GetUserUseCase>()
    private lateinit var viewModel: UserViewModel

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        viewModel = UserViewModel(getUserUseCase)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `loadUser emits user on success`() = runTest {
        coEvery { getUserUseCase("1") } returns Result.success(fakeUser)

        viewModel.uiState.test {
            viewModel.loadUser("1")
            assertThat(awaitItem()).isEqualTo(UserUiState())
            assertThat(awaitItem().isLoading).isTrue()
            assertThat(awaitItem().user).isEqualTo(fakeUser)
            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

## Compose UI Testing

```kotlin
@get:Rule
val composeTestRule = createComposeRule()

@Test
fun userCard_displaysName() {
    composeTestRule.setContent {
        UserCard(user = fakeUser)
    }

    composeTestRule.onNodeWithText(fakeUser.name).assertIsDisplayed()
    composeTestRule.onNodeWithText(fakeUser.email).assertIsDisplayed()
}
```

## Test Organization

```
src/
├── test/kotlin/           # Unit: ViewModels, UseCases, Repositories
└── androidTest/kotlin/    # Instrumented: Compose UI, Room, integration
```
