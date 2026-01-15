//
//  MarkGamePlayedUseCase.swift
import Foundation

protocol MarkGamePlayedUseCaseProtocol {
    func execute(gameId: String) async throws
}

final class MarkGamePlayedUseCase: MarkGamePlayedUseCaseProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    func execute(gameId: String) async throws {
        // Mark game as played in repository
        // This can update local cache and/or remote server
    }
}

