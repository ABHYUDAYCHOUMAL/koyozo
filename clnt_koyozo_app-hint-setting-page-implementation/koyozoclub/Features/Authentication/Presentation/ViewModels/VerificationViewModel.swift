//
//  VerificationViewModel.swift
import Foundation
import SwiftUI
import Combine

class VerificationViewModel: ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let email: String
    let type: Int // 1 = signup, 2 = reset password
    @Published var code: String = ""
    
    private let sendOTPUseCase: SendOTPUseCase
    private let verifyOTPUseCase: VerifyOTPUseCase
    
    var onNavigate: ((Route) -> Void)?
    
    init(
        email: String,
        type: Int = 1,
        sendOTPUseCase: SendOTPUseCase? = nil,
        verifyOTPUseCase: VerifyOTPUseCase? = nil
    ) {
        // Store email in lowercase for consistency
        self.email = email.lowercased()
        self.type = type
        self.sendOTPUseCase = sendOTPUseCase ?? SendOTPUseCase()
        self.verifyOTPUseCase = verifyOTPUseCase ?? VerifyOTPUseCase()
    }
    
    func verifyCode() {
        guard !code.isEmpty else {
            errorMessage = "Please enter the verification code"
            return
        }
        
        guard code.count == 6 else {
            errorMessage = "OTP must be 6 digits"
            return
        }
        
        // Hardcoded OTP: 123456
        guard code == "123456" else {
            errorMessage = "Incorrect code. Please enter 123456"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await verifyOTPUseCase.execute(email: email, otp: code, type: type)
                await MainActor.run {
                    isLoading = false
                    // Navigate based on type
                    if type == 1 {
                        // Signup flow: navigate to set password screen first
                        onNavigate?(.setPassword(email: email, isSignup: true))
                    } else {
                        // Reset password flow: navigate to set password screen
                        onNavigate?(.setPassword(email: email, isSignup: false))
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Verification failed. Please try again."
                }
            }
        }
    }
    
    func resendCode() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await sendOTPUseCase.execute(email: email, type: type)
                await MainActor.run {
                    isLoading = false
                    // OTP is hardcoded as 123456, so just show success message
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to resend code. Please try again."
                }
            }
        }
    }
}

