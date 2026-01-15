//
//  FavoritesManager.swift
import Foundation

/// Manages favorite games storage in UserDefaults
final class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let userDefaults: UserDefaults
    private let favoritesKey = "koyozoclub.favorites.gameIds"
    private let favoriteSummariesKey = "koyozoclub.favorites.summaries"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    /// Get all favorite game IDs
    func getFavoriteGameIds() -> [String] {
        let summaries = getFavoriteSummaries()
        if !summaries.isEmpty {
            return summaries.map { $0.id }
        }
        
        return userDefaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    /// Get all favorite game summaries
    func getFavoriteSummaries() -> [FavoriteGameSummary] {
        guard let data = userDefaults.data(forKey: favoriteSummariesKey),
              let summaries = try? decoder.decode([FavoriteGameSummary].self, from: data) else {
            return []
        }
        return summaries
    }
    
    /// Save summaries to storage
    private func saveFavoriteSummaries(_ summaries: [FavoriteGameSummary]) {
        if let data = try? encoder.encode(summaries) {
            userDefaults.set(data, forKey: favoriteSummariesKey)
        }
    }
    
    /// Save IDs to storage (backwards compatibility)
    private func saveFavoriteIds(_ ids: [String]) {
        userDefaults.set(ids, forKey: favoritesKey)
    }
    
    /// Check if a game is favorited
    func isFavorite(gameId: String) -> Bool {
        return getFavoriteGameIds().contains(gameId)
    }
    
    /// Add a game to favorites using full game data
    func addFavorite(game: Game) {
        // Upsert summary
        var summaries = getFavoriteSummaries()
        if !summaries.contains(where: { $0.id == game.id }) {
            summaries.append(FavoriteGameSummary(game: game))
            saveFavoriteSummaries(summaries)
        }
        
        // Maintain legacy IDs list
        var ids = userDefaults.stringArray(forKey: favoritesKey) ?? []
        if !ids.contains(game.id) {
            ids.append(game.id)
            saveFavoriteIds(ids)
        }
    }
    
    /// Remove a game from favorites
    func removeFavorite(gameId: String) {
        // Remove from summaries
        var summaries = getFavoriteSummaries()
        summaries.removeAll { $0.id == gameId }
        saveFavoriteSummaries(summaries)
        
        // Remove from legacy IDs list
        var ids = userDefaults.stringArray(forKey: favoritesKey) ?? []
        ids.removeAll { $0 == gameId }
        saveFavoriteIds(ids)
    }
    
    /// Toggle favorite status for a game
    /// Returns true if game is now favorited, false if removed
    @discardableResult
    func toggleFavorite(gameId: String) -> Bool {
        if isFavorite(gameId: gameId) {
            removeFavorite(gameId: gameId)
            return false
        } else {
            // Without full game data we can only persist the ID (legacy path)
            var ids = userDefaults.stringArray(forKey: favoritesKey) ?? []
            guard !ids.contains(gameId) else { return true }
            ids.append(gameId)
            saveFavoriteIds(ids)
            return true
        }
    }
    
    /// Toggle favorite status with full game data (preferred)
    /// Returns true if game is now favorited, false if removed
    @discardableResult
    func toggleFavorite(game: Game) -> Bool {
        if isFavorite(gameId: game.id) {
            removeFavorite(gameId: game.id)
            return false
        } else {
            addFavorite(game: game)
            return true
        }
    }
    
    /// Clear all favorites (for testing/reset)
    func clearAllFavorites() {
        userDefaults.removeObject(forKey: favoritesKey)
        userDefaults.removeObject(forKey: favoriteSummariesKey)
    }
}

