//
//  PasswordRequirement.swift
import Foundation

struct PasswordRequirement: Hashable {
    let text: String
    var isMet: Bool
    var showError: Bool
    
    init(text: String, isMet: Bool = false, showError: Bool = false) {
        self.text = text
        self.isMet = isMet
        self.showError = showError
    }
}

