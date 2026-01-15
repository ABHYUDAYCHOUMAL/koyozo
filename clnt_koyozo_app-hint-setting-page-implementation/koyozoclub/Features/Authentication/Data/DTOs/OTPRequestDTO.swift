//
//  OTPRequestDTO.swift
import Foundation

struct SendOTPRequestDTO: Codable {
    let email: String
    let type: Int // 1 for registration, 2 for forgot password
}

struct VerifyOTPRequestDTO: Codable {
    let email: String
    let otp: String
    let type: Int
}

struct OTPResponseDTO: Codable {
    let status: Int
    let hasError: Bool
    let error: [String]
    let data: OTPResponseDataDTO
    
    enum CodingKeys: String, CodingKey {
        case status
        case hasError
        case error
        case data
    }
}

struct OTPResponseDataDTO: Codable {
    let message: String
}

