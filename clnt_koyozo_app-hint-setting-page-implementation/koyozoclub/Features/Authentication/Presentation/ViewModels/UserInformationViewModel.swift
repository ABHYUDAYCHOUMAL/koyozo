//
//  UserInformationViewModel.swift
import Foundation
import SwiftUI
import Combine

class UserInformationViewModel: ViewModelProtocol {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var fullName: String = ""
    @Published var birthdate: Date? = nil
    @Published var selectedGender: String? = nil
    @Published var showDatePicker: Bool = false
    
    var email: String = ""
    var password: String = "" // Will be set from SetPasswordView in signup flow, or empty for now
    
    let genderOptions = ["Male", "Female", "Prefer not to say"]
    
    private let registerUseCase: RegisterUseCase
    
    var formattedBirthdate: String {
        guard let date = birthdate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    var formattedDOB: String {
        guard let date = birthdate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date)
    }
    
    var onNavigate: ((Route) -> Void)?
    
    init(registerUseCase: RegisterUseCase? = nil) {
        self.registerUseCase = registerUseCase ?? RegisterUseCase()
    }
    
    func submitUserInfo() {
        errorMessage = nil
        
        guard !fullName.isEmpty else {
            errorMessage = "Please enter your full name"
            return
        }
        
        guard birthdate != nil else {
            errorMessage = "Please select your birthdate"
            return
        }
        
        guard selectedGender != nil else {
            errorMessage = "Please select your gender"
            return
        }
        
        guard !email.isEmpty else {
            errorMessage = "Email is required"
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password is required"
            return
        }
        
        isLoading = true
        
        Task {
            do {
                // Convert gender to lowercase for API
                let gender = selectedGender?.lowercased() ?? "male"
                _ = try await registerUseCase.execute(
                    email: email,
                    password: password,
                    username: fullName,
                    DOB: formattedDOB,
                    gender: gender
                )
                await MainActor.run {
                    isLoading = false
                    // Save email to session
                    UserSessionManager.shared.saveUserEmail(email)
                    // Set flag to show login snackbar
                    UserSessionManager.shared.setShouldShowLoginSnackbar(true)
                    // Navigate to main app after successful registration
                    // First-time signup users should see onboarding
                    onNavigate?(.onboarding)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Registration failed. Please try again."
                }
            }
        }
    }
}

