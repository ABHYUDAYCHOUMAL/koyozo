//
//  SearchViewModel.swift
import Foundation
import SwiftUI
import Combine

class SearchViewModel: ViewModelProtocol {
    var isLoading: Bool = false
    var errorMessage: String?
    
    @Published var searchText: String = ""
    @Published var searchResults: [Game] = []
    @Published var isLoadingMore: Bool = false
    
    private let searchGamesUseCase: SearchGamesUseCase
    
    // Pagination state
    private var currentPage: Int = 0
    private var totalPages: Int = 1
    private var isFetching: Bool = false
    private var searchDebounceWorkItem: DispatchWorkItem?
    
    init(searchGamesUseCase: SearchGamesUseCase? = nil) {
        self.searchGamesUseCase = searchGamesUseCase ?? SearchGamesUseCase()
    }
    
    /// Debounced search trigger to avoid excessive API calls
    func applySearch() {
        searchDebounceWorkItem?.cancel()
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // If empty, clear results immediately
        if term.isEmpty {
            resetResults()
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.resetPagination()
            self?.fetch(reset: true)
        }
        searchDebounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: workItem)
    }
    
    /// Load more results when reaching list end
    func loadMoreIfNeeded(currentGame: Game) {
        guard !isFetching, currentPage < totalPages else { return }
        guard let index = searchResults.firstIndex(where: { $0.id == currentGame.id }) else { return }
        let thresholdIndex = searchResults.count - 3
        if index >= thresholdIndex {
            fetch(reset: false)
        }
    }
    
    /// Core fetch logic
    private func fetch(reset: Bool) {
        Task {
            if isFetching { return }
            isFetching = true
            
            if reset {
                await MainActor.run {
                    isLoading = true
                    isLoadingMore = false
                    errorMessage = nil
                    searchResults = []
                }
            } else {
                await MainActor.run {
                    isLoadingMore = true
                }
            }
            
            do {
                let result = try await searchGamesUseCase.execute(
                    query: searchText,
                    pageNumber: currentPage,
                    pageSize: Constants.API.defaultPageSize
                )
                
                await MainActor.run {
                    searchResults.append(contentsOf: result.games)
                    currentPage = result.pageNumber + 1
                    totalPages = result.totalPages
                    isLoading = false
                    isLoadingMore = false
                    errorMessage = nil
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                    isLoadingMore = false
                }
            }
            
            isFetching = false
        }
    }
    
    private func resetPagination() {
        currentPage = 0
        totalPages = 1
    }
    
    private func resetResults() {
        currentPage = 0
        totalPages = 1
        searchResults = []
        errorMessage = nil
        isLoading = false
        isLoadingMore = false
    }
}

