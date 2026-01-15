//
//  GoogleAuthDataSource.swift
import Foundation
import GoogleSignIn

protocol GoogleAuthDataSourceProtocol {
    func signIn() async throws -> GoogleSignInResult
}

struct GoogleSignInResult {
    let email: String
    let displayName: String?
    let idToken: String?
}

final class GoogleAuthDataSource: GoogleAuthDataSourceProtocol {
    private let clientID: String
    
    init() {
        // Try to get Google Client ID from GoogleService-Info.plist first (Firebase standard)
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let clientId = plist["CLIENT_ID"] as? String,
           !clientId.isEmpty {
            self.clientID = clientId
        }
        // Fallback to Config.plist
        else if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                let plist = NSDictionary(contentsOfFile: path),
                let clientId = plist["GOOGLE_SIGN_IN_CLIENT_ID"] as? String,
                !clientId.isEmpty {
            self.clientID = clientId
        } else {
            // Default fallback - this will need to be set
            self.clientID = "YOUR_GOOGLE_CLIENT_ID"
        }
    }
    
    @MainActor
    func signIn() async throws -> GoogleSignInResult {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AppError.unknown
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            let user = result.user
            guard let email = user.profile?.email else {
                throw AppError.unknown
            }
            
            // Convert email to lowercase for consistency
            let lowercaseEmail = email.lowercased()
            
            return GoogleSignInResult(
                email: lowercaseEmail,
                displayName: user.profile?.name,
                idToken: user.idToken?.tokenString
            )
        } catch {
            throw AppError.unknown
        }
    }
}

