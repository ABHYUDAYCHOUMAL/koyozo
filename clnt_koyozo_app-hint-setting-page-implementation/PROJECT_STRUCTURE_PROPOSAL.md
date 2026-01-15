# Koyozo Gaming Controller iOS App - Project Structure Proposal

## Overview
This document proposes a scalable, maintainable project structure for the Koyozo gaming controller iOS application, designed to accommodate short-term features and long-term extensibility.

---

## Architecture Pattern: **MVVM + Clean Architecture**

### Rationale
- **MVVM (Model-View-ViewModel)**: Natural fit for SwiftUI's reactive data flow
- **Clean Architecture**: Separation of concerns for scalability
- **Repository Pattern**: Abstraction layer for data sources (API, local cache, etc.)
- **Dependency Injection**: Testability and modularity

---

## Proposed Directory Structure

```
clnt_koyozo_app/
│
├── koyozoclub/                          # Main App Target
│   ├── App/                             # Application Entry & Configuration
│   │   ├── koyozoclubApp.swift          # @main entry point
│   │   ├── AppDelegate.swift            # App lifecycle (if needed)
│   │   └── AppDependencies.swift        # Dependency injection container
│   │
│   ├── Core/                            # Shared Foundation Code
│   │   ├── Extensions/                  # Swift extensions
│   │   │   ├── View+Extensions.swift
│   │   │   ├── String+Extensions.swift
│   │   │   ├── Date+Extensions.swift
│   │   │   └── Color+Extensions.swift
│   │   │
│   │   ├── Utilities/                   # Helper utilities
│   │   │   ├── Logger.swift             # Logging utility
│   │   │   ├── Constants.swift          # App-wide constants
│   │   │   ├── AppErrors.swift          # Custom error types
│   │   │   └── Validators.swift         # Input validation helpers
│   │   │
│   │   ├── Theme/                       # Design System
│   │   │   ├── AppTheme.swift           # Color scheme, typography
│   │   │   ├── Spacing.swift            # Design tokens
│   │   │   └── Components/              # Reusable UI components
│   │   │       ├── PrimaryButton.swift
│   │   │       ├── TextField.swift
│   │   │       ├── CardView.swift
│   │   │       └── LoadingView.swift
│   │   │
│   │   ├── Navigation/                  # Navigation handling
│   │   │   ├── AppCoordinator.swift     # Root coordinator
│   │   │   ├── NavigationPath.swift     # Navigation state
│   │   │   └── Route.swift              # Route definitions
│   │   │
│   │   └── Protocols/                   # Shared protocols
│   │       ├── ViewModelProtocol.swift
│   │       └── RepositoryProtocol.swift
│   │
│   ├── Features/                        # Feature Modules (Domain-Based)
│   │   │
│   │   ├── Authentication/              # Phase 1: Foundation & Authentication
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   ├── SplashView.swift
│   │   │   │   │   ├── LoginView.swift
│   │   │   │   │   ├── SignupView.swift
│   │   │   │   │   └── ForgotPasswordView.swift
│   │   │   │   ├── ViewModels/
│   │   │   │   │   ├── LoginViewModel.swift
│   │   │   │   │   ├── SignupViewModel.swift
│   │   │   │   │   └── SplashViewModel.swift
│   │   │   │   └── Components/
│   │   │   │       ├── GoogleSignInButton.swift
│   │   │   │       └── AuthTextField.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   ├── User.swift
│   │   │   │   │   └── AuthToken.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── LoginUseCase.swift
│   │   │   │       ├── SignupUseCase.swift
│   │   │   │       ├── GoogleSignInUseCase.swift
│   │   │   │       └── LogoutUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       ├── Repositories/
│   │   │       │   └── AuthRepository.swift
│   │   │       ├── DataSources/
│   │   │       │   ├── AuthRemoteDataSource.swift    # API calls
│   │   │       │   ├── AuthLocalDataSource.swift     # Keychain/UserDefaults
│   │   │       │   └── GoogleAuthDataSource.swift    # Google Sign-In SDK
│   │   │       ├── DTOs/                             # Data Transfer Objects
│   │   │       │   ├── LoginRequestDTO.swift
│   │   │       │   ├── SignupRequestDTO.swift
│   │   │       │   └── AuthResponseDTO.swift
│   │   │       └── Mappers/
│   │   │           └── AuthMapper.swift              # DTO <-> Domain conversion
│   │   │
│   │   ├── GameLibrary/                 # Phase 2: Game Library Dashboard
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   ├── GameLibraryView.swift        # Dashboard
│   │   │   │   │   ├── GameGridView.swift
│   │   │   │   │   ├── GameCardView.swift
│   │   │   │   │   └── RecentGamesView.swift
│   │   │   │   ├── ViewModels/
│   │   │   │   │   └── GameLibraryViewModel.swift
│   │   │   │   └── Components/
│   │   │   │       ├── GameGridItem.swift
│   │   │   │       └── DashboardHintView.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   ├── Game.swift
│   │   │   │   │   ├── GameCategory.swift
│   │   │   │   │   └── GameVendor.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── FetchGamesUseCase.swift
│   │   │   │       ├── FetchRecentGamesUseCase.swift
│   │   │   │       └── FetchGameCategoriesUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       ├── Repositories/
│   │   │       │   └── GameRepository.swift
│   │   │       ├── DataSources/
│   │   │       │   ├── GameRemoteDataSource.swift
│   │   │       │   └── GameLocalDataSource.swift     # CoreData/SQLite cache
│   │   │       ├── DTOs/
│   │   │       │   ├── GameDTO.swift
│   │   │       │   └── GameListResponseDTO.swift
│   │   │       └── Mappers/
│   │   │           └── GameMapper.swift
│   │   │
│   │   ├── GameSearch/                  # Phase 3: Search & Favorites
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   ├── SearchView.swift
│   │   │   │   │   ├── SearchResultsView.swift
│   │   │   │   │   ├── FavoritesView.swift
│   │   │   │   │   └── SearchBarView.swift
│   │   │   │   ├── ViewModels/
│   │   │   │   │   ├── SearchViewModel.swift
│   │   │   │   │   └── FavoritesViewModel.swift
│   │   │   │   └── Components/
│   │   │   │       └── FavoriteButton.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   └── Favorite.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── SearchGamesUseCase.swift
│   │   │   │       ├── AddFavoriteUseCase.swift
│   │   │   │       ├── RemoveFavoriteUseCase.swift
│   │   │   │       └── FetchFavoritesUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       ├── Repositories/
│   │   │       │   └── FavoriteRepository.swift
│   │   │       └── DataSources/
│   │   │           ├── FavoriteRemoteDataSource.swift
│   │   │           └── FavoriteLocalDataSource.swift
│   │   │
│   │   ├── GameLauncher/                # Phase 3: Game Launcher
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   └── LaunchGameView.swift
│   │   │   │   └── ViewModels/
│   │   │   │       └── GameLauncherViewModel.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   └── UseCases/
│   │   │   │       └── LaunchGameUseCase.swift       # URL scheme handling
│   │   │   │
│   │   │   └── Data/
│   │   │       └── Services/
│   │   │           └── GameLauncherService.swift     # URL scheme execution
│   │   │
│   │   ├── GameDetail/                  # Phase 4: Detail Screen
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   ├── GameDetailView.swift
│   │   │   │   │   ├── GameInfoView.swift
│   │   │   │   │   ├── GameScreenshotsView.swift
│   │   │   │   │   ├── OnboardingView.swift
│   │   │   │   │   └── ControllerSetupView.swift
│   │   │   │   ├── ViewModels/
│   │   │   │   │   └── GameDetailViewModel.swift
│   │   │   │   └── Components/
│   │   │   │       ├── GameRatingView.swift
│   │   │   │       └── PlayButton.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   ├── GameDetail.swift
│   │   │   │   │   └── GameScreenshot.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── FetchGameDetailUseCase.swift
│   │   │   │       └── MarkGamePlayedUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       └── Repositories/
│   │   │           └── GameDetailRepository.swift
│   │   │
│   │   ├── Controller/                  # Phase 4: Controller Support
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   ├── ControllerConnectionView.swift
│   │   │   │   │   ├── ControllerCalibrationView.swift
│   │   │   │   │   └── ControllerRebootView.swift
│   │   │   │   └── ViewModels/
│   │   │   │       └── ControllerViewModel.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   ├── GameController.swift
│   │   │   │   │   └── ControllerConfig.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── DetectControllerUseCase.swift
│   │   │   │       ├── CalibrateControllerUseCase.swift
│   │   │   │       └── RebootControllerUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       └── Services/
│   │   │           └── ControllerService.swift       # GameController framework
│   │   │
│   │   ├── UserProfile/                 # Future: User Gaming Profile
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   └── ProfileView.swift
│   │   │   │   └── ViewModels/
│   │   │   │       └── ProfileViewModel.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   ├── UserProfile.swift
│   │   │   │   │   └── GamingStats.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── FetchProfileUseCase.swift
│   │   │   │       └── UpdateProfileUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       └── Repositories/
│   │   │           └── ProfileRepository.swift
│   │   │
│   │   ├── Preferences/                 # Future: User Preferences
│   │   │   ├── Presentation/
│   │   │   │   ├── Views/
│   │   │   │   │   └── SettingsView.swift
│   │   │   │   └── ViewModels/
│   │   │   │       └── SettingsViewModel.swift
│   │   │   │
│   │   │   ├── Domain/
│   │   │   │   ├── Models/
│   │   │   │   │   └── UserPreferences.swift
│   │   │   │   └── UseCases/
│   │   │   │       ├── SavePreferencesUseCase.swift
│   │   │   │       └── FetchPreferencesUseCase.swift
│   │   │   │
│   │   │   └── Data/
│   │   │       └── Repositories/
│   │   │           └── PreferencesRepository.swift
│   │   │
│   │   ├── Competitions/                # Future: Gaming Competitions
│   │   │   ├── Presentation/
│   │   │   ├── Domain/
│   │   │   └── Data/
│   │   │
│   │   └── Analytics/                   # Future: User Data Capture
│   │       ├── Presentation/
│   │       ├── Domain/
│   │       │   └── Models/
│   │       │       └── GameplaySession.swift
│   │       └── Data/
│   │           └── Services/
│   │               └── AnalyticsService.swift
│   │
│   ├── Data/                            # Shared Data Layer
│   │   ├── Network/                     # Networking Infrastructure
│   │   │   ├── APIClient.swift          # Base HTTP client (URLSession wrapper)
│   │   │   ├── APIEndpoint.swift        # Endpoint definitions
│   │   │   ├── RequestBuilder.swift     # Request construction
│   │   │   ├── ResponseHandler.swift    # Response parsing
│   │   │   └── NetworkError.swift       # Network-specific errors
│   │   │
│   │   ├── Storage/                     # Local Storage Infrastructure
│   │   │   ├── KeychainManager.swift    # Secure storage (tokens)
│   │   │   ├── UserDefaultsManager.swift # Simple preferences
│   │   │   ├── CoreDataStack.swift      # CoreData setup (if needed)
│   │   │   └── DatabaseManager.swift    # SQLite wrapper (alternative)
│   │   │
│   │   └── Cache/                       # Caching Strategy
│   │       ├── CacheManager.swift       # Cache interface
│   │       ├── MemoryCache.swift        # In-memory cache
│   │       └── DiskCache.swift          # Persistent cache
│   │
│   ├── Resources/                       # App Resources
│   │   ├── Assets.xcassets/            # Images, icons, colors
│   │   ├── Localizable.xcstrings       # Localization strings
│   │   ├── Fonts/                      # Custom fonts (if any)
│   │   └── Config/                     # Configuration files
│   │       ├── Config.plist            # App config (API URLs, etc.)
│   │       └── Info.plist              # App metadata
│   │
│   └── SupportingFiles/                # Supporting Files
│       └── Info.plist                  # App info (if not auto-generated)
│
├── Tests/                               # Test Targets
│   ├── UnitTests/                       # Unit Tests
│   │   ├── Core/
│   │   │   └── Utilities/
│   │   │       └── ValidatorsTests.swift
│   │   │
│   │   ├── Features/
│   │   │   ├── Authentication/
│   │   │   │   ├── Domain/
│   │   │   │   │   └── UseCases/
│   │   │   │   │       └── LoginUseCaseTests.swift
│   │   │   │   └── Data/
│   │   │   │       └── Repositories/
│   │   │   │           └── AuthRepositoryTests.swift
│   │   │   │
│   │   │   ├── GameLibrary/
│   │   │   │   └── ...
│   │   │   │
│   │   │   └── [Other Features]/
│   │   │
│   │   └── Data/
│   │       ├── Network/
│   │       │   └── APIClientTests.swift
│   │       └── Storage/
│   │           └── KeychainManagerTests.swift
│   │
│   ├── IntegrationTests/                # Integration Tests
│   │   ├── AuthenticationFlowTests.swift
│   │   ├── GameLibraryFlowTests.swift
│   │   └── GameLaunchFlowTests.swift
│   │
│   └── UITests/                         # UI Tests
│       ├── AuthenticationUITests.swift
│       ├── GameLibraryUITests.swift
│       └── GameDetailUITests.swift
│
├── Scripts/                             # Build & Deployment Scripts
│   ├── build.sh                        # Build script
│   ├── test.sh                         # Test runner script
│   ├── lint.sh                         # Linting script (SwiftLint)
│   └── archive.sh                      # Archive script
│
├── Documentation/                       # Project Documentation
│   ├── API.md                          # API documentation
│   ├── ARCHITECTURE.md                 # Architecture details
│   └── CONTRIBUTING.md                 # Contribution guidelines
│
├── Config/                              # Build Configuration
│   ├── Debug.xcconfig                  # Debug build settings
│   ├── Release.xcconfig                # Release build settings
│   ├── Staging.xcconfig                # Staging environment
│   └── Production.xcconfig             # Production environment
│
├── .swiftformat                        # Swift formatting rules
├── .swiftlint.yml                      # SwiftLint configuration
├── .gitignore
├── README.md
└── koyozoclub.xcodeproj/               # Xcode project file
```

