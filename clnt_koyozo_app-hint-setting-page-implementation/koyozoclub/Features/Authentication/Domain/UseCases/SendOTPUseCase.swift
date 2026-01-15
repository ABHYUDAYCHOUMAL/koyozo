//
//  SendOTPUseCase.swift
import Foundation

protocol SendOTPUseCaseProtocol {
    func execute(email: String, type: Int) async throws -> Void
}

final class SendOTPUseCase: SendOTPUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(email: String, type: Int) async throws -> Void {
        return try await authRepository.sendOTP(email: email, type: type)
    }
}

