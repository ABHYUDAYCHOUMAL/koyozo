//
//  GoogleSignInUseCase.swift
import Foundation

protocol GoogleSignInUseCaseProtocol {
    func execute() async throws -> AuthToken
}

final class GoogleSignInUseCase: GoogleSignInUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute() async throws -> AuthToken {
        return try await authRepository.signInWithGoogle()
    }
}

