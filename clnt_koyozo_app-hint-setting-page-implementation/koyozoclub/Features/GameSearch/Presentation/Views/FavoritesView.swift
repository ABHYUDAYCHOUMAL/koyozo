//
//  FavoritesView.swift
import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel: FavoritesViewModel
    
    init(viewModel: FavoritesViewModel = FavoritesViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.favorites.isEmpty {
                    VStack {
                        Text("No favorites yet")
                            .foregroundColor(.gray)
                            .padding()
                    }
                } else {
                    LazyVStack(spacing: Spacing.md) {
                        ForEach(viewModel.favorites) { game in
                            GameCardView(game: game, isFocused: false)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favorites")
            .onAppear {
                viewModel.fetchFavorites()
            }
        }
    }
}

#Preview {
    FavoritesView(viewModel: FavoritesViewModel())
}

