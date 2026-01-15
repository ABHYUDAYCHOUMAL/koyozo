//
//  ForgotPasswordView.swift
import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel = LoginViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Reset Password")
                .font(.largeTitle)
                .bold()
            
            AppTextField(
                placeholder: "Email",
                text: $viewModel.email
            )
            
            PrimaryButton(title: "Send Reset Link") {
                viewModel.resetPassword()
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ForgotPasswordView(viewModel: LoginViewModel())
}

