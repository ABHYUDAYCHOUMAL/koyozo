//
//  FetchPreferencesUseCase.swift
import Foundation

protocol FetchPreferencesUseCaseProtocol {
    func execute() async throws -> UserPreferences
}

final class FetchPreferencesUseCase: FetchPreferencesUseCaseProtocol {
    private let preferencesRepository: PreferencesRepository
    
    init(preferencesRepository: PreferencesRepository? = nil) {
        self.preferencesRepository = preferencesRepository ?? PreferencesRepository()
    }
    
    func execute() async throws -> UserPreferences {
        return try await preferencesRepository.fetchPreferences()
    }
}

