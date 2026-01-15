//
//  GameLocalDataSource.swift
import Foundation

protocol GameLocalDataSourceProtocol {
    func fetchGames() async throws -> [Game]
    func fetchRecentGames() async throws -> [Game]
    func fetchGame(by id: String) async throws -> Game?
    func saveGames(_ games: [Game]) async throws
    func saveGame(_ game: Game) async throws
    func markGameAsRecent(_ game: Game) async throws
}

final class GameLocalDataSource: GameLocalDataSourceProtocol {
    private let userDefaultsManager: UserDefaultsManager
    private let dashboardGamesKey = "koyozoclub.cached.dashboard.games"
    private let recentGamesKey = "koyozoclub.cached.recent.games"
    private let gamesCacheKey = "koyozoclub.cached.games"
    
    init(userDefaultsManager: UserDefaultsManager? = nil) {
        self.userDefaultsManager = userDefaultsManager ?? UserDefaultsManager()
    }
    
    func fetchGames() async throws -> [Game] {
        // Fetch cached dashboard games
        if let cachedGames: [Game] = try? await userDefaultsManager.fetch([Game].self, forKey: dashboardGamesKey) {
            return cachedGames
        }
        return []
    }
    
    func fetchRecentGames() async throws -> [Game] {
        // Fetch cached recent games
        if let cachedGames: [Game] = try? await userDefaultsManager.fetch([Game].self, forKey: recentGamesKey) {
            return cachedGames
        }
        return []
    }
    
    func fetchGame(by id: String) async throws -> Game? {
        // Try to find in cached games
        let cachedGames = try await fetchGames()
        return cachedGames.first { $0.id == id }
    }
    
    func saveGames(_ games: [Game]) async throws {
        // Save dashboard games to cache
        try await userDefaultsManager.save(games, forKey: dashboardGamesKey)
    }
    
    func saveGame(_ game: Game) async throws {
        // Update or add game to cache
        var cachedGames = try await fetchGames()
        if let index = cachedGames.firstIndex(where: { $0.id == game.id }) {
            cachedGames[index] = game
        } else {
            cachedGames.append(game)
        }
        try await saveGames(cachedGames)
    }
    
    func markGameAsRecent(_ game: Game) async throws {
        // Add to recent games cache
        var recentGames = try await fetchRecentGames()
        // Remove if already exists to avoid duplicates
        recentGames.removeAll { $0.id == game.id }
        // Add to beginning
        recentGames.insert(game, at: 0)
        // Keep only last 20 recent games
        if recentGames.count > 20 {
            recentGames = Array(recentGames.prefix(20))
        }
        try await userDefaultsManager.save(recentGames, forKey: recentGamesKey)
    }
}

