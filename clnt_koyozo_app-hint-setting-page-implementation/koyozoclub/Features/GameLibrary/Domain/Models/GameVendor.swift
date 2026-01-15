//
//  GameVendor.swift
import Foundation

struct GameVendor: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let logoURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoURL = "logo_url"
    }
}

