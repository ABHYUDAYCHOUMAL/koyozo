//
//  GameLauncherViewModel.swift
import Foundation
import SwiftUI
import Combine

class GameLauncherViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    var isLaunching: Bool = false
    
    private let launchGameUseCase: LaunchGameUseCase
    
    init(launchGameUseCase: LaunchGameUseCase? = nil) {
        self.launchGameUseCase = launchGameUseCase ?? LaunchGameUseCase()
    }
    
    func launchGame(_ game: Game) {
        isLaunching = true
        errorMessage = nil
        
        launchGameUseCase.execute(game: game)
        
        // Reset launching state after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLaunching = false
        }
    }
}

