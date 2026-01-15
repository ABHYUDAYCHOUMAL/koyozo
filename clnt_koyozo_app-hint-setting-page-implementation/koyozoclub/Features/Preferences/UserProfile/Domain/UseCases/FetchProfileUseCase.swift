//
//  FetchProfileUseCase.swift
import Foundation

protocol FetchProfileUseCaseProtocol {
    func execute() async throws -> UserProfile
}

final class FetchProfileUseCase: FetchProfileUseCaseProtocol {
    private let profileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository? = nil) {
        self.profileRepository = profileRepository ?? ProfileRepository()
    }
    
    func execute() async throws -> UserProfile {
        return try await profileRepository.fetchProfile()
    }
}

