//
//  GamingStats.swift
import Foundation

struct GamingStats: Codable {
    let gamesPlayed: Int
    let totalPlayTime: Double // in hours
    let favoriteGames: [String] // Game IDs
    let achievements: [String]
    
    enum CodingKeys: String, CodingKey {
        case gamesPlayed = "games_played"
        case totalPlayTime = "total_play_time"
        case favoriteGames = "favorite_games"
        case achievements
    }
}

