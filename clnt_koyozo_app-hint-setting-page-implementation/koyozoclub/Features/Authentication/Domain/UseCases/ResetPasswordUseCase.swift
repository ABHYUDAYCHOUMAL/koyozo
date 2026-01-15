//
//  ResetPasswordUseCase.swift
import Foundation

protocol ResetPasswordUseCaseProtocol {
    func execute(email: String) async throws -> Void
    func resetPassword(email: String, newPassword: String) async throws -> Void
}

final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(email: String) async throws -> Void {
        // Send OTP for password reset (type 2)
        return try await authRepository.sendOTP(email: email, type: 2)
    }
    
    func resetPassword(email: String, newPassword: String) async throws -> Void {
        return try await authRepository.resetPassword(email: email, newPassword: newPassword)
    }
}
