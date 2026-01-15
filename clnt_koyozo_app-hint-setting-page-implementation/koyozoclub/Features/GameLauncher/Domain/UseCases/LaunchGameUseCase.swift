//
//  LaunchGameUseCase.swift
import Foundation

protocol LaunchGameUseCaseProtocol {
    func execute(game: Game)
}

final class LaunchGameUseCase: LaunchGameUseCaseProtocol {
    private let gameLauncherService: GameLauncherService
    
    init(gameLauncherService: GameLauncherService? = nil) {
        self.gameLauncherService = gameLauncherService ?? GameLauncherService()
    }
    
    func execute(game: Game) {
        gameLauncherService.launch(game: game)
    }
}