---

## Key Design Decisions

### 1. **Feature-Based Modular Structure**
- Each feature (Authentication, GameLibrary, etc.) is self-contained
- Features can be developed, tested, and maintained independently
- Easy to scale by adding new features without affecting existing ones

### 2. **Clean Architecture Layers**
Each feature follows **Presentation → Domain → Data** structure:
- **Presentation**: Views, ViewModels, UI Components
- **Domain**: Business logic, Use Cases, Domain Models (pure Swift, no dependencies)
- **Data**: Repositories, Data Sources, DTOs, Mappers

### 3. **Dependency Injection**
- `AppDependencies.swift` acts as DI container
- Use protocol-oriented programming for testability
- Dependencies injected via initializers

### 4. **Networking Architecture**
- Centralized `APIClient` for all network calls
- `APIEndpoint` protocol for type-safe endpoints
- Repository pattern abstracts data sources (API vs. local cache)

### 5. **Local Caching Strategy**
- Multi-layer caching: Memory → Disk → Network
- CoreData or SQLite for persistent game catalog cache
- Keychain for secure token storage
- UserDefaults for simple preferences

---

## Build & Deployment Configuration

### Build Configurations
1. **Debug**: Development with logging, debugging symbols
2. **Staging**: Pre-production testing environment
3. **Release**: Production build

