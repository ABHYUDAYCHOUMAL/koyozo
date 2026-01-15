//
//  ControllerConfig.swift
import Foundation

struct ControllerConfig: Codable {
    let buttonMapping: [String: String]
    let sensitivity: Double
    let vibrationEnabled: Bool
    
    enum CodingKeys: String, CodingKey {
        case buttonMapping = "button_mapping"
        case sensitivity
        case vibrationEnabled = "vibration_enabled"
    }
}

