//
//  RemoveFavoriteUseCase.swift
import Foundation

protocol RemoveFavoriteUseCaseProtocol {
    func execute(gameId: String) async throws
}

final class RemoveFavoriteUseCase: RemoveFavoriteUseCaseProtocol {
    private let favoriteRepository: FavoriteRepository
    
    init(favoriteRepository: FavoriteRepository? = nil) {
        self.favoriteRepository = favoriteRepository ?? FavoriteRepository()
    }
    
    func execute(gameId: String) async throws {
        try await favoriteRepository.removeFavorite(gameId: gameId)
    }
}

