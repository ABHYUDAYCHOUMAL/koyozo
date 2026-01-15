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
        search: String?
    ) async throws -> PaginatedGamesResult
    
    /// Convenience method for dashboard - fetches top games by rating
    func executeForDashboard() async throws -> [Game]
    
    /// Fetch cached games for dashboard (instant load)
    func executeCachedForDashboard() async throws -> [Game]
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
    /// - Returns: PaginatedGamesResult with games and metadata
    func execute(
        pageNumber: Int = 0,
        pageSize: Int = Constants.API.defaultPageSize,
        sortBy: String = Constants.API.defaultSortBy,
        sortOrder: String = Constants.API.defaultSortOrder,
        search: String? = nil
    ) async throws -> PaginatedGamesResult {
        return try await gameRepository.fetchGames(
            pageNumber: pageNumber,
            pageSize: pageSize,
            sortBy: sortBy,
            sortOrder: sortOrder,
            search: search
        )
    }
    
    /// Convenience method for Dashboard view
    /// Fetches top games sorted by rating (descending)
    /// - Returns: Array of top games for dashboard display
    func executeForDashboard() async throws -> [Game] {
        let result = try await execute(
            pageNumber: 0,
            pageSize: Constants.API.dashboardGameCount,
            sortBy: Constants.API.defaultSortBy,
            sortOrder: Constants.API.defaultSortOrder,
            search: nil
        )
        return result.games
    }
    
    /// Fetch cached games for dashboard (instant load, no network call)
    /// - Returns: Array of cached games, empty if no cache exists
    func executeCachedForDashboard() async throws -> [Game] {
        return try await gameRepository.fetchCachedGames()
    }
}

