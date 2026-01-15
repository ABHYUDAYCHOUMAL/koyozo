//
//  LoginUseCase.swift
import Foundation

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> AuthToken
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(email: String, password: String) async throws -> AuthToken {
        return try await authRepository.login(email: email, password: password)
    }
}

