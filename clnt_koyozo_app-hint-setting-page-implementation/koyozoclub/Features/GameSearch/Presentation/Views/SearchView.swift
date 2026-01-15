//
//  SearchView.swift
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel = SearchViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(text: $viewModel.searchText) {
                    viewModel.applySearch()
                }
                
                if viewModel.isLoading {
                    LoadingView()
                } else if !viewModel.searchResults.isEmpty {
                    SearchResultsView(
                        games: viewModel.searchResults,
                        onItemAppear: { game in
                            viewModel.loadMoreIfNeeded(currentGame: game)
                        }
                    )
                    if viewModel.isLoadingMore {
                        ProgressView()
                            .padding(.vertical, Spacing.md)
                    }
                } else if !viewModel.searchText.isEmpty {
                    Text("No games found")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Search Games")
            .onChange(of: viewModel.searchText) { _ in
                viewModel.applySearch()
            }
        }
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel())
}

