//
//  VerificationView.swift
import SwiftUI

struct VerificationView: View {
    let email: String
    let type: Int // 1 = signup, 2 = reset password
    @StateObject private var viewModel: VerificationViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    
    init(email: String, type: Int = 1, viewModel: VerificationViewModel? = nil) {
        self.email = email
        self.type = type
        _viewModel = StateObject(wrappedValue: viewModel ?? VerificationViewModel(email: email, type: type))
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
                        Text("Check your inbox")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.white)
                            .padding(.top, Spacing.xs)
                        
                        // Instructions with highlighted email
                        VStack(spacing: Spacing.xs) {
                            Text("Enter the verification code we have just sent to")
                                .font(.body)
                                .foregroundColor(AppTheme.Colors.white)
                                .multilineTextAlignment(.center)
                            
                            Text(email)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.Colors.white)
                                .padding(.top, Spacing.xs)
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.bottom, Spacing.xs)
                        
                        // Code Field
                        LabeledTextField(
                            label: "Code",
                            placeholder: "Enter code",
                            text: $viewModel.code
                        )
                        .frame(width: min(400, geometry.size.width * 0.7))
                        
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(width: min(400, geometry.size.width * 0.7))
                        }
                        
                        // Resend Code Link
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.resendCode()
                            }) {
                                Text("Resend code")
                                    .font(.body)
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        
                        // Continue Button
                        PrimaryButton(title: "Continue") {
                            viewModel.verifyCode()
                        }
                        .frame(width: min(400, geometry.size.width * 0.7))
                        .padding(.top, Spacing.xs)
                        .padding(.bottom, Spacing.md)
                        
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
                    // Clear navigation path when navigating to gameLibrary (after successful signup)
                    // This prevents showing a back button to login page
                    if case .gameLibrary = route {
                        coordinator.navigateAndClearPath(to: route)
                    } else {
                        coordinator.navigate(to: route)
                    }
                }
                // Send OTP when view appears
                viewModel.resendCode()
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
        VerificationView(email: "newfakeemail@gmail.com")
            .environmentObject(AppCoordinator())
    }
    
}
