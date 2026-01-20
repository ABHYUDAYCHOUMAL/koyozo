//
//  GameLibraryViewModel.swift
import Foundation
import SwiftUI
import Combine

class GameLibraryViewModel: ViewModelProtocol
{
    var isLoading: Bool = false
    var errorMessage: String?
    
    @Published var gameItems: [GameItem] = []
    @Published var favoriteItems: [GameItem] = [] // Favorites list for second row
    @Published var selectedGameIndex: Int = 0
    @Published var selectedFavoriteIndex: Int = 0 // Selection index for favorites row
    
    @Published var newTryoutsItems: [GameItem] = []
    @Published var popularInIndiaItems: [GameItem] = []
    @Published var playWithFriendsItems: [GameItem] = []
    @Published var platformsItems: [GameItem] = []

    @Published var selectedNewTryoutsIndex: Int = 0
    @Published var selectedPopularInIndiaIndex: Int = 0
    @Published var selectedPlayWithFriendsIndex: Int = 0
    @Published var selectedPlatformsIndex: Int = 0
    
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
            
            // Fetch main games and categories independently
            // This way, if one fails, others can still succeed
            
            // Fetch main games row (no category filter)
            let games: [Game]?
            do {
                games = try await fetchGamesUseCase.executeForDashboard(category: nil)
            } catch {
                games = nil
                await MainActor.run {
                    // Only show error if we don't have cached data
                    if allGamesCache.isEmpty {
                        errorMessage = error.localizedDescription
                        allGamesCache = []
                        // Keep "All Games" entry so navigation remains available
                        gameItems = [GameItem.allGames]
                        loadFavorites(preserving: selectedFavoriteIndex)
                        selectedGameIndex = clampedSelectionIndex(selectedGameIndex, upperBound: gameItems.count)
                    }
                }
            }
            
            // Update main games first (if fetch succeeded)
            if let games = games {
                await MainActor.run {
                    // Check if data actually changed
                    let gamesChanged = games.map { $0.id } != allGamesCache.map { $0.id }
                    
                    if gamesChanged {
                        let previousGameIndex = selectedGameIndex
                        let previousFavoriteIndex = selectedFavoriteIndex
                        
                        // Cache all games for favorites lookup
                        allGamesCache = games
                        gameItems = games.map { GameItem.game($0) } + [GameItem.allGames]
                        loadFavorites(preserving: previousFavoriteIndex)
                        selectedGameIndex = clampedSelectionIndex(previousGameIndex, upperBound: gameItems.count)
                    }
                    errorMessage = nil
                }
            }
            
            // Fetch category-specific games with caching (similar to main games)
            // Step 1: Load from cache immediately for each category
            let cachedNewTryouts = try? await fetchGamesUseCase.executeCachedForCategory(category: "New Tryouts")
            let cachedPopularInIndia = try? await fetchGamesUseCase.executeCachedForCategory(category: "Popular in India Today")
            let cachedPlayWithFriends = try? await fetchGamesUseCase.executeCachedForCategory(category: "Play with Friends")
            let cachedPlatforms = try? await fetchGamesUseCase.executeCachedForCategory(category: "Platforms")
            
            // Display cached data immediately if available
            await MainActor.run {
                if let cached = cachedNewTryouts, !cached.isEmpty {
                    newTryoutsItems = cached.map { GameItem.game($0) }
                }
                if let cached = cachedPopularInIndia, !cached.isEmpty {
                    popularInIndiaItems = cached.map { GameItem.game($0) }
                }
                if let cached = cachedPlayWithFriends, !cached.isEmpty {
                    playWithFriendsItems = cached.map { GameItem.game($0) }
                }
                if let cached = cachedPlatforms, !cached.isEmpty {
                    platformsItems = cached.map { GameItem.game($0) }
                }
            }
            
            // Step 2: Refresh from API in background with page size 50
            let categoryPageSize = 50
            
