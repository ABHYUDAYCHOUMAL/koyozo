//
//  Validators.swift
import Foundation

struct Validators {
    // Add validation functions here
    
    static func isValidEmail(_ email: String) -> Bool {
        // Email validation logic
        return !email.isEmpty && email.contains("@")
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        // Password validation: at least 8 characters and 1 number
        return password.count >= 8 && hasNumber(password)
    }
    
    // Password requirement validators
    static func hasMinimumCharacters(_ password: String, count: Int = 8) -> Bool {
        return password.count >= count
    }
    
    static func hasNumber(_ password: String) -> Bool {
        return password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil
    }
}

