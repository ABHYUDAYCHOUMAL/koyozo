//
//  GameCategory.swift
import Foundation

struct GameCategory: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let iconURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconURL = "icon_url"
    }
}

