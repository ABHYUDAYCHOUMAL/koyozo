//
//  AuthRepository.swift
import Foundation

protocol AuthRepositoryProtocol {
    func login(email: String, password: String) async throws -> AuthToken
    func signup(name: String, email: String, password: String) async throws -> AuthToken
    func register(email: String, password: String, username: String, DOB: String, gender: String) async throws -> AuthToken
    func signInWithGoogle() async throws -> AuthToken
    func logout() async throws
    func checkEmailExists(email: String) async throws -> LoginCheckResult
    func sendOTP(email: String, type: Int) async throws -> Void
    func verifyOTP(email: String, otp: String, type: Int) async throws -> Void
    func resetPassword(email: String, newPassword: String) async throws -> Void
    func setPassword(password: String) async throws -> Void
}

final class AuthRepository: AuthRepositoryProtocol {
    private let remoteDataSource: AuthRemoteDataSource
    private let localDataSource: AuthLocalDataSource
    private let googleAuthDataSource: GoogleAuthDataSource
    
    init(
        remoteDataSource: AuthRemoteDataSource? = nil,
        localDataSource: AuthLocalDataSource? = nil,
        googleAuthDataSource: GoogleAuthDataSource? = nil
    ) {
        self.remoteDataSource = remoteDataSource ?? AuthRemoteDataSource()
        self.localDataSource = localDataSource ?? AuthLocalDataSource()
        self.googleAuthDataSource = googleAuthDataSource ?? GoogleAuthDataSource()
    }
    
    func login(email: String, password: String) async throws -> AuthToken {
        let token = try await remoteDataSource.login(email: email, password: password)
        try await localDataSource.saveToken(token)
        return token
    }
    
    func signup(name: String, email: String, password: String) async throws -> AuthToken {
        let token = try await remoteDataSource.signup(name: name, email: email, password: password)
        try await localDataSource.saveToken(token)
        return token
    }
    
    func signInWithGoogle() async throws -> AuthToken {
        let googleResult = try await googleAuthDataSource.signIn()
        let token = try await remoteDataSource.signInWithGoogle(
            email: googleResult.email,
            username: googleResult.displayName
        )
        try await localDataSource.saveToken(token)
        return token
    }
    
    func logout() async throws {
        try await remoteDataSource.logout()
        // Clear session (token and email)
        await UserSessionManager.shared.clearSession()
    }
    
    func checkEmailExists(email: String) async throws -> LoginCheckResult {
        return try await remoteDataSource.checkEmailExists(email: email)
    }
    
    func sendOTP(email: String, type: Int) async throws -> Void {
        return try await remoteDataSource.sendOTP(email: email, type: type)
    }
    
    func verifyOTP(email: String, otp: String, type: Int) async throws -> Void {
        return try await remoteDataSource.verifyOTP(email: email, otp: otp, type: type)
    }
    
    func register(email: String, password: String, username: String, DOB: String, gender: String) async throws -> AuthToken {
        let token = try await remoteDataSource.register(email: email, password: password, username: username, DOB: DOB, gender: gender)
        try await localDataSource.saveToken(token)
        return token
    }
    
    func resetPassword(email: String, newPassword: String) async throws -> Void {
        return try await remoteDataSource.resetPassword(email: email, newPassword: newPassword)
    }
    
    func setPassword(password: String) async throws -> Void {
        return try await remoteDataSource.setPassword(password: password)
    }
}

