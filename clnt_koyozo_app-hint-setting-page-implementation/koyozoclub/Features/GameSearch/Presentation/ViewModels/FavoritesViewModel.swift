//
//  FavoritesViewModel.swift
import Foundation
import SwiftUI
import Combine

class FavoritesViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    var favorites: [Game] = []
    
    private let fetchFavoritesUseCase: FetchFavoritesUseCase
    private let addFavoriteUseCase: AddFavoriteUseCase
    private let removeFavoriteUseCase: RemoveFavoriteUseCase
    
    init(
        fetchFavoritesUseCase: FetchFavoritesUseCase? = nil,
        addFavoriteUseCase: AddFavoriteUseCase? = nil,
        removeFavoriteUseCase: RemoveFavoriteUseCase? = nil
    ) {
        self.fetchFavoritesUseCase = fetchFavoritesUseCase ?? FetchFavoritesUseCase()
        self.addFavoriteUseCase = addFavoriteUseCase ?? AddFavoriteUseCase()
        self.removeFavoriteUseCase = removeFavoriteUseCase ?? RemoveFavoriteUseCase()
    }
    
    func fetchFavorites() {
        Task {
            isLoading = true
            do {
                favorites = try await fetchFavoritesUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func addFavorite(_ game: Game) {
        Task {
            do {
                try await addFavoriteUseCase.execute(game: game)
                favorites.append(game)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func removeFavorite(_ game: Game) {
        Task {
            do {
                try await removeFavoriteUseCase.execute(gameId: game.id)
                favorites.removeAll { $0.id == game.id }
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

