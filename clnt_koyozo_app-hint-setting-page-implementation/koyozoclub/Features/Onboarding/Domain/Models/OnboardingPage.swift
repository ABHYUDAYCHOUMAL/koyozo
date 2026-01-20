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
    let imageName: String?
    let videoName: String? // Optional video file name (without .mp4 extension)
    let title: String
    let description: String
    let controllerHint: String? // Optional hint like "Use Y for Selection"
    
    init(id: Int, imageName: String? = nil, videoName: String? = nil, title: String, description: String, controllerHint: String? = nil) {
        self.id = id
        self.imageName = imageName
        self.videoName = videoName
        self.title = title
        self.description = description
        self.controllerHint = controllerHint
    }
}
