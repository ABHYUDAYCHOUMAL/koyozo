//
//  LaunchGameView.swift
import SwiftUI

struct LaunchGameView: View {
    @StateObject private var viewModel: GameLauncherViewModel
    let game: Game
    
    init(viewModel: GameLauncherViewModel = GameLauncherViewModel(), game: Game) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.game = game
    }
    
    var body: some View {
        VStack {
            if viewModel.isLaunching {
                LoadingView()
                Text("Launching game...")
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            } else {
                Text("Game launched successfully")
            }
        }
        .onAppear {
            viewModel.launchGame(game)
        }
    }
}

#Preview {
    LaunchGameView(
        game: Game(
            id: "1",
            title: "Test Game",
            thumbnailURL: "",
            backgroundURL: nil,
            description: nil,
            launchURL: "sample://",
            appStoreID: "123456789"
        )
    )
}

