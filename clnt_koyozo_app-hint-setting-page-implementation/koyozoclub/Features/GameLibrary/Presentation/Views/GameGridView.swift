//
//  GameGridView.swift
import SwiftUI

struct GameGridView: View {
    let games: [Game]
    let selectedGameIndex: Int
    var onGameTap: ((Game) -> Void)?
    var onItemAppear: ((Game) -> Void)?
    
    var body: some View {
        ScrollViewReader { proxy in
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 5),
                spacing: Spacing.xs
            ) {
                ForEach(Array(games.enumerated()), id: \.element.id) { index, game in
                    GameCardView(
                        game: game,
                        isFocused: index == selectedGameIndex
                    ) {
                        onGameTap?(game)
                    }
                    .id(index)
                    .onAppear {
                        onItemAppear?(game)
                    }
                }
            }
            .onChange(of: selectedGameIndex) { newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
}

#Preview {
    GameGridView(games: [], selectedGameIndex: 0)
}

