//
//  OnboardingManager.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 16/01/26.
//

// koyozoclub/Core/Session/OnboardingManager.swift
import Foundation

final class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let userDefaults: UserDefaults
    private let hasSeenOnboardingKey = "has_seen_onboarding"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func hasSeenOnboarding() -> Bool {
        return userDefaults.bool(forKey: hasSeenOnboardingKey)
    }
    
    func markOnboardingAsSeen() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
    }
    
    func resetOnboarding() {
        userDefaults.removeObject(forKey: hasSeenOnboardingKey)
    }
}
