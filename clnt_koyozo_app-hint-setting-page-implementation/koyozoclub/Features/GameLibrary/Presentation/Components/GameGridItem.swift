//
//  GameGridItem.swift
import SwiftUI

struct GameGridItem: View {
    let game: Game
    let isFocused: Bool
    
    var body: some View {
        GameCardView(game: game, isFocused: isFocused)
    }
}

#Preview {
    GameGridItem(
        game: Game(
            id: "1",
            title: "Sample Game",
            category: "",
            customURLScheme: "",
            thumbnailURL: "",
            backgroundURL: nil,
            description: nil,
            launchURL: "sample://",
            appStoreID: "123456789"
        ),
        isFocused: false
    )
}

