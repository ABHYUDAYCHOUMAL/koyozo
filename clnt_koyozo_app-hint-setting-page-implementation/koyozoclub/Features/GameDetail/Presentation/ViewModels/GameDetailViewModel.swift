//
//  GameDetailViewModel.swift
import Foundation
import SwiftUI
import Combine

class GameDetailViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    var game: Game?
    var screenshots: [GameScreenshot] = []
    var isControllerConnected: Bool = false
    
    private let gameId: String
    private let fetchGameDetailUseCase: FetchGameDetailUseCase
    private let markGamePlayedUseCase: MarkGamePlayedUseCase
    private let launchGameUseCase: LaunchGameUseCase
    
    init(
        gameId: String,
        fetchGameDetailUseCase: FetchGameDetailUseCase? = nil,
        markGamePlayedUseCase: MarkGamePlayedUseCase? = nil,
        launchGameUseCase: LaunchGameUseCase? = nil
    ) {
        self.gameId = gameId
        self.fetchGameDetailUseCase = fetchGameDetailUseCase ?? FetchGameDetailUseCase()
        self.markGamePlayedUseCase = markGamePlayedUseCase ?? MarkGamePlayedUseCase()
        self.launchGameUseCase = launchGameUseCase ?? LaunchGameUseCase()
    }
    
    func fetchGameDetail() {
        Task {
            isLoading = true
            do {
                game = try await fetchGameDetailUseCase.execute(gameId: gameId)
                // Fetch screenshots if available
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
    
    func launchGame() {
        guard let game = game else { return }
        
        Task {
            do {
                try await launchGameUseCase.execute(game: game)
                try await markGamePlayedUseCase.execute(gameId: gameId)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

