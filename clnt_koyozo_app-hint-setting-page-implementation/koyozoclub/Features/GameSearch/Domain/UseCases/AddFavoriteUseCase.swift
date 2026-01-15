//
//  AddFavoriteUseCase.swift
import Foundation

protocol AddFavoriteUseCaseProtocol {
    func execute(game: Game) async throws
}

final class AddFavoriteUseCase: AddFavoriteUseCaseProtocol {
    private let favoriteRepository: FavoriteRepository
    
    init(favoriteRepository: FavoriteRepository? = nil) {
        self.favoriteRepository = favoriteRepository ?? FavoriteRepository()
    }
    
    func execute(game: Game) async throws {
        try await favoriteRepository.addFavorite(gameId: game.id)
    }
}

