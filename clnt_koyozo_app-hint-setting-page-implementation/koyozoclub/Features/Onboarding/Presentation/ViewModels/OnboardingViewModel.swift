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
        // Page 1: Welcome (keep current first page)
        OnboardingPage(
            id: 0,
            imageName: "onboarding_controller",
            title: "Welcome to Koyozo",
            description: "Your ultimate gaming companion for iOS games with controller support",
            controllerHint: nil
        ),
        // Page 2: A button video
        OnboardingPage(
            id: 1,
            videoName: "A",
            title: "Press 'A' to Select",
            description: "Press 'A' to select /start",
            controllerHint: nil
        ),
        // Page 3: B button video
        OnboardingPage(
            id: 2,
            videoName: "B",
            title: "Press 'B' to Go Back",
            description: "Press 'B' to back in between pages",
            controllerHint: nil
        ),
        // Page 4: Y button video
        OnboardingPage(
            id: 3,
            videoName: "Y",
            title: "Press 'Y' to Search",
            description: "Press 'Y' to search",
            controllerHint: nil
        ),
        // Page 5: X button placeholder (icon)
        OnboardingPage(
            id: 4,
            imageName: nil,
            title: "Press 'X' to Favorite",
            description: "Press 'X' for keeping a game in favourite",
            controllerHint: nil
        ),
        // Page 6: Joystick video
        OnboardingPage(
            id: 5,
            videoName: "Joystick",
            title: "Use Joystick to Navigate",
            description: "Use Joystick to navigate",
            controllerHint: nil
        ),
        // Page 7: Mode button video
        OnboardingPage(
            id: 6,
            videoName: "mode",
            title: "Switch Between Modes",
            description: "Press mode to switch in between modes",
            controllerHint: nil
        ),
        // Page 8: Vibration video
        OnboardingPage(
            id: 7,
            videoName: "vibrate",
            title: "Press and hold to Reset the Controller",
            description: "Feel the real vibe with vibration",
            controllerHint: nil
        ),
        // Page 9: Final page (keep current last page)
        OnboardingPage(
            id: 8,
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
