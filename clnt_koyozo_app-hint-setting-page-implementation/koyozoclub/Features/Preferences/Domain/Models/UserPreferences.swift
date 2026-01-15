//
//  UserPreferences.swift
import Foundation

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var autoLaunchEnabled: Bool = false
    var vibrationEnabled: Bool = true
    var sensitivity: Double = 50.0
    var theme: String = "system"
    
    enum CodingKeys: String, CodingKey {
        case notificationsEnabled = "notifications_enabled"
        case autoLaunchEnabled = "auto_launch_enabled"
        case vibrationEnabled = "vibration_enabled"
        case sensitivity
        case theme
    }
}

