//
//  LoginResponseDTO.swift
import Foundation

// Firebase ResponseDto structure for login
struct LoginResponseDTO: Codable {
    let status: Int
    let hasError: Bool
    let error: [String]
    let data: LoginResponseDataDTO?
    let isUserExist: Bool?
    
    enum CodingKeys: String, CodingKey {
        case status
        case hasError
        case error
        case data
        case isUserExist
    }
}

struct LoginResponseDataDTO: Codable {
    let token: String?
    let message: String?
}

