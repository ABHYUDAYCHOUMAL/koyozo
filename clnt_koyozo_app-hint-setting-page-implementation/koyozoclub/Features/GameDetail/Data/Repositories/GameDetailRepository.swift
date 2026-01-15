//
//  GameDetailRepository.swift
import Foundation

protocol GameDetailRepositoryProtocol {
    func fetchGameDetail(gameId: String) async throws -> GameDetail
}

final class GameDetailRepository: GameDetailRepositoryProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    func fetchGameDetail(gameId: String) async throws -> GameDetail {
        let game = try await gameRepository.fetchGame(by: gameId)
        // Fetch additional details like screenshots
        // For now, return basic structure
        return GameDetail(
            game: game,
            screenshots: [],
            description: game.description ?? "",
            releaseDate: nil,
            developer: nil
        )
    }
}

