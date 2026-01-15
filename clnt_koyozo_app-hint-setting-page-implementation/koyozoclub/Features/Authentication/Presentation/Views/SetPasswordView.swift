//
//  SetPasswordView.swift
import SwiftUI

struct SetPasswordView: View {
    let email: String
    let isSignup: Bool
    @StateObject private var viewModel: SetPasswordViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @FocusState private var focusedField: Field?
    
    enum Field {
        case password
        case confirmPassword
    }
    
    init(email: String, isSignup: Bool = false, viewModel: SetPasswordViewModel? = nil) {
        self.email = email
        self.isSignup = isSignup
        _viewModel = StateObject(wrappedValue: viewModel ?? SetPasswordViewModel())
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
                    
                    // Centered vertical layout - no scrolling
                    VStack(spacing: Spacing.sm) {
                        // Title
                        Text("Set Password")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.white)
                            .padding(.top, Spacing.xs)
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Password")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.white)
                            
                            ZStack(alignment: .leading) {
                                // Placeholder text - only show when password is empty AND not focused
                                if viewModel.password.isEmpty && focusedField != .password {
                                    Text("Enter password")
                                        .foregroundColor(Color.gray.opacity(0.6))
                                        .font(.body)
                                        .allowsHitTesting(false)
                                }
                                
                                SecureField("", text: $viewModel.password)
                                    .focused($focusedField, equals: .password)
                                    .foregroundColor(AppTheme.Colors.darkBlue)
                                    .font(.body)
                            }
                            .padding(.vertical, Spacing.md)
                            .padding(.horizontal, Spacing.sm + Spacing.xs)
                            .background(AppTheme.Colors.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.Colors.darkBlue, lineWidth: 1)
                            )
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .onChange(of: focusedField) { oldValue, newValue in
                            // When user moves from password field to confirm password field
                            if oldValue == .password && newValue == .confirmPassword {
                                viewModel.validatePassword()
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text("Confirm Password")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.white)
                            
                            ZStack(alignment: .leading) {
                                // Placeholder text - only show when confirmPassword is empty AND not focused
                                if viewModel.confirmPassword.isEmpty && focusedField != .confirmPassword {
                                    Text("Enter password again")
                                        .foregroundColor(Color.gray.opacity(0.6))
                                        .font(.body)
                                        .allowsHitTesting(false)
                                }
                                
                                SecureField("", text: $viewModel.confirmPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .foregroundColor(AppTheme.Colors.darkBlue)
                                    .font(.body)
                            }
                            .padding(.vertical, Spacing.md)
                            .padding(.horizontal, Spacing.sm + Spacing.xs)
                            .background(AppTheme.Colors.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppTheme.Colors.darkBlue, lineWidth: 1)
                            )
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: min(400, geometry.size.width * 0.7))
                        }
                        
                        // Continue Button
                        PrimaryButton(title: "Continue") {
                            viewModel.setPassword()
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, Spacing.lg)
                        .disabled(viewModel.isLoading)
                        
                        // Loading Indicator
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarBackButtonHidden()
            .onAppear {
                // Store email in lowercase for consistency
                viewModel.email = email.lowercased()
                viewModel.isSignup = isSignup
                viewModel.onNavigate = { route in
                    // Clear navigation path when navigating to gameLibrary (after successful signup)
                    // This prevents showing a back button to login page
                    if case .gameLibrary = route {
                        coordinator.navigateAndClearPath(to: route)
                    } else {
                        coordinator.navigate(to: route)
                    }
                }
            }
        }
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
    
    #Preview {
        SetPasswordView(email: "test@example.com", isSignup: false)
            .environmentObject(AppCoordinator())
    }
}
