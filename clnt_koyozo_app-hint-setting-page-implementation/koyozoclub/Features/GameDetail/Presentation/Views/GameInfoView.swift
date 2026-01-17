//
//  GameInfoView.swift
import SwiftUI

struct GameInfoView: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(game.title)
                .font(.title)
                .bold()
            
            if let description = game.description {
                Text(description)
                    .font(.body)
            }
        }
    }
}

#Preview {
    GameInfoView(game: Game(
        id: "1",
        title: "Test Game",
        category: "",
        customURLScheme: "",
        thumbnailURL: "",
        backgroundURL: nil,
        description: nil,
        launchURL: "sample://",
        appStoreID: "123456789"
    ))
}

