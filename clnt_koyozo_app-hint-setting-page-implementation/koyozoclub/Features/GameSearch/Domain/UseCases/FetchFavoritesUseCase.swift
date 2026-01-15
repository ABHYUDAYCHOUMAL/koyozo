//
//  FetchFavoritesUseCase.swift
import Foundation

protocol FetchFavoritesUseCaseProtocol {
    func execute() async throws -> [Game]
}

final class FetchFavoritesUseCase: FetchFavoritesUseCaseProtocol {
    private let favoriteRepository: FavoriteRepository
    
    init(favoriteRepository: FavoriteRepository? = nil) {
        self.favoriteRepository = favoriteRepository ?? FavoriteRepository()
    }
    
    func execute() async throws -> [Game] {
        return try await favoriteRepository.fetchFavorites()
    }
}

