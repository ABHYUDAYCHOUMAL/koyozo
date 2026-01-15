//
//  RecentGamesView.swift
import SwiftUI

struct RecentGamesView: View {
    @ObservedObject var viewModel: GameLibraryViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Recent Games")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(viewModel.recentGames) { game in
                        GameCardView(game: game, isFocused: false)
                            .frame(width: 150)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RecentGamesView(viewModel: GameLibraryViewModel())
}

