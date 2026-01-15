//
//  VerifyOTPUseCase.swift
import Foundation

protocol VerifyOTPUseCaseProtocol {
    func execute(email: String, otp: String, type: Int) async throws -> Void
}

final class VerifyOTPUseCase: VerifyOTPUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(email: String, otp: String, type: Int) async throws -> Void {
        return try await authRepository.verifyOTP(email: email, otp: otp, type: type)
    }
}

