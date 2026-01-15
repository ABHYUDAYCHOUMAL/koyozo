//
//  ResetPasswordViewModel.swift
import Foundation
import SwiftUI
import Combine

class ResetPasswordViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    @Published var email: String = ""
    
    var onNavigate: ((Route) -> Void)?
    
    private let resetPasswordUseCase: ResetPasswordUseCase
    
    init(resetPasswordUseCase: ResetPasswordUseCase? = nil) {
        self.resetPasswordUseCase = resetPasswordUseCase ?? ResetPasswordUseCase()
    }
    
    func sendResetLink() {
        errorMessage = nil
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }
        
        guard Validators.isValidEmail(email) else {
            errorMessage = "Please enter a valid email"
            return
        }
        
        // Convert email to lowercase before sending to backend
        let lowercaseEmail = email.lowercased()
        
        isLoading = true
        
        Task {
            do {
                _ = try await resetPasswordUseCase.execute(email: lowercaseEmail)
                await MainActor.run {
                    isLoading = false
                    // Store lowercase email for consistency
                    self.email = lowercaseEmail
                    // Navigate to verification screen (type 2 = reset password)
                    onNavigate?(.verification(email: lowercaseEmail, type: 2))
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to send reset link. Please try again."
                }
            }
        }
    }
}

