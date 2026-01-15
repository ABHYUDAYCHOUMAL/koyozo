//
//  Game.swift
import Foundation

/// Domain model representing a Game
/// This is the business/domain layer model used throughout the app
struct Game: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let thumbnailURL: String?
    let backgroundURL: String?
    let description: String?
    let launchURL: String?
    let appStoreID: String
    let rating: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case thumbnailURL = "thumbnail_url"
        case backgroundURL = "background_url"
        case description
        case launchURL = "launch_url"
        case appStoreID = "app_store_id"
        case rating
    }
    
    /// Convenience initializer for creating Game with all parameters
    init(
        id: String,
        title: String,
        thumbnailURL: String?,
        backgroundURL: String?,
        description: String?,
        launchURL: String?,
        appStoreID: String,
        rating: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.backgroundURL = backgroundURL
        self.description = description
        self.launchURL = launchURL
        self.appStoreID = appStoreID
        self.rating = rating
    }
}

