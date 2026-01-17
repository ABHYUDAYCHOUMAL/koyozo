//
//  OnboardingViewModel.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 16/01/26.
//
// koyozoclub/Features/Onboarding/Presentation/ViewModels/OnboardingViewModel.swift
import Foundation
import SwiftUI
import Combine

class OnboardingViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    @Published var currentPageIndex: Int = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            imageName: "onboarding_controller",
            title: "Welcome to Koyozo",
            description: "Your ultimate gaming companion for iOS games with controller support",
            controllerHint: nil
        ),
        OnboardingPage(
            id: 1,
            imageName: "onboarding_controller",
            title: "Connect Your Controller",
            description: "Pair your favorite gaming controller for the best experience",
            controllerHint: "Use Y for Pin/unpin"
        ),
        OnboardingPage(
            id: 2,
            imageName: "onboarding_browse",
            title: "Browse & Play",
            description: "Discover thousands of iOS games optimized for controller play",
            controllerHint: nil
        ),
        OnboardingPage(
            id: 3,
            imageName: "onboarding_browse",
            title: "Ready to Play!",
            description: "Start your gaming journey with Koyozo now",
            controllerHint: nil
        )
    ]
    
    var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }
    
    var currentPage: OnboardingPage {
        pages[currentPageIndex]
    }
    
    func nextPage() {
        if currentPageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex += 1
            }
        }
    }
    
    func previousPage() {
        if currentPageIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPageIndex -= 1
            }
        }
    }
    
    func skipOnboarding() {
        OnboardingManager.shared.markOnboardingAsSeen()
    }
    
    func completeOnboarding() {
        OnboardingManager.shared.markOnboardingAsSeen()
    }
}
