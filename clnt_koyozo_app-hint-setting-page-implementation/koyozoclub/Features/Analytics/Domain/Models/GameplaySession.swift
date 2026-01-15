//
//  GameplaySession.swift
import Foundation

struct GameplaySession: Codable {
    let id: String
    let gameId: String
    let userId: String
    let startTime: Date
    let endTime: Date?
    let duration: TimeInterval
    let controllerType: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gameId = "game_id"
        case userId = "user_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case duration
        case controllerType = "controller_type"
    }
}

