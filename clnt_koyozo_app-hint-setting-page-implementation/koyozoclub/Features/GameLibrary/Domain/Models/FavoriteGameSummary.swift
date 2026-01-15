//
//  FavoriteGameSummary.swift
//
import Foundation

/// Lightweight snapshot for rendering and launching favorite games without full catalog fetch
struct FavoriteGameSummary: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let thumbnailURL: String?
    let backgroundURL: String?
    let description: String?
    let launchURL: String?
    let appStoreID: String
    let rating: Double?
    
    init(
        id: String,
        title: String,
        thumbnailURL: String?,
        backgroundURL: String?,
        description: String?,
        launchURL: String?,
        appStoreID: String,
        rating: Double?
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
    
    init(game: Game) {
        self.init(
            id: game.id,
            title: game.title,
            thumbnailURL: game.thumbnailURL,
            backgroundURL: game.backgroundURL,
            description: game.description,
            launchURL: game.launchURL,
            appStoreID: game.appStoreID,
            rating: game.rating
        )
    }
    
    /// Convert the summary back to a domain `Game`
    func asGame() -> Game {
        Game(
            id: id,
            title: title,
            thumbnailURL: thumbnailURL,
            backgroundURL: backgroundURL,
            description: description,
            launchURL: launchURL,
            appStoreID: appStoreID,
            rating: rating
        )
    }
}
