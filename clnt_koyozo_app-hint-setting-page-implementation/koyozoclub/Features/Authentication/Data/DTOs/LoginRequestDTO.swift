//
//  LoginRequestDTO.swift
import Foundation

struct LoginRequestDTO: Codable {
    let email: String
    let password: String?
    
    init(email: String, password: String? = nil) {
        self.email = email
        self.password = password
    }
}

