//
//  AuthToken.swift
import Foundation

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

