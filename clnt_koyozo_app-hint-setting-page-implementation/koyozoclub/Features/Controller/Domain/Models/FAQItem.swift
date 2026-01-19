//
//  FAQItem.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  FAQItem.swift
import Foundation

struct FAQItem: Identifiable, Hashable {
    let id: UUID
    let question: String
    let answer: FAQAnswer
    
    init(question: String, answer: FAQAnswer) {
        self.id = UUID()
        self.question = question
        self.answer = answer
    }
}

enum FAQAnswer: Hashable {
    case text(String)
    case steps([String])
    case stepsWithTable([String], FAQTable?)
    case multiSection([FAQSection])
}

struct FAQSection: Hashable {
    let title: String?
    let items: [String]
}

struct FAQTable: Hashable {
    let headers: [String]
    let rows: [[String]]
}
