//
//  AppErrors.swift
import Foundation

enum AppError: LocalizedError {
    case unknown
    case networkError(String)
    case invalidData
    case authenticationFailed
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "An unknown error occurred"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidData:
            return "Invalid data received"
        case .authenticationFailed:
            return "Authentication failed"
        }
    }
}