### Environment Variables (via .xcconfig)
```swift
// Config.plist structure
API_BASE_URL = "https://api.koyozo.com"
API_KEY = "${API_KEY}"  // From environment
GOOGLE_SIGN_IN_CLIENT_ID = "${GOOGLE_CLIENT_ID}"
ENABLE_ANALYTICS = true/false
```

### Code Signing & Provisioning
- Automatic code signing for development
- Manual provisioning for production releases
- Separate App IDs for development/staging/production if needed

---

## Testing Strategy

### Unit Tests (80%+ coverage target)
- Test ViewModels independently
- Test Use Cases with mocked repositories
- Test Data layer with mocked network responses

### Integration Tests
- Test complete flows (e.g., login → fetch games → launch game)
- Use test API endpoints or mock servers

### UI Tests
- Critical user flows
- Accessibility testing
- Controller interaction testing

---

## Dependencies & Third-Party Libraries

### Recommended Dependencies (via Swift Package Manager)
1. **Networking**: 
   - `Alamofire` (optional, or use URLSession)
   - `Combine` (built-in for reactive programming)

2. **Image Loading**:
   - `Kingfisher` or `SDWebImageSwiftUI` (for game thumbnails)

3. **Authentication**:
   - `GoogleSignIn` (Google Sign-In SDK)

