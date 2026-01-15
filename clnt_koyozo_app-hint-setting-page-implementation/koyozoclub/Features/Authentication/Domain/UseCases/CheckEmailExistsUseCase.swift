//
//  CheckEmailExistsUseCase.swift
import Foundation

protocol CheckEmailExistsUseCaseProtocol {
    func execute(email: String) async throws -> LoginCheckResult
}

final class CheckEmailExistsUseCase: CheckEmailExistsUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(email: String) async throws -> LoginCheckResult {
        return try await authRepository.checkEmailExists(email: email)
    }
}

