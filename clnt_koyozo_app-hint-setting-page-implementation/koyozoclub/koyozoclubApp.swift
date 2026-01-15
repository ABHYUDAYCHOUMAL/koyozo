//
//  koyozoclubApp.swift
import SwiftUI

@main
struct koyozoclubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var coordinator = AppCoordinator()
    @State private var isCheckingSession = true
    @State private var isLoggedIn = false
    
    init() {
        ControllerManager.shared.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $coordinator.navigationPath) {
                Group {
                    if isCheckingSession {
                        // Show a loading state while checking session
                        ZStack {
                            AppTheme.Colors.darkBlue
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        .onAppear {
                            checkSession()
                        }
                    } else if isLoggedIn {
                        // User is logged in, show GameLibraryView
                        GameLibraryView()
                    } else {
                        // User is not logged in, show LoginView
                        LoginView()
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    routeView(for: route)
                }
            }
            .environmentObject(coordinator)
        }
    }
    
    private func checkSession() {
        Task {
            let loggedIn = await UserSessionManager.shared.isLoggedIn()
            await MainActor.run {
                isLoggedIn = loggedIn
                isCheckingSession = false
            }
        }
    }
    
    @ViewBuilder
    private func routeView(for route: Route) -> some View {
        switch route {
        case .login:
            LoginView()
        case .enterPassword(let email):
            EnterPasswordView(email: email)
        case .signup(let email):
            SignupView(email: email)
        case .verification(let email, let type):
            VerificationView(email: email, type: type)
        case .userInformation(let email, let password):
            UserInformationView(email: email, password: password)
        case .resetPassword:
            ResetPasswordView()
        case .setPassword(let email, let isSignup):
            SetPasswordView(email: email, isSignup: isSignup)
        case .gameLibrary:
            GameLibraryView()
        case .allGames(let showSearch):
            AllGamesView(showSearch: showSearch)
        case .search:
            SearchView()
        case .favorites:
            FavoritesView()
        case .profile:
            ProfileView()
        case .settings:
            SettingsView()
        }
    }
}
