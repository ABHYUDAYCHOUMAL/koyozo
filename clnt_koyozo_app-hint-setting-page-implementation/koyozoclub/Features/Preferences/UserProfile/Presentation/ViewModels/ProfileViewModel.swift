//
//  ProfileViewModel.swift
import Foundation
import SwiftUI
import Combine

class ProfileViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    var profile: UserProfile?
    var gamingStats: GamingStats?
    
    private let fetchProfileUseCase: FetchProfileUseCase
    private let updateProfileUseCase: UpdateProfileUseCase
    
    init(
        fetchProfileUseCase: FetchProfileUseCase? = nil,
        updateProfileUseCase: UpdateProfileUseCase? = nil
    ) {
        self.fetchProfileUseCase = fetchProfileUseCase ?? FetchProfileUseCase()
        self.updateProfileUseCase = updateProfileUseCase ?? UpdateProfileUseCase()
    }
    
    func fetchProfile() {
        Task {
            isLoading = true
            do {
                profile = try await fetchProfileUseCase.execute()
                // Fetch gaming stats
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func updateProfile(_ profile: UserProfile) {
        Task {
            isLoading = true
            do {
                self.profile = try await updateProfileUseCase.execute(profile: profile)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

