//
//  FetchGamesUseCase.swift
import Foundation

// MARK: - Protocol

protocol FetchGamesUseCaseProtocol {
    /// Execute fetch with pagination and sorting
    func execute(
        pageNumber: Int,
        pageSize: Int,
        sortBy: String,
        sortOrder: String,
        search: String?,
        category: String?
    ) async throws -> PaginatedGamesResult
    
    /// Convenience method for dashboard - fetches top games by rating
    /// - Parameter category: Optional category name to filter games (e.g., "New Tryouts")
    func executeForDashboard(category: String?) async throws -> [Game]
    
    /// Fetch cached games for dashboard (instant load)
    func executeCachedForDashboard() async throws -> [Game]
    
    /// Fetch cached games for a category (instant load)
    func executeCachedForCategory(category: String) async throws -> [Game]
}

// MARK: - Implementation

final class FetchGamesUseCase: FetchGamesUseCaseProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    /// Execute fetch with full pagination support
    /// - Parameters:
    ///   - pageNumber: Page number (0-indexed)
    ///   - pageSize: Number of games per page
    ///   - sortBy: Field to sort by
    ///   - sortOrder: Sort direction (asc/desc)
    ///   - search: Optional search term
    ///   - category: Optional category name to filter games
    /// - Returns: PaginatedGamesResult with games and metadata
    func execute(
        pageNumber: Int = 0,
        pageSize: Int = Constants.API.defaultPageSize,
        sortBy: String = Constants.API.defaultSortBy,
        sortOrder: String = Constants.API.defaultSortOrder,
        search: String? = nil,
        category: String? = nil
    ) async throws -> PaginatedGamesResult {
        return try await gameRepository.fetchGames(
            pageNumber: pageNumber,
            pageSize: pageSize,
            sortBy: sortBy,
            sortOrder: sortOrder,
            search: search,
            category: category
        )
    }
    
    /// Convenience method for Dashboard view
    /// Fetches top games sorted by rating (descending), optionally filtered by category
    /// - Parameter category: Optional category name to filter games (e.g., "New Tryouts", "Popular in India Today")
    /// - Returns: Array of top games for dashboard display
    func executeForDashboard(category: String? = nil) async throws -> [Game] {
        let result = try await execute(
            pageNumber: 0,
            pageSize: Constants.API.dashboardGameCount,
            sortBy: Constants.API.defaultSortBy,
            sortOrder: Constants.API.defaultSortOrder,
            search: nil,
            category: category
        )
        return result.games
    }
    
    /// Fetch cached games for dashboard (instant load, no network call)
    /// - Returns: Array of cached games, empty if no cache exists
    func executeCachedForDashboard() async throws -> [Game] {
        return try await gameRepository.fetchCachedGames()
    }
    
    /// Fetch cached games for a category (instant load, no network call)
    /// - Parameter category: Category name (e.g., "New Tryouts")
    /// - Returns: Array of cached games for the category, empty if no cache exists
    func executeCachedForCategory(category: String) async throws -> [Game] {
        return try await gameRepository.fetchCachedCategoryGames(category: category)
    }
}

