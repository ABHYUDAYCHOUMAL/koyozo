//
//  GameScreenshot.swift
import Foundation

struct GameScreenshot: Codable, Identifiable {
    let id: String
    let imageURL: String
    let thumbnailURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case thumbnailURL = "thumbnail_url"
    }
}

