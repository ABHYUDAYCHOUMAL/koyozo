//
//  FavoriteRepository.swift
import Foundation

protocol FavoriteRepositoryProtocol {
    func fetchFavorites() async throws -> [Game]
    func addFavorite(gameId: String) async throws
    func removeFavorite(gameId: String) async throws
    func isFavorite(gameId: String) async throws -> Bool
}

final class FavoriteRepository: FavoriteRepositoryProtocol {
    private let remoteDataSource: FavoriteRemoteDataSource
    private let localDataSource: FavoriteLocalDataSource
    
    init(
        remoteDataSource: FavoriteRemoteDataSource? = nil,
        localDataSource: FavoriteLocalDataSource? = nil
    ) {
        self.remoteDataSource = remoteDataSource ?? FavoriteRemoteDataSource()
        self.localDataSource = localDataSource ?? FavoriteLocalDataSource()
    }
    
    func fetchFavorites() async throws -> [Game] {
        let games = try await remoteDataSource.fetchFavorites()
        try await localDataSource.saveFavorites(games)
        return games
    }
    
    func addFavorite(gameId: String) async throws {
        try await remoteDataSource.addFavorite(gameId: gameId)
        try await localDataSource.addFavorite(gameId: gameId)
    }
    
    func removeFavorite(gameId: String) async throws {
        try await remoteDataSource.removeFavorite(gameId: gameId)
        try await localDataSource.removeFavorite(gameId: gameId)
    }
    
    func isFavorite(gameId: String) async throws -> Bool {
        return try await localDataSource.isFavorite(gameId: gameId)
    }
}

