//
//  GameListResponseDTO.swift
import Foundation

// MARK: - iOS Games API Response
// Response format as defined in IOS_GAMES_API.md

/// Root response wrapper for iOS Games API
struct iOSGamesResponseDTO: Codable {
    let statusCode: Int
    let hasError: Bool
    let errors: [String]?
    let data: iOSGamesDataDTO?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case hasError
        case errors = "error"
        case data
    }
    
    var normalizedErrors: [String] {
        errors ?? []
    }
}

/// Data container for games list response
struct iOSGamesDataDTO: Codable {
    let games: [GameDTO]
    let pagination: PaginationDTO?
    let sort: SortDTO?
}

/// Pagination metadata from API response
struct PaginationDTO: Codable {
    let pageNumber: Int
    let pageSize: Int
    let totalPages: Int
    let totalItems: Int
}

/// Sort metadata from API response
struct SortDTO: Codable {
    let sortBy: String
    let sortOrder: String
}

// MARK: - Single Game Response

/// Response wrapper for single game endpoint
struct iOSGameResponseDTO: Codable {
    let statusCode: Int
    let hasError: Bool
    let errors: [String]?
    let data: GameDTO?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case hasError
        case errors = "error"
        case data
    }
    
    var normalizedErrors: [String] {
        errors ?? []
    }
}
