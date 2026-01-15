//
//  SetPasswordViewModel.swift
import Foundation
import SwiftUI
import Combine

class SetPasswordViewModel: ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    var email: String = ""
    var isSignup: Bool = false
    
    var onNavigate: ((Route) -> Void)?
    var onSuccess: (() -> Void)?
    
    private let resetPasswordUseCase: ResetPasswordUseCase
    
    init(resetPasswordUseCase: ResetPasswordUseCase? = nil) {
        self.resetPasswordUseCase = resetPasswordUseCase ?? ResetPasswordUseCase()
    }
    
    func validatePassword() {
        errorMessage = nil
        
        // Check if password is empty
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }
        
        // Check password requirements: 8 characters and 1 number
        guard Validators.hasMinimumCharacters(password, count: 8) else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard Validators.hasNumber(password) else {
            errorMessage = "Password must contain at least 1 number"
            return
        }
    }
    
    func setPassword() {
        errorMessage = nil
        
        // Check if password is empty
        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }
        
        // Check password requirements: 8 characters and 1 number
        guard Validators.hasMinimumCharacters(password, count: 8) else {
            errorMessage = "Password must be at least 8 characters"
            return
        }
        
        guard Validators.hasNumber(password) else {
            errorMessage = "Password must contain at least 1 number"
            return
        }
        
        // Check if confirm password is empty
        guard !confirmPassword.isEmpty else {
            errorMessage = "Please confirm your password"
            return
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            return
        }
        
        Task {
            if isSignup {
                // Signup flow: navigate to user information screen with password
                await MainActor.run {
                    isLoading = false
                    onNavigate?(.userInformation(email: email, password: password))
                }
            } else {
                // Reset password flow: call resetPassword API
                do {
                    try await resetPasswordUseCase.resetPassword(email: email, newPassword: password)
                    await MainActor.run {
                        isLoading = false
                        // Navigate to login screen after successful password reset
                        onNavigate?(.login)
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Failed to set password. Please try again."
                    }
                }
            }
        }
    }
}

