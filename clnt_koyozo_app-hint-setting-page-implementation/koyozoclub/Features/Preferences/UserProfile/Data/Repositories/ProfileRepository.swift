//
//  ProfileRepository.swift
import Foundation

protocol ProfileRepositoryProtocol {
    func fetchProfile() async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws -> UserProfile
}

final class ProfileRepository: ProfileRepositoryProtocol {
    private let apiClient: APIClient
    
    init(apiClient: APIClient? = nil) {
        self.apiClient = apiClient ?? APIClient()
    }
    
    func fetchProfile() async throws -> UserProfile {
        // Implement API call
        throw AppError.unknown
    }
    
    func updateProfile(_ profile: UserProfile) async throws -> UserProfile {
        // Implement API call
        throw AppError.unknown
    }
}

