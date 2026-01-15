//
//  FetchGameDetailUseCase.swift
import Foundation

protocol FetchGameDetailUseCaseProtocol {
    func execute(gameId: String) async throws -> Game
}

final class FetchGameDetailUseCase: FetchGameDetailUseCaseProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    func execute(gameId: String) async throws -> Game {
        return try await gameRepository.fetchGame(by: gameId)
    }
}

