//
//  AuthResponseDTO.swift
import Foundation

struct AuthResponseDTO: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let user: UserDTO
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
    }
}

struct UserDTO: Codable {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case profileImageURL = "profile_image_url"
        case createdAt = "created_at"
    }
}

