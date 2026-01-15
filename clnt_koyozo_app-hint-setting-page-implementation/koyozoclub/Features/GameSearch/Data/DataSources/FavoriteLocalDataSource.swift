//
//  FavoriteLocalDataSource.swift
import Foundation

protocol FavoriteLocalDataSourceProtocol {
    func fetchFavorites() async throws -> [Game]
    func saveFavorites(_ games: [Game]) async throws
    func addFavorite(gameId: String) async throws
    func removeFavorite(gameId: String) async throws
    func isFavorite(gameId: String) async throws -> Bool
}

final class FavoriteLocalDataSource: FavoriteLocalDataSourceProtocol {
    func fetchFavorites() async throws -> [Game] {
        // Implement local fetch
        return []
    }
    
    func saveFavorites(_ games: [Game]) async throws {
        // Implement local save
    }
    
    func addFavorite(gameId: String) async throws {
        // Implement local add
    }
    
    func removeFavorite(gameId: String) async throws {
        // Implement local remove
    }
    
    func isFavorite(gameId: String) async throws -> Bool {
        // Implement check
        return false
    }
}

