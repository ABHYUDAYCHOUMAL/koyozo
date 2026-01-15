//
//  RegisterUseCase.swift
import Foundation

protocol RegisterUseCaseProtocol {
    func execute(email: String, password: String, username: String, DOB: String, gender: String) async throws -> AuthToken
}

final class RegisterUseCase: RegisterUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute(email: String, password: String, username: String, DOB: String, gender: String) async throws -> AuthToken {
        return try await authRepository.register(email: email, password: password, username: username, DOB: DOB, gender: gender)
    }
}

