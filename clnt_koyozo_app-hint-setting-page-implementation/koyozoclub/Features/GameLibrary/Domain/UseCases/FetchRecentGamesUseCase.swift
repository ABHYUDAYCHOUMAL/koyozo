//
//  FetchRecentGamesUseCase.swift
import Foundation

protocol FetchRecentGamesUseCaseProtocol {
    func execute() async throws -> [Game]
}

final class FetchRecentGamesUseCase: FetchRecentGamesUseCaseProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    func execute() async throws -> [Game] {
        return try await gameRepository.fetchRecentGames()
    }
}

