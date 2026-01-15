//
//  FavoriteRemoteDataSource.swift
import Foundation

protocol FavoriteRemoteDataSourceProtocol {
    func fetchFavorites() async throws -> [Game]
    func addFavorite(gameId: String) async throws
    func removeFavorite(gameId: String) async throws
}

final class FavoriteRemoteDataSource: FavoriteRemoteDataSourceProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? APIClient()
    }
    
    func fetchFavorites() async throws -> [Game] {
        // Implement API call
        throw AppError.unknown
    }
    
    func addFavorite(gameId: String) async throws {
        // Implement API call
        throw AppError.unknown
    }
    
    func removeFavorite(gameId: String) async throws {
        // Implement API call
        throw AppError.unknown
    }
}

