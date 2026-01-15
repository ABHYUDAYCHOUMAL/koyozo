//
//  GameMapper.swift
import Foundation

/// Maps between Data layer DTOs and Domain layer models
struct GameMapper {
    
    /// Converts a GameDTO from API to a Game domain model
    /// - Parameter dto: The data transfer object from API response
    /// - Returns: A Game domain model for use in the app
    static func toDomain(from dto: GameDTO) -> Game {
        Game(
            id: dto.id,
            title: dto.title,
            thumbnailURL: dto.thumbnailURL,
            backgroundURL: dto.backgroundURL,
            description: dto.description,
            launchURL: dto.launchURL,
            appStoreID: dto.appStoreID,
            rating: dto.rating
        )
    }
    
    /// Converts an array of GameDTOs to an array of Game domain models
    /// - Parameter dtos: Array of data transfer objects from API response
    /// - Returns: Array of Game domain models
    static func toDomain(from dtos: [GameDTO]) -> [Game] {
        dtos.map { toDomain(from: $0) }
    }
}

