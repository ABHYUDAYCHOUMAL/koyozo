//
//  SignupView.swift
import SwiftUI
import Combine

struct SignupView: View {
    let email: String
    @StateObject private var viewModel: SignupViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selectedIndex: Int = -1 // -1 means no selection initially
    @State private var cancellables = Set<AnyCancellable>()
    private let controllerManager = ControllerManager.shared
    
    // Focusable elements: 0 = Password field, 1 = Continue button
    private let focusableCount = 2
    
    init(email: String, viewModel: SignupViewModel = SignupViewModel()) {
        self.email = email
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
                    VStack(spacing: Spacing.xs) {
                        Spacer()
                            .frame(height: max(20, (geometry.size.height - 600) / 2))
                        
                        // Title
                        Text("Create your account")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.white)
                            .padding(.top, Spacing.xs)
                        
                        // Email Field (pre-filled)
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Email")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.white)
                            
                            Text(email)
                                .foregroundColor(AppTheme.Colors.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .font(.body)
                                .padding(.vertical, Spacing.md)
                                .padding(.horizontal, Spacing.sm + Spacing.xs)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.Colors.darkBlue)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(AppTheme.Colors.white, lineWidth: 1)
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
                        
                        // Password Requirements
                        PasswordRequirementsView(requirements: viewModel.passwordRequirements)
                            .frame(width: min(400, geometry.size.width * 0.7))
                            .padding(.top, Spacing.sm)
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: min(400, geometry.size.width * 0.7))
                        }
                        
                        // Continue Button
                        PrimaryButton(
                            title: "Continue",
                            isFocused: selectedIndex == 1,
                            isDisabled: viewModel.isLoading,
                            action: {
                                viewModel.signup()
                            }
                        )
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, Spacing.md)
                        
                        Spacer()
                            .frame(height: max(20, (geometry.size.height - 600) / 2))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .onAppear {
            viewModel.email = email
            viewModel.onNavigate = { route in
                // Clear stack when entering the main app so there’s no back to auth
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
                    viewModel.signup()
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
    SignupView(email: "Fakeemail@gmail.com")
        .environmentObject(AppCoordinator())
}

