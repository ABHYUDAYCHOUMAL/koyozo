//
//  CheckEmailResponseDTO.swift
import Foundation

struct CheckEmailResponseDataDTO: Codable {
    let email: String
    let exists: Bool
}

