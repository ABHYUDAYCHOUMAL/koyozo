//
//  SocialLoginRequestDTO.swift
import Foundation

struct SocialLoginRequestDTO: Codable {
    let email: String
    let username: String?
    let type: String
    let gender: String?
    let DOB: String?
    
    enum CodingKeys: String, CodingKey {
        case email
        case username
        case type
        case gender
        case DOB
    }
}

