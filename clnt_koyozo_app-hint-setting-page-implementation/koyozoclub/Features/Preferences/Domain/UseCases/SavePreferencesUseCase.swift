//
//  SavePreferencesUseCase.swift
import Foundation

protocol SavePreferencesUseCaseProtocol {
    func execute(preferences: UserPreferences) async throws
}

final class SavePreferencesUseCase: SavePreferencesUseCaseProtocol {
    private let preferencesRepository: PreferencesRepository
    
    init(preferencesRepository: PreferencesRepository? = nil) {
        self.preferencesRepository = preferencesRepository ?? PreferencesRepository()
    }
    
    func execute(preferences: UserPreferences) async throws {
        try await preferencesRepository.savePreferences(preferences)
    }
}

