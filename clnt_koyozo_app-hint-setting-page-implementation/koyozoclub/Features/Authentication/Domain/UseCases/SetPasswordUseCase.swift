//
//  SetPasswordUseCase.swift
import Foundation

protocol SetPasswordUseCaseProtocol {
    func execute(password: String) async throws -> Void
}

final class SetPasswordUseCase: SetPasswordUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(password: String) async throws -> Void {
        return try await authRepository.setPassword(password: password)
    }
}

