//
//  ResetPasswordRequestDTO.swift
import Foundation

struct ResetPasswordRequestDTO: Codable {
    let email: String
    let newPassword: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case newPassword
    }
}

