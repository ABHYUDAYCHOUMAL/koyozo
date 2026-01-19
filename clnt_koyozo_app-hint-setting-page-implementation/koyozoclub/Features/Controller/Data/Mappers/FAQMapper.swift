//
//  FAQMapper.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 18/01/26.
//

//  FAQMapper.swift
import Foundation

struct FAQMapper {
    
    /// Converts FAQItemDTO from API to FAQItem domain model
    static func toDomain(from dto: FAQItemDTO) -> FAQItem {
        // Parse the answer to determine the type
        let answer = parseAnswer(dto.answer)
        
        return FAQItem(
            question: dto.question,
            answer: answer
        )
    }
    
    /// Converts array of FAQItemDTOs to array of FAQItems
    static func toDomain(from dtos: [FAQItemDTO]) -> [FAQItem] {
        dtos.map { toDomain(from: $0) }
    }
    
    /// Parse answer string to determine FAQAnswer type
    /// The API returns plain text, so we'll use .text for now
    /// You can enhance this later to support steps, tables, etc.
    private static func parseAnswer(_ answer: String) -> FAQAnswer {
        // Check if answer contains numbered steps (1. 2. 3. etc.)
        if answer.contains("\n1.") || answer.contains("\n2.") {
            let steps = answer
                .components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            return .steps(steps)
        }
        
        // Default to text
        return .text(answer)
    }
}
