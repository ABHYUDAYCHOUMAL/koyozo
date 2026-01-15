//
//  RegisterRequestDTO.swift
import Foundation

struct RegisterRequestDTO: Codable {
    let email: String
    let password: String
    let username: String
    let DOB: String
    let gender: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case username
        case DOB
        case gender
    }
}

