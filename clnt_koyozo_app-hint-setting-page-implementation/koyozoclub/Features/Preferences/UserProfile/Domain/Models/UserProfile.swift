//
//  UserProfile.swift
import Foundation

struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String?
    let bio: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profileImageURL = "profile_image_url"
        case bio
        case createdAt = "created_at"
    }
}

