//  GameController.swift
import Foundation

struct GameController: Codable, Identifiable {
    let id: String
    let name: String
    let type: ControllerType
    let isConnected: Bool
    let batteryLevel: Int?
    
    enum ControllerType: String, Codable {
        case bluetooth
        case wired
        case mfi // Made for iPhone/iPad
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case isConnected = "is_connected"
        case batteryLevel = "battery_level"
    }
}

