//
//  UserSessionManager.swift
import Foundation

final class UserSessionManager {
    static let shared = UserSessionManager()
    
    private let userDefaults: UserDefaults
    private let emailKey = "user_email"
    private let shouldShowLoginSnackbarKey = "should_show_login_snackbar"
    private let authLocalDataSource: AuthLocalDataSource
    
    init(userDefaults: UserDefaults = .standard, authLocalDataSource: AuthLocalDataSource? = nil) {
        self.userDefaults = userDefaults
        self.authLocalDataSource = authLocalDataSource ?? AuthLocalDataSource()
    }
    
    func saveUserEmail(_ email: String) {
        userDefaults.set(email, forKey: emailKey)
    }
    
    func setShouldShowLoginSnackbar(_ shouldShow: Bool) {
        userDefaults.set(shouldShow, forKey: shouldShowLoginSnackbarKey)
    }
    
    func shouldShowLoginSnackbar() -> Bool {
        return userDefaults.bool(forKey: shouldShowLoginSnackbarKey)
    }
    
    func getUserEmail() -> String? {
        return userDefaults.string(forKey: emailKey)
    }
    
    func clearUserEmail() {
        userDefaults.removeObject(forKey: emailKey)
    }
    
    func isLoggedIn() async -> Bool {
        // Check if we have both email and token
        guard let email = getUserEmail(), !email.isEmpty else {
            return false
        }
        
        // Check if token exists
        if let _ = try? await authLocalDataSource.getToken() {
            return true
        }
        
        return false
    }
    
    func clearSession() async {
        clearUserEmail()
        setShouldShowLoginSnackbar(false)
        try? await authLocalDataSource.clearToken()
    }
}

