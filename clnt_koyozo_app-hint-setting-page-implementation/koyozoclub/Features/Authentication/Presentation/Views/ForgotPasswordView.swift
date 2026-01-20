//
//  ForgotPasswordView.swift
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppTheme.Colors.darkBlue
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.md) {
                Text("Reset Password")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.text)
                
                AppTextField(
                    placeholder: "Enter email",
                    text: $viewModel.email,
                    isEmailField: true
                )
                
                PrimaryButton(title: "Send Reset Link") {
                    viewModel.resetPassword()
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: 420)
        }
    }
}

#Preview {
    ForgotPasswordView(viewModel: LoginViewModel())
}

