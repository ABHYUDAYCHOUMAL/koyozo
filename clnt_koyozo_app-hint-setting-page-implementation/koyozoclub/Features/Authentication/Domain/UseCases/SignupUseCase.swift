//
//  SignupUseCase.swift
import Foundation

protocol SignupUseCaseProtocol {
    func execute(name: String, email: String, password: String) async throws -> AuthToken
}

final class SignupUseCase: SignupUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(name: String, email: String, password: String) async throws -> AuthToken {
        return try await authRepository.signup(name: name, email: email, password: password)
    }
}

