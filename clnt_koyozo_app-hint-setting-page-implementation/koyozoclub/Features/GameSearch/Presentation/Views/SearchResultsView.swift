//
//  SearchResultsView.swift
import SwiftUI

struct SearchResultsView: View {
    let games: [Game]
    var onItemAppear: ((Game) -> Void)?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(games) { game in
                    GameCardView(game: game, isFocused: false)
                        .onAppear {
                            onItemAppear?(game)
                        }
                }
            }
            .padding()
        }
    }
}

#Preview {
    SearchResultsView(games: [])
}

