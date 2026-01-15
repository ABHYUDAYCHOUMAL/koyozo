//
//  SplashViewModel.swift
import Foundation
import SwiftUI
import Combine

class SplashViewModel: ViewModelProtocol {
    var isLoading: Bool = true
    var errorMessage: String?
    
    var isAuthenticated: Bool = false
    
    func checkAuthenticationStatus() {
        // Check if user is already authenticated
        // Navigate to appropriate screen
    }
}

