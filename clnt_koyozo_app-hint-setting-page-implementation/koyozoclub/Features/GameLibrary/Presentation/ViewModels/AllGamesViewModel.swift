//
//  AllGamesViewModel.swift
import Foundation
import SwiftUI
import Combine

class AllGamesViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    @Published var allGames: [Game] = []
    @Published var searchText: String = ""
    @Published var selectedGameIndex: Int = 0
    @Published var isLaunching: Bool = false
    @Published var favoriteUpdateTrigger: Bool = false // Triggers UI update when favorites change
    @Published var isLoadingMore: Bool = false
    
    private let fetchGamesUseCase: FetchGamesUseCase
    private let launchGameUseCase: LaunchGameUseCase
    private let favoritesManager = FavoritesManager.shared
    
    // Pagination state
    private var currentPage: Int = 0
    private var totalPages: Int = 1
    private var currentSearchTerm: String? = nil
    private var isFetching: Bool = false
    private var searchDebounceWorkItem: DispatchWorkItem?
    
    // Computed property for filtered games
    var filteredGames: [Game] {
        return allGames
    }
    
    var selectedGame: Game? {
        guard selectedGameIndex >= 0 && selectedGameIndex < filteredGames.count else {
            return nil
        }
        return filteredGames[selectedGameIndex]
    }
    
    /// Trigger a debounced server-side search
    func applySearch() {
        searchDebounceWorkItem?.cancel()
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.currentSearchTerm = term.isEmpty ? nil : term
            self.resetPagination()
            self.fetchAllGames(reset: true)
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
    
    func selectGame(at index: Int) {
        guard index >= 0 && index < filteredGames.count else { return }
        selectedGameIndex = index
    }
    
    func moveFocusLeft() {
        let newIndex = max(0, selectedGameIndex - 1)
        selectGame(at: newIndex)
    }
    
    func moveFocusRight() {
        let newIndex = min(filteredGames.count - 1, selectedGameIndex + 1)
        selectGame(at: newIndex)
    }
    
    func moveFocusUp() {
        let columns = 5
        let newIndex = max(0, selectedGameIndex - columns)
        selectGame(at: newIndex)
    }
    
    func moveFocusDown() {
        let columns = 5
        let newIndex = min(filteredGames.count - 1, selectedGameIndex + columns)
        selectGame(at: newIndex)
    }
    
    /// Keep the controller selection within the filtered results.
    func syncSelectionWithFilteredGames() {
        let count = filteredGames.count
        
        guard count > 0 else {
            selectedGameIndex = 0
            return
        }
        
        if count == 1 {
            selectedGameIndex = 0
            return
        }
        
        if selectedGameIndex >= count {
            selectedGameIndex = count - 1
        } else if selectedGameIndex < 0 {
            selectedGameIndex = 0
        }
    }
    
    init(
        fetchGamesUseCase: FetchGamesUseCase? = nil,
        launchGameUseCase: LaunchGameUseCase? = nil
    ) {
        self.fetchGamesUseCase = fetchGamesUseCase ?? FetchGamesUseCase()
        self.launchGameUseCase = launchGameUseCase ?? LaunchGameUseCase()
    }
    
    /// Handle pagination trigger when a game appears
    func loadMoreIfNeeded(currentGame: Game) {
        guard !isFetching, currentPage < totalPages else { return }
        guard let index = filteredGames.firstIndex(where: { $0.id == currentGame.id }) else { return }
        let thresholdIndex = filteredGames.count - 3
        if index >= thresholdIndex {
            fetchAllGames(reset: false)
        }
    }
    
    func launchSelectedGame() {
        guard let game = selectedGame else { return }
        isLaunching = true
        launchGameUseCase.execute(game: game)
        
        // Reset launching state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLaunching = false
        }
    }
    
    /// Fetch initial or next page of games
    func fetchAllGames(reset: Bool = false) {
        Task {
            if isFetching { return }
            isFetching = true
            
            if reset {
                await MainActor.run {
                    isLoading = true
                    isLoadingMore = false
                    errorMessage = nil
                    allGames = []
                    selectedGameIndex = 0
                    currentPage = 0
                    totalPages = 1
                }
            } else {
                await MainActor.run {
                    isLoadingMore = true
                }
            }
            
            do {
                let result = try await fetchGamesUseCase.execute(
                    pageNumber: currentPage,
                    pageSize: Constants.API.defaultPageSize,
                    sortBy: Constants.API.defaultSortBy,
                    sortOrder: Constants.API.defaultSortOrder,
                    search: currentSearchTerm
                )
                
                await MainActor.run {
                    allGames.append(contentsOf: result.games)
                    currentPage = result.pageNumber + 1
                    totalPages = result.totalPages
                    isLoading = false
                    isLoadingMore = false
                    errorMessage = nil
                    syncSelectionWithFilteredGames()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    isLoadingMore = false
                }
            }
            
            isFetching = false
        }
    }
    
    private func resetPagination() {
        currentPage = 0
        totalPages = 1
        allGames = []
        selectedGameIndex = 0
    }
    
    // MARK: - Favorites
    
    /// Toggle favorite for the currently selected game
    @discardableResult
    func toggleFavoriteForSelectedGame() -> Bool? {
        guard let game = selectedGame else { return nil }
        let isFavorited = favoritesManager.toggleFavorite(game: game)
        favoriteUpdateTrigger.toggle() // Trigger UI update
        return isFavorited
    }
    
    /// Check if a game is favorited
    func isFavorite(gameId: String) -> Bool {
        return favoritesManager.isFavorite(gameId: gameId)
    }
    
    /// Check if the currently selected game is a favorite
    var isSelectedGameFavorite: Bool {
        guard let game = selectedGame else { return false }
        return isFavorite(gameId: game.id)
    }
}