4. **Local Storage**:
   - CoreData (built-in) OR `Realm` (alternative)

5. **Analytics** (future):
   - `Firebase Analytics` or custom solution

6. **Code Quality**:
   - `SwiftLint` (via CocoaPods or SPM)

---

## Future Scalability Considerations

### 1. **Modular Framework Targets** (Future)
As the app grows, consider splitting into:
- `KoyozoCore` (shared utilities)
- `KoyozoAuth` (authentication module)
- `KoyozoGames` (game library module)
- Each as a separate framework/Swift Package

### 2. **Feature Flags**
Implement feature flags for:
- Gradual feature rollouts
- A/B testing
- Remote configuration

### 3. **Offline Support**
- Robust local caching for game catalog
- Offline mode with sync when online
- Background sync for user data

### 4. **Cloud Games Integration**
- Separate module for cloud gaming protocols
- Streaming support infrastructure
- Connection quality monitoring

### 5. **Competitions Module**
- Real-time updates (WebSocket)
- Leaderboard system
- Tournament bracket management

### 6. **Analytics & Telemetry**
- Event tracking infrastructure
- Performance monitoring
- Crash reporting (e.g., Sentry)

---

## Development Workflow

### Version Control
- Feature branches: `feature/auth-implementation`
- Release branches: `release/v1.0.0`
- Hotfix branches: `hotfix/critical-bug`

