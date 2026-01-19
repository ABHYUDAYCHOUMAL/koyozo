//
//  FAQResponseDTO.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 18/01/26.
//

//  FAQResponseDTO.swift
import Foundation

/// Root response from FAQs API
struct FAQResponseDTO: Codable {
    let status: Int
    let hasError: Bool
    let error: [String]?
    let data: FAQDataDTO?
}

/// Data container for FAQs
struct FAQDataDTO: Codable {
    let faqs: [FAQItemDTO]
}

/// Individual FAQ item from API
struct FAQItemDTO: Codable {
    let id: String
    let question: String
    let answer: String
    let category: String?
    let createdAt: FirestoreTimestampDTO?
    let updatedAt: FirestoreTimestampDTO?
    
    enum CodingKeys: String, CodingKey {
        case id
        case question
        case answer
        case category
        case createdAt
        case updatedAt
    }
}
