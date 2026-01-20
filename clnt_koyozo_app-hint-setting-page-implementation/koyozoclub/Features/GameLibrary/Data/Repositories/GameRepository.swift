//
//  GameRepository.swift
import Foundation

// MARK: - Paginated Games Result

/// Result structure containing games with pagination metadata
struct PaginatedGamesResult {
    let games: [Game]
    let pageNumber: Int
    let pageSize: Int
    let totalPages: Int
    let totalItems: Int
    
    /// Whether there are more pages to load
    var hasMorePages: Bool {
        return pageNumber < totalPages - 1
    }
}

// MARK: - Protocol

protocol GameRepositoryProtocol {
    /// Fetch games with pagination, sorting, optional search, and optional category filter
    func fetchGames(
        pageNumber: Int,
        pageSize: Int,
        sortBy: String,
        sortOrder: String,
        search: String?,
        category: String?
    ) async throws -> PaginatedGamesResult
    
    /// Fetch recent games from local storage
    func fetchRecentGames() async throws -> [Game]
    
    /// Fetch game categories
    func fetchCategories() async throws -> [GameCategory]
    
    /// Fetch cached games for dashboard (instant load)
    func fetchCachedGames() async throws -> [Game]
    
    /// Fetch cached games for a category (instant load)
    func fetchCachedCategoryGames(category: String) async throws -> [Game]
    
    /// Fetch a single game by ID
    func fetchGame(by id: String) async throws -> Game
}

// MARK: - Implementation

final class GameRepository: GameRepositoryProtocol {
    private let remoteDataSource: GameRemoteDataSource
    private let localDataSource: GameLocalDataSource
    
    init(
        remoteDataSource: GameRemoteDataSource? = nil,
        localDataSource: GameLocalDataSource? = nil
    ) {
        self.remoteDataSource = remoteDataSource ?? GameRemoteDataSource()
        self.localDataSource = localDataSource ?? GameLocalDataSource()
    }
    
    /// Fetch games with pagination, sorting, optional search, and optional category filter
    /// - Parameters:
    ///   - pageNumber: Page number (0-indexed)
    ///   - pageSize: Number of games per page
    ///   - sortBy: Field to sort by (rating, title, createdAt, updatedAt)
    ///   - sortOrder: Sort direction (asc or desc)
    ///   - search: Optional search term
    ///   - category: Optional category name to filter games
    /// - Returns: PaginatedGamesResult with games and pagination metadata
    func fetchGames(
        pageNumber: Int,
        pageSize: Int,
        sortBy: String,
        sortOrder: String,
        search: String?,
        category: String? = nil
    ) async throws -> PaginatedGamesResult {
        // For dashboard queries (first page, no search, no category), try cache first
        let isDashboardQuery = pageNumber == 0 && search == nil && category == nil
        
        // Fetch from remote API
        let response = try await remoteDataSource.fetchGames(
            pageNumber: pageNumber,
            pageSize: pageSize,
            sortBy: sortBy,
            sortOrder: sortOrder,
            search: search,
            category: category
        )
        
        // Convert DTOs to domain models
        let games = GameMapper.toDomain(from: response.games)
        
        // Cache first page results locally for offline access
        if isDashboardQuery {
            Task {
                try? await localDataSource.saveGames(games)
            }
        } else if let category = category, pageNumber == 0 && search == nil {
            // Cache category games for offline access
            Task {
                try? await localDataSource.saveCategoryGames(games, category: category)
            }
        }
        
        // Handle pagination: use API response if available, otherwise calculate from request
        let pagination: PaginationDTO
        if let apiPagination = response.pagination {
            pagination = apiPagination
        } else {
            // If API doesn't return pagination, calculate it from the response
            // If we got fewer games than requested, this is the last page
            let hasMorePages = games.count >= pageSize
            pagination = PaginationDTO(
                pageNumber: pageNumber,
                pageSize: pageSize,
                totalPages: hasMorePages ? pageNumber + 2 : pageNumber + 1,
                totalItems: (pageNumber * pageSize) + games.count
            )
        }
        
        return PaginatedGamesResult(
            games: games,
            pageNumber: pagination.pageNumber,
            pageSize: pagination.pageSize,
            totalPages: pagination.totalPages,
            totalItems: pagination.totalItems
        )
    }
    
    /// Fetch recent games from local storage
    func fetchRecentGames() async throws -> [Game] {
        return try await localDataSource.fetchRecentGames()
    }
    
    /// Fetch game categories (not currently supported by API)
    func fetchCategories() async throws -> [GameCategory] {
        return try await remoteDataSource.fetchCategories()
    }
    
    /// Fetch games from cache (for dashboard)
    func fetchCachedGames() async throws -> [Game] {
        return try await localDataSource.fetchGames()
    }
    
    /// Fetch cached games for a category
    func fetchCachedCategoryGames(category: String) async throws -> [Game] {
        return try await localDataSource.fetchCategoryGames(category: category)
    }
    
    /// Fetch a single game by ID
    func fetchGame(by id: String) async throws -> Game {
        // Try local cache first
        if let game = try? await localDataSource.fetchGame(by: id) {
            return game
        }
        
        // Fetch from remote
        let game = try await remoteDataSource.fetchGame(by: id)
        try await localDataSource.saveGame(game)
        return game
    }
}

