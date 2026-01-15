//
//  SearchGamesUseCase.swift
import Foundation

// MARK: - Protocol

protocol SearchGamesUseCaseProtocol {
    /// Search games using server-side search with pagination
    func execute(
        query: String,
        pageNumber: Int,
        pageSize: Int
    ) async throws -> PaginatedGamesResult
}

// MARK: - Implementation

final class SearchGamesUseCase: SearchGamesUseCaseProtocol {
    private let gameRepository: GameRepository
    
    init(gameRepository: GameRepository? = nil) {
        self.gameRepository = gameRepository ?? GameRepository()
    }
    
    /// Execute server-side search with pagination
    /// - Parameters:
    ///   - query: Search term (searches in title and description)
    ///   - pageNumber: Page number (0-indexed)
    ///   - pageSize: Number of results per page
    /// - Returns: PaginatedGamesResult with matching games
    func execute(
        query: String,
        pageNumber: Int = 0,
        pageSize: Int = Constants.API.defaultPageSize
    ) async throws -> PaginatedGamesResult {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Return empty result for empty query
            return PaginatedGamesResult(
                games: [],
                pageNumber: 0,
                pageSize: pageSize,
                totalPages: 0,
                totalItems: 0
            )
        }
        
        // Use server-side search via repository
        // Sort by rating descending for best results first
        return try await gameRepository.fetchGames(
            pageNumber: pageNumber,
            pageSize: pageSize,
            sortBy: Constants.API.defaultSortBy,
            sortOrder: Constants.API.defaultSortOrder,
            search: query
        )
    }
}

