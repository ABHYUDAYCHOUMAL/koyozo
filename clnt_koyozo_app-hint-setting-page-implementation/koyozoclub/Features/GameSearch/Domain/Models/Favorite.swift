//
//  Favorite.swift
import Foundation

struct Favorite: Codable, Identifiable {
    let id: String
    let gameId: String
    let userId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case gameId = "game_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}

