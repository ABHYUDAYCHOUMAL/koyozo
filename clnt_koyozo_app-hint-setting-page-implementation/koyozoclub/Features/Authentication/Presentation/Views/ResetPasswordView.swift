//
//  ResetPasswordView.swift
import SwiftUI

struct ResetPasswordView: View {
    @StateObject private var viewModel: ResetPasswordViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    init(viewModel: ResetPasswordViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? ResetPasswordViewModel())
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
                        Text("Reset password")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.white)
                            .padding(.top, Spacing.xs)
                        
                        // Instruction
                        Text("Confirm the email for password reset")
                            .font(.body)
                            .foregroundColor(AppTheme.Colors.white)
                            .multilineTextAlignment(.center)
                            .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Email Field
                        LabeledTextField(
                            label: "Email",
                            placeholder: "Enter email",
                        text: $viewModel.email,
                        isEmailField: true
                        )
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
                            viewModel.sendResetLink()
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        
                        // Back to Login Link
                        Button(action: {
                            coordinator.popToRoot()
                        }) {
                            Text("Back to login")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.white)
                        }
                        .padding(.top, Spacing.md)
                        .padding(.bottom, Spacing.lg)
                        
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
                viewModel.onNavigate = { route in
                    coordinator.navigate(to: route)
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
        ResetPasswordView()
            .environmentObject(AppCoordinator())
    }
    
}
