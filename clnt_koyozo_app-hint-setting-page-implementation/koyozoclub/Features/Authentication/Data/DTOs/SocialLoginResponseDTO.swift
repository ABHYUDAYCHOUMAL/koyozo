//
//  SocialLoginResponseDTO.swift
import Foundation

// Firebase ResponseDto structure
struct FirebaseResponseDTO<T: Codable>: Codable {
    let status: Int
    let hasError: Bool
    let error: [String]
    let data: T
    
    enum CodingKeys: String, CodingKey {
        case status
        case hasError
        case error
        case data
    }
}

struct SocialLoginResponseDataDTO: Codable {
    let token: String
}

