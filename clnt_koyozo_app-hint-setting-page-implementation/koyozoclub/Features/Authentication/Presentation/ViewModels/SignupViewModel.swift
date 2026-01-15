//
//  SignupViewModel.swift
import Foundation
import SwiftUI
import Combine

class SignupViewModel: ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var name: String = ""
    var email: String = ""
    @Published var password: String = "" {
        didSet {
            updatePasswordRequirements()
        }
    }
    
    @Published var passwordRequirements: [PasswordRequirement] = [
        PasswordRequirement(text: "8 characters"),
        PasswordRequirement(text: "1 number")
    ]
    
    @Published var showPasswordErrors: Bool = false
    
    var onNavigate: ((Route) -> Void)?
    
    private let signupUseCase: SignupUseCase
    
    init(signupUseCase: SignupUseCase? = nil) {
        self.signupUseCase = signupUseCase ?? SignupUseCase()
    }
    
    private func updatePasswordRequirements() {
        passwordRequirements = [
            PasswordRequirement(
                text: "8 characters",
                isMet: Validators.hasMinimumCharacters(password, count: 8),
                showError: showPasswordErrors && !Validators.hasMinimumCharacters(password, count: 8)
            ),
            PasswordRequirement(
                text: "1 number",
                isMet: Validators.hasNumber(password),
                showError: showPasswordErrors && !Validators.hasNumber(password)
            )
        ]
    }
    
    func signup() {
        // SignupView is not used in the current flow
        // Flow: LoginView → VerificationView → SetPasswordView → UserInformationView → Register
        // This method is kept for compatibility but should not be called
        errorMessage = "Please use the email login flow"
    }
    
    func signInWithGoogle() {
        // Implement Google Sign-In logic
    }
}

