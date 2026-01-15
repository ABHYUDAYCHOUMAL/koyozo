//
//  SettingsViewModel.swift
import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    var preferences: UserPreferences = UserPreferences()
    
    private let savePreferencesUseCase: SavePreferencesUseCase
    private let fetchPreferencesUseCase: FetchPreferencesUseCase
    
    init(
        savePreferencesUseCase: SavePreferencesUseCase? = nil,
        fetchPreferencesUseCase: FetchPreferencesUseCase? = nil
    ) {
        self.savePreferencesUseCase = savePreferencesUseCase ?? SavePreferencesUseCase()
        self.fetchPreferencesUseCase = fetchPreferencesUseCase ?? FetchPreferencesUseCase()
    }
    
    func savePreferences() {
        Task {
            do {
                try await savePreferencesUseCase.execute(preferences: preferences)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetchPreferences() {
        Task {
            isLoading = true
            do {
                preferences = try await fetchPreferencesUseCase.execute()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

