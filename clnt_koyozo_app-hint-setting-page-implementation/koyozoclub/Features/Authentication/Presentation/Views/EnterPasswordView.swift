//
//  EnterPasswordView.swift
import SwiftUI
import Combine

struct EnterPasswordView: View {
    let email: String
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedIndex: Int = -1 // -1 means no selection initially
    @State private var cancellables = Set<AnyCancellable>()
    private let controllerManager = ControllerManager.shared
    
    // Focusable elements: 0 = Password field, 1 = Forgot password link, 2 = Log in button
    private let focusableCount = 3
    
    init(email: String, viewModel: LoginViewModel = LoginViewModel()) {
        self.email = email
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark blue background
                AppTheme.Colors.darkBlue
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Navigation Bar
                    customNavigationBar(topInset: geometry.safeAreaInsets.top)
                    
                    // Fixed content (no scrolling)
                    VStack(spacing: Spacing.sm) {
                        // Title
                        Text("Enter your password")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(AppTheme.Colors.white)
                            .padding(.top, Spacing.sm)
                        
                        // Email Field (pre-filled with edit option)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Email")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.white)
                            
                            HStack {
                                Text(email)
                                    .foregroundColor(AppTheme.Colors.text)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .font(.body)
                                
                                Spacer()
                                
                                Button(action: {
                                    coordinator.pop()
                                }) {
                                    Text("Edit")
                                        .font(.body)
                                        .foregroundColor(AppTheme.Colors.text)
                                }
                            }
                            .padding(.vertical, Spacing.md)
                            .padding(.horizontal, Spacing.sm + Spacing.xs)
                            .background(AppTheme.Colors.inputBackground)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.Colors.inputBorder, lineWidth: 1)
                            )
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Password Field
                        LabeledTextField(
                            label: "Password",
                            placeholder: "Enter password",
                            text: $viewModel.password,
                            isSecure: true,
                            isFocused: selectedIndex == 0
                        )
                        .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Forgot Password Link
                        HStack {
                            Button(action: {
                                coordinator.navigate(to: .resetPassword)
                            }) {
                                Text("Forgot password?")
                                    .font(.body)
                                    .foregroundColor(selectedIndex == 1 ? Color.white : AppTheme.Colors.primary)
                                    .underline(selectedIndex == 1)
                            }
                            Spacer()
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: min(400, geometry.size.width * 0.7))
                        }
                        
                        // Log In Button
                        PrimaryButton(
                            title: "Log in",
                            isFocused: selectedIndex == 2,
                            action: {
                                viewModel.login()
                            }
                        )
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.sm)
                        .padding(.bottom, Spacing.lg)
                        .disabled(viewModel.isLoading)
                        
                        // Loading Indicator
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        
                        Spacer(minLength: geometry.safeAreaInsets.bottom + Spacing.lg)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .onAppear {
            // Store email in lowercase for consistency
            viewModel.email = email.lowercased()
            viewModel.onNavigate = { route in
                // Clear navigation when landing on the dashboard to prevent back navigation to auth
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
                    // Focus on password field (already focused)
                    break
                case 1:
                    coordinator.navigate(to: .resetPassword)
                case 2:
                    viewModel.login()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // B Button - Go back
        controllerManager.onButtonBPressed
            .sink {
                coordinator.pop()
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
    
    @ViewBuilder
    private func customNavigationBar(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    coordinator.pop()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            .padding(.top, topInset + Spacing.sm)
            
            Divider()
                .background(AppTheme.Colors.text.opacity(0.2))
        }
        .background(AppTheme.Colors.darkBlue)
    }
}
    #Preview {
        EnterPasswordView(email: "Fakeveryverylongemail@gm")
            .environmentObject(AppCoordinator())
    }
