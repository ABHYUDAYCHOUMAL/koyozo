//
//  GameDetailView.swift
import SwiftUI

struct GameDetailView: View {
    @StateObject private var viewModel: GameDetailViewModel
    let gameId: String
    
    init(viewModel: GameDetailViewModel? = nil, gameId: String) {
        let vm = viewModel ?? GameDetailViewModel(gameId: gameId)
        _viewModel = StateObject(wrappedValue: vm)
        self.gameId = gameId
    }
    
    var body: some View {
        ScrollView {
            if let game = viewModel.game {
                VStack(alignment: .leading, spacing: Spacing.md) {
                    GameInfoView(game: game)
                    GameScreenshotsView(screenshots: viewModel.screenshots)
                    
                    PlayButton {
                        viewModel.launchGame()
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                LoadingView()
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(viewModel.game?.title ?? "Game Details")
        .onAppear {
            viewModel.fetchGameDetail()
        }
    }
}

#Preview {
    GameDetailView(gameId: "1")
}