            // Fetch all categories in parallel and update UI incrementally as each completes
            // Use TaskGroup to handle parallel execution properly
            await withTaskGroup(of: Void.self) { group in
                // New Tryouts
                group.addTask {
                    if let result = try? await self.fetchGamesUseCase.execute(
                        pageNumber: 0,
                        pageSize: categoryPageSize,
                        sortBy: Constants.API.defaultSortBy,
                        sortOrder: Constants.API.defaultSortOrder,
                        search: nil,
                        category: "New Tryouts"
                    ) {
                        await MainActor.run {
                            let previousIndex = self.selectedNewTryoutsIndex
                            self.newTryoutsItems = result.games.map { GameItem.game($0) }
                            self.selectedNewTryoutsIndex = self.clampedSelectionIndex(previousIndex, upperBound: self.newTryoutsItems.count)
                        }
                    }
                }
                
                // Popular in India Today
                group.addTask {
                    if let result = try? await self.fetchGamesUseCase.execute(
                        pageNumber: 0,
                        pageSize: categoryPageSize,
                        sortBy: Constants.API.defaultSortBy,
                        sortOrder: Constants.API.defaultSortOrder,
                        search: nil,
                        category: "Popular in India Today"
                    ) {
                        await MainActor.run {
                            let previousIndex = self.selectedPopularInIndiaIndex
                            self.popularInIndiaItems = result.games.map { GameItem.game($0) }
                            self.selectedPopularInIndiaIndex = self.clampedSelectionIndex(previousIndex, upperBound: self.popularInIndiaItems.count)
                        }
                    }
                }
                
                // Play with Friends
                group.addTask {
                    if let result = try? await self.fetchGamesUseCase.execute(
                        pageNumber: 0,
                        pageSize: categoryPageSize,
                        sortBy: Constants.API.defaultSortBy,
                        sortOrder: Constants.API.defaultSortOrder,
                        search: nil,
                        category: "Play with Friends"
                    ) {
                        await MainActor.run {
                            let previousIndex = self.selectedPlayWithFriendsIndex
                            self.playWithFriendsItems = result.games.map { GameItem.game($0) }
                            self.selectedPlayWithFriendsIndex = self.clampedSelectionIndex(previousIndex, upperBound: self.playWithFriendsItems.count)
                        }
                    }
                }
                
                // Platforms
                group.addTask {
                    if let result = try? await self.fetchGamesUseCase.execute(
                        pageNumber: 0,
                        pageSize: categoryPageSize,
                        sortBy: Constants.API.defaultSortBy,
                        sortOrder: Constants.API.defaultSortOrder,
                        search: nil,
                        category: "Platforms"
                    ) {
                        await MainActor.run {
                            let previousIndex = self.selectedPlatformsIndex
                            self.platformsItems = result.games.map { GameItem.game($0) }
                            self.selectedPlatformsIndex = self.clampedSelectionIndex(previousIndex, upperBound: self.platformsItems.count)
                        }
                    }
                }
            }
            
            await MainActor.run {
                isLoading = false
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
    func toggleFavoriteForCurrentGame(inRow rowIndex: Int) -> Bool?
    {
        let game: Game?
        
        switch rowIndex
        {
        case 0:
            // Games row
            guard let selectedItem = selectedItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        case 1:
            // Favorites row
            guard let selectedItem = selectedFavoriteItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        case 2:
            // New Tryouts row
            guard let selectedItem = selectedNewTryoutItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        case 3:
            // Popular in India row
            guard let selectedItem = selectedPopularInIndiaItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        case 4:
            // Play with Friends row
            guard let selectedItem = selectedPlayWithFriendsItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        case 5:
            // Platforms row
            guard let selectedItem = selectedPlatformsItem,
                  case .game(let g) = selectedItem else {
                return nil
            }
            game = g
        default:
            return nil
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
    
    //added from here
    var selectedNewTryoutItem: GameItem? {
        guard selectedNewTryoutsIndex >= 0 && selectedNewTryoutsIndex < newTryoutsItems.count else {
            return nil
        }
        return newTryoutsItems[selectedNewTryoutsIndex]
    }

    var selectedPopularInIndiaItem: GameItem? {
        guard selectedPopularInIndiaIndex >= 0 && selectedPopularInIndiaIndex < popularInIndiaItems.count else {
            return nil
        }
        return popularInIndiaItems[selectedPopularInIndiaIndex]
    }

    var selectedPlayWithFriendsItem: GameItem? {
        guard selectedPlayWithFriendsIndex >= 0 && selectedPlayWithFriendsIndex < playWithFriendsItems.count else {
            return nil
        }
        return playWithFriendsItems[selectedPlayWithFriendsIndex]
    }

    var selectedPlatformsItem: GameItem? {
        guard selectedPlatformsIndex >= 0 && selectedPlatformsIndex < platformsItems.count else {
            return nil
        }
        return platformsItems[selectedPlatformsIndex]
    }
    // to here for new category
    
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
    

    func selectNewTryout(at index: Int) {
        guard index >= 0 && index < newTryoutsItems.count else { return }
        selectedNewTryoutsIndex = index
    }

    func selectPopularInIndia(at index: Int) {
        guard index >= 0 && index < popularInIndiaItems.count else { return }
        selectedPopularInIndiaIndex = index
    }

    func selectPlayWithFriends(at index: Int) {
        guard index >= 0 && index < playWithFriendsItems.count else { return }
        selectedPlayWithFriendsIndex = index
    }

    func selectPlatforms(at index: Int) {
        guard index >= 0 && index < platformsItems.count else { return }
        selectedPlatformsIndex = index
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