### Code Review
- PR-based development
- Automated testing on PR creation
- Code quality checks (SwiftLint)

### CI/CD Pipeline (Future)
1. **Build**: Xcode Cloud or GitHub Actions
2. **Test**: Run unit + integration tests
3. **Lint**: SwiftLint validation
4. **Archive**: Create build artifacts
5. **Deploy**: TestFlight → App Store

---

## Clarifying Questions

Before finalizing the structure, please confirm:

1. **Caching Strategy**:
   - Do you prefer CoreData, SQLite, or a simpler solution (UserDefaults) for game catalog caching?
   - How much offline functionality is needed initially?

2. **Networking Library**:
   - Use native `URLSession` or a third-party library like `Alamofire`?

3. **Analytics Requirements**:
   - Any specific analytics provider preference (Firebase, Mixpanel, custom)?
   - What level of user data tracking is acceptable/required?

4. **Controller Hardware**:
   - What type of controller hardware API/SDK will be used?
   - Does it use Apple's GameController framework or a custom SDK?

5. **URL Scheme / Deep Linking**:
   - Do games support custom URL schemes, or will you use Universal Links?
   - Need to handle deep linking from external sources?

6. **Multi-language Support**:
   - Is localization required in Phase 1, or can it be added later?

7. **Testing Priorities**:
   - What level of test coverage is expected in Phase 1?
   - Are UI tests required from the start?

8. **Cloud Gaming**:
   - What protocols/technologies will be used for cloud games?
   - Any specific cloud gaming provider integration needed?

9. **Team Size**:
   - How many developers will work on this simultaneously?
   - This affects how granular the modularization should be.

10. **Deployment Environment**:
    - Will there be separate staging/production environments?
    - Do you need TestFlight distribution or only App Store?

---

## Recommended Next Steps

1. **Review & Approve** this structure proposal
2. **Answer clarifying questions** to refine the architecture
3. **Set up initial project structure** (folders, basic files)
4. **Configure dependencies** (Swift Package Manager)
5. **Create base infrastructure** (APIClient, Theme, Navigation)
6. **Implement Phase 1 features** (Authentication) following this structure

---

## Notes

- This structure is designed to be **flexible and scalable**
- Features can be added incrementally without major refactoring
- Testing is built into the architecture from the start
- Code is organized for easy onboarding of new developers
- Separation of concerns makes debugging and maintenance easier

Would you like me to refine any specific part of this proposal based on your answers to the clarifying questions?

