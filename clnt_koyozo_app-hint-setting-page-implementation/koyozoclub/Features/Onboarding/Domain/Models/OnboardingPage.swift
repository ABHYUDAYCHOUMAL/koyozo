//
//  OnboardingPage.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 16/01/26.
//

// koyozoclub/Features/Onboarding/Domain/Models/OnboardingPage.swift
import Foundation

struct OnboardingPage: Identifiable, Hashable {
    let id: Int
    let imageName: String
    let title: String
    let description: String
    let controllerHint: String? // Optional hint like "Use Y for Selection"
}
