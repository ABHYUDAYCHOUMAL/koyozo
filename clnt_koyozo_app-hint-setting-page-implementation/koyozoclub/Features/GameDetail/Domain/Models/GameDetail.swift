//
//  GameDetail.swift
import Foundation

struct GameDetail: Codable {
    let game: Game
    let screenshots: [GameScreenshot]
    let description: String
    let releaseDate: Date?
    let developer: String?
    
    enum CodingKeys: String, CodingKey {
        case game
        case screenshots
        case description
        case releaseDate = "release_date"
        case developer
    }
}

