//
//  GameLibraryViewModel.swift
import Foundation
import SwiftUI
import Combine

class GameLibraryViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    @Published var gameItems: [GameItem] = []
    @Published var favoriteItems: [GameItem] = [] // Favorites list for second row
    @Published var selectedGameIndex: Int = 0
    @Published var selectedFavoriteIndex: Int = 0 // Selection index for favorites row
    @Published var recentGames: [Game] = [] // For RecentGamesView - empty for now
    
    // All games cache for favorites lookup
    private var allGamesCache: [Game] = []
    private let favoritesManager = FavoritesManager.shared
    
    var selectedItem: GameItem? {
        // This will be determined by which row is selected in the view
        // For now, return the selected game from the first row
        guard selectedGameIndex >= 0 && selectedGameIndex < gameItems.count else {
            return nil
        }
        return gameItems[selectedGameIndex]
    }
    
    private let fetchGamesUseCase: FetchGamesUseCase
    private let fetchRecentGamesUseCase: FetchRecentGamesUseCase
    private let launchGameUseCase: LaunchGameUseCase
    
    @Published var isLaunching: Bool = false
    
    init(
        fetchGamesUseCase: FetchGamesUseCase? = nil,
        fetchRecentGamesUseCase: FetchRecentGamesUseCase? = nil,
        launchGameUseCase: LaunchGameUseCase? = nil
    ) {
        self.fetchGamesUseCase = fetchGamesUseCase ?? FetchGamesUseCase()
        self.fetchRecentGamesUseCase = fetchRecentGamesUseCase ?? FetchRecentGamesUseCase()
        self.launchGameUseCase = launchGameUseCase ?? LaunchGameUseCase()
    }
    
    func fetchGames() {
        Task {
            // Step 1: Load from cache immediately (instant display)
            let cachedGames = try? await fetchGamesUseCase.executeCachedForDashboard()
            
            if let cachedGames = cachedGames, !cachedGames.isEmpty {
                await MainActor.run {
                    // Display cached data immediately
                    allGamesCache = cachedGames
                    let previousGameIndex = selectedGameIndex
                    let previousFavoriteIndex = selectedFavoriteIndex
                    
                    gameItems = cachedGames.map { GameItem.game($0) } + [GameItem.allGames]
                    loadFavorites(preserving: previousFavoriteIndex)
                    selectedGameIndex = clampedSelectionIndex(previousGameIndex, upperBound: gameItems.count)
                    isLoading = false // Don't show loading for cached data
                }
            } else {
                // No cache available, show loading
                await MainActor.run {
                    isLoading = true
                }
            }
            
            // Step 2: Refresh from API in background
            errorMessage = nil
            
            do {
                // Fetch top games for the dashboard (defaults to rating desc, top 10)
                let games = try await fetchGamesUseCase.executeForDashboard()
                
                // Check if data actually changed
                let gamesChanged = games.map { $0.id } != allGamesCache.map { $0.id }
                
                await MainActor.run {
                    // Only update if data changed
                    if gamesChanged {
                        // Cache all games for favorites lookup
                        allGamesCache = games
                        
                        let previousGameIndex = selectedGameIndex
                        let previousFavoriteIndex = selectedFavoriteIndex
                        
                        gameItems = games.map { GameItem.game($0) } + [GameItem.allGames]
                        
                        loadFavorites(preserving: previousFavoriteIndex)
                        
                        selectedGameIndex = clampedSelectionIndex(previousGameIndex, upperBound: gameItems.count)
                    }
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    // Only show error if we don't have cached data
                    if allGamesCache.isEmpty {
                        errorMessage = error.localizedDescription
                        
                        let previousGameIndex = selectedGameIndex
                        let previousFavoriteIndex = selectedFavoriteIndex
                        
                        allGamesCache = []
                        
                        // Keep "All Games" entry so navigation remains available
                        gameItems = [GameItem.allGames]
                        
                        loadFavorites(preserving: previousFavoriteIndex)
                        
                        selectedGameIndex = clampedSelectionIndex(previousGameIndex, upperBound: gameItems.count)
                    }
                    isLoading = false
                }
            }
        }
    }
    
    /// Load favorites from local storage
    private func loadFavorites(preserving index: Int? = nil) {
        let previousIndex = index ?? selectedFavoriteIndex
        
        // Primary source: compact summaries persisted locally
        let summaries = favoritesManager.getFavoriteSummaries()
        var favoriteGames = summaries.map { $0.asGame() }
        
        // Backwards compatibility: if any legacy IDs exist without summaries, try to hydrate from cache
        let favoriteIds = favoritesManager.getFavoriteGameIds()
        let summaryIds = Set(summaries.map { $0.id })
        let legacyIds = favoriteIds.filter { !summaryIds.contains($0) }
        if !legacyIds.isEmpty {
            let cachedGames = allGamesCache.filter { legacyIds.contains($0.id) }
            favoriteGames.append(contentsOf: cachedGames)
        }
        
        // Deduplicate by id while preserving order (summaries first, then cache)
        var seen = Set<String>()
        favoriteGames = favoriteGames.filter { game in
            guard !seen.contains(game.id) else { return false }
            seen.insert(game.id)
            return true
        }
        
        favoriteItems = favoriteGames.map { GameItem.game($0) } + [GameItem.allGames]
        
        let upperBound = favoriteItems.count
        selectedFavoriteIndex = clampedSelectionIndex(previousIndex, upperBound: upperBound)
    }
    
    /// Toggle favorite status for the currently selected game
    /// Returns true if game is now favorited, false if removed
    @discardableResult
    func toggleFavoriteForCurrentGame(inRow rowIndex: Int) -> Bool? {
        let game: Game?
        
        if rowIndex == 0 {
            // Games row
            guard let selectedItem = selectedItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        } else {
            // Favorites row
            guard let selectedItem = selectedFavoriteItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        }
        
        guard let game = game else { return nil }
        
        let isFavorited = favoritesManager.toggleFavorite(game: game)
        
        // Reload favorites list
        loadFavorites()
        
        // Adjust selection index if needed
        if !isFavorited && rowIndex == 1 {
            selectedFavoriteIndex = clampedSelectionIndex(selectedFavoriteIndex, upperBound: favoriteItems.count)
        }
        
        return isFavorited
    }
    
    /// Toggle favorite for a specific game
    @discardableResult
    func toggleFavorite(for game: Game) -> Bool {
        let isFavorited = favoritesManager.toggleFavorite(game: game)
        loadFavorites()
        return isFavorited
    }
    
    /// Check if a game is favorited
    func isFavorite(gameId: String) -> Bool {
        return favoritesManager.isFavorite(gameId: gameId)
    }
    
    func selectGame(at index: Int) {
        guard index >= 0 && index < gameItems.count else { return }
        selectedGameIndex = index
    }
    
    func selectFavorite(at index: Int) {
        guard index >= 0 && index < favoriteItems.count else { return }
        selectedFavoriteIndex = index
    }
    
    var selectedFavoriteItem: GameItem? {
        guard selectedFavoriteIndex >= 0 && selectedFavoriteIndex < favoriteItems.count else {
            return nil
        }
        return favoriteItems[selectedFavoriteIndex]
    }
    
    func handleAllGamesTap() {
        // This will be handled by the view to navigate
        // Just select it for visual feedback
        if let allGamesIndex = gameItems.firstIndex(where: { $0.isAllGames }) {
            selectedGameIndex = allGamesIndex
        }
    }
    
    func launchSelectedGame() {
        guard let selectedItem = selectedItem,
              case .game(let game) = selectedItem else {
            // Can't launch "All Games" or invalid selection
            return
        }
        
        launchGame(game)
    }
    
    func launchGame(_ game: Game) {
        isLaunching = true
        errorMessage = nil
        
        launchGameUseCase.execute(game: game)
        
        // Reset launching state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLaunching = false
        }
    }
    
    private func clampedSelectionIndex(_ index: Int, upperBound: Int) -> Int {
        guard upperBound > 0 else { return 0 }
        let maxIndex = upperBound - 1
        if index < 0 {
            return 0
        } else if index > maxIndex {
            return maxIndex
        }
        return index
    }
}

