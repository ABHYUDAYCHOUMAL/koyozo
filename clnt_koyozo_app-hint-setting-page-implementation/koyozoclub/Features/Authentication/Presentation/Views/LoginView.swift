//
//  LoginView.swift
import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedIndex: Int = -1 // -1 means no selection initially
    @State private var cancellables = Set<AnyCancellable>()
    private let controllerManager = ControllerManager.shared
    
    // Focusable elements: 0 = Google button, 1 = Email field, 2 = Continue button
    private let focusableCount = 3
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark blue background
                AppTheme.Colors.darkBlue
                    .ignoresSafeArea()
                
                // Scrollable content to handle keyboard
                ScrollView {
                    VStack(spacing: Spacing.md) {
                        Spacer()
                            .frame(height: max(0, (geometry.size.height - 500) / 2))
                        
                        // Title
                        Text("Log in or Sign up")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        // Google Sign-In Button
                        GoogleSignInButton(
                            isFocused: selectedIndex == 0,
                            action: {
                                viewModel.signInWithGoogle()
                            }
                        )
                        .frame(width: min(400, geometry.size.width * 0.65))
                        
                        // OR Separator
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                            Text("OR")
                                .foregroundColor(.white)
                                .font(.caption)
                                .padding(.horizontal, Spacing.sm)
                            Rectangle()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 1)
                        }
                        .frame(width: min(400, geometry.size.width * 0.65))
                        
                        // Email Input
                        AppTextField(
                            placeholder: "Enter email",
                            text: $viewModel.email,
                            isFocused: selectedIndex == 1,
                            isEmailField: true
                        )
                        .frame(width: min(400, geometry.size.width * 0.65))
                        
                        // Continue Button
                        PrimaryButton(
                            title: "Continue",
                            isFocused: selectedIndex == 2,
                            isDisabled: viewModel.isLoading,
                            action: {
                                viewModel.continueWithEmail()
                            }
                        )
                        .frame(width: min(400, geometry.size.width * 0.65))
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: min(400, geometry.size.width * 0.65))
                                .padding(.top, Spacing.xs)
                        }
                        
                        Spacer()
                            .frame(height: max(0, (geometry.size.height - 500) / 2))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .onAppear {
            viewModel.onNavigate = { route in
                // Clear navigation path when navigating to gameLibrary (after successful login)
                // This prevents showing a back button to login page
                if case .gameLibrary = route {
                    coordinator.navigateAndClearPath(to: route)
                } else {
                    coordinator.navigate(to: route)
                }
            }
            setupControllerHandlers()
            controllerManager.startMonitoring()
        }
        .onDisappear {
            controllerManager.stopMonitoring()
            cancellables.removeAll()
        }
    }
    
    private func setupControllerHandlers() {
        // A Button - Activate selected element
        controllerManager.onButtonAPressed
            .sink { [weak viewModel] in
                guard let viewModel = viewModel else { return }
                
                // Only activate if something is selected
                guard selectedIndex >= 0 else { return }
                
                switch selectedIndex {
                case 0:
                    viewModel.signInWithGoogle()
                case 1:
                    // Focus on email field (already focused, but could trigger keyboard on iOS)
                    break
                case 2:
                    viewModel.continueWithEmail()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Up - Previous element
        controllerManager.onDPadUp
            .sink {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selectedIndex < 0 {
                        // First controller input - select last element
                        selectedIndex = focusableCount - 1
                    } else {
                        selectedIndex = max(0, selectedIndex - 1)
                    }
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Down - Next element
        controllerManager.onDPadDown
            .sink {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if selectedIndex < 0 {
                        // First controller input - select first element
                        selectedIndex = 0
                    } else {
                        selectedIndex = min(focusableCount - 1, selectedIndex + 1)
                    }
                }
            }
            .store(in: &cancellables)
    }
}

#Preview {
    LoginView(viewModel: LoginViewModel())
}

