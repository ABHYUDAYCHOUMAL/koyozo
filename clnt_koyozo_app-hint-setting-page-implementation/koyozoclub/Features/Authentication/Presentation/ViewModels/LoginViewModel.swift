//
//  LoginViewModel.swift
import Foundation
import SwiftUI
import Combine

class LoginViewModel: ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var email: String = ""
    @Published var password: String = ""
    
    private let loginUseCase: LoginUseCase
    private let checkEmailExistsUseCase: CheckEmailExistsUseCase
    var onNavigate: ((Route) -> Void)?
    
    init(
        loginUseCase: LoginUseCase? = nil,
        checkEmailExistsUseCase: CheckEmailExistsUseCase? = nil
    ) {
        self.loginUseCase = loginUseCase ?? LoginUseCase()
        self.checkEmailExistsUseCase = checkEmailExistsUseCase ?? CheckEmailExistsUseCase()
    }
    
    func continueWithEmail() {
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
        errorMessage = nil
        
        Task {
            do {
                let result = try await checkEmailExistsUseCase.execute(email: lowercaseEmail)
                await MainActor.run {
                    isLoading = false
                    switch result {
                    case .emailExists:
                        // Navigate to enter password screen (existing user)
                        // Store lowercase email for consistency
                        self.email = lowercaseEmail
                        onNavigate?(.enterPassword(email: lowercaseEmail))
                    case .emailNotFound:
                        // Navigate to OTP verification screen (new user - signup flow)
                        // Store lowercase email for consistency
                        self.email = lowercaseEmail
                        onNavigate?(.verification(email: lowercaseEmail, type: 1))
                    case .error(let error):
                        errorMessage = "Failed to check email. Please try again."
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to check email. Please try again."
                }
            }
        }
    }
    
    func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        guard Validators.isValidPassword(password) else {
            errorMessage = "Password must be at least 8 characters and contain a number"
            return
        }
        
        // Convert email to lowercase before sending to backend
        let lowercaseEmail = email.lowercased()
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await loginUseCase.execute(email: lowercaseEmail, password: password)
                await MainActor.run {
                    isLoading = false
                    // Store lowercase email for consistency
                    self.email = lowercaseEmail
                    // Save email to session
                    UserSessionManager.shared.saveUserEmail(lowercaseEmail)
                    // Set flag to show login snackbar
                    UserSessionManager.shared.setShouldShowLoginSnackbar(true)
                    // Navigate to main app after successful login - clear path so no back button
                    onNavigate?(.gameLibrary)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Login failed. Please check your credentials."
                }
            }
        }
    }
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Get email from Google Sign-In
                let googleAuthDataSource = GoogleAuthDataSource()
                let googleResult = try await googleAuthDataSource.signIn()
                
                // Sign in with Google
                let googleSignInUseCase = GoogleSignInUseCase()
                _ = try await googleSignInUseCase.execute()
                
                await MainActor.run {
                    isLoading = false
                    // Save email to session
                    UserSessionManager.shared.saveUserEmail(googleResult.email)
                    // Set flag to show login snackbar
                    UserSessionManager.shared.setShouldShowLoginSnackbar(true)
                    // Navigate to main app
                    onNavigate?(.gameLibrary)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Google Sign-In failed. Please try again."
                }
            }
        }
    }
    
    func resetPassword() {
        // Implement password reset logic
    }
}

