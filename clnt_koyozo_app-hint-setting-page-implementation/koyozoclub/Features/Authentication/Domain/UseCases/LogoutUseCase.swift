//
//  LogoutUseCase.swift
import Foundation

protocol LogoutUseCaseProtocol {
    func execute() async throws
}

final class LogoutUseCase: LogoutUseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository? = nil) {
        self.authRepository = authRepository ?? AuthRepository()
    }
    
    func execute() async throws {
        try await authRepository.logout()
    }
}

