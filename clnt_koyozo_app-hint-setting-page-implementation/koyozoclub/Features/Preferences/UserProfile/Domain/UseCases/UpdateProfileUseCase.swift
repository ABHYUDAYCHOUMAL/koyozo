//
//  UpdateProfileUseCase.swift
import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(profile: UserProfile) async throws -> UserProfile
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let profileRepository: ProfileRepository
    
    init(profileRepository: ProfileRepository? = nil) {
        self.profileRepository = profileRepository ?? ProfileRepository()
    }
    
    func execute(profile: UserProfile) async throws -> UserProfile {
        return try await profileRepository.updateProfile(profile)
    }
}

