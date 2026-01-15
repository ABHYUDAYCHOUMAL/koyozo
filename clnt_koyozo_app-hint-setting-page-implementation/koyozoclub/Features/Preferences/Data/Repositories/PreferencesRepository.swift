//
//  PreferencesRepository.swift
import Foundation

protocol PreferencesRepositoryProtocol {
    func savePreferences(_ preferences: UserPreferences) async throws
    func fetchPreferences() async throws -> UserPreferences
}

final class PreferencesRepository: PreferencesRepositoryProtocol {
    private let userDefaultsManager: UserDefaultsManager
    
    init(userDefaultsManager: UserDefaultsManager? = nil) {
        self.userDefaultsManager = userDefaultsManager ?? UserDefaultsManager()
    }
    
    func savePreferences(_ preferences: UserPreferences) async throws {
        try await userDefaultsManager.save(preferences, forKey: "user_preferences")
    }
    
    func fetchPreferences() async throws -> UserPreferences {
        return try await userDefaultsManager.fetch(UserPreferences.self, forKey: "user_preferences") 
            ?? UserPreferences()
    }
}

