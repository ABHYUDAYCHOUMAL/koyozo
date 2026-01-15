//
//  AllGamesView.swift
import SwiftUI
import Combine

struct AllGamesView: View {
    @StateObject private var viewModel: AllGamesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isSearchBarVisible: Bool
    @FocusState private var isSearchFocused: Bool
    @State private var isControllerInputActive = false
    
    private let controllerManager = ControllerManager.shared
    
    init(viewModel: AllGamesViewModel = AllGamesViewModel(), showSearch: Bool = false) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _isSearchBarVisible = State(initialValue: showSearch)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark blue background matching app theme
                AppTheme.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    customNavigationBar(topInset: geometry.safeAreaInsets.top)
                    
                    // Custom Search Bar (appears when search button is clicked)
                    if isSearchBarVisible {
                        HStack {
                            TextField("Search games...", text: $viewModel.searchText)
                                .focused($isSearchFocused)
                                .foregroundColor(AppTheme.Colors.text)
                                .padding(.horizontal, Spacing.md)
                                .padding(.vertical, Spacing.sm)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal, Spacing.md)
                                .onSubmit {
                                    viewModel.applySearch()
                                }
                                .onChange(of: viewModel.searchText) { _ in
                                    viewModel.applySearch()
                                }
                            
                        Button(action: {
                            clearSearchBar()
                        }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(AppTheme.Colors.text)
                                    .padding(.trailing, Spacing.md)
                            }
                        }
                        .padding(.vertical, Spacing.sm)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    ScrollView {
                        if viewModel.isLoading {
                            LoadingView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(.top, 100)
                        } else if let error = viewModel.errorMessage, viewModel.filteredGames.isEmpty {
                            VStack(spacing: Spacing.md) {
                                Text("Error loading games")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.Colors.text)
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(AppTheme.Colors.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 100)
                        } else if !viewModel.filteredGames.isEmpty {
                            VStack(spacing: 0) {
                                GameGridView(
                                    games: viewModel.filteredGames,
                                    selectedGameIndex: viewModel.selectedGameIndex,
                                    onGameTap: { game in
                                        viewModel.selectGame(at: viewModel.filteredGames.firstIndex(where: { $0.id == game.id }) ?? 0)
                                    },
                                    onItemAppear: { game in
                                        viewModel.loadMoreIfNeeded(currentGame: game)
                                    }
                                )
                                .padding(Spacing.md)
                                
                                if viewModel.isLoadingMore {
                                    LazyVGrid(
                                        columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.sm), count: 5),
                                        spacing: Spacing.xs
                                    ) {
                                        ForEach(0..<10, id: \.self) { _ in
                                            GameCardShimmerView()
                                        }
                                    }
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.top, Spacing.sm)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
                // Controller Hints - floating over content at bottom
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack(spacing: Spacing.sm) {
                            // Y Button - Search
                            HintButton(
                                buttonText: "Y",
                                labelText: "Search",
                                action: {
                                    isSearchBarVisible.toggle()
                                    if isSearchBarVisible {
                                        isSearchFocused = true
                                    }
                                }
                            )
                            
                            // X Button - Favourite
                            HintButton(
                                buttonText: "X",
                                labelText: viewModel.isSelectedGameFavorite ? "Unfavourite" : "Favourite",
                                action: {
                                    viewModel.toggleFavoriteForSelectedGame()
                                }
                            )
                            .id(viewModel.favoriteUpdateTrigger) // Force refresh when favorites change
                            
                            // B Button - Back
                            HintButton(
                                buttonText: "B",
                                labelText: "Back",
                                action: {
                                if !coordinator.navigationPath.isEmpty {
                                    coordinator.pop()
                                }
                                }
                            )
                            
                            // A Button - Launch
                            HintButton(
                                buttonText: "A",
                                labelText: "Start",
                                action: {
                                    viewModel.launchSelectedGame()
                                }
                            )
                        }
                        .padding(.trailing, Spacing.lg)
                        .padding(.bottom, Spacing.xl)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            isControllerInputActive = true
            viewModel.fetchAllGames(reset: true)
            setupControllerHandlers()
            if isSearchBarVisible {
                // Delay focus to ensure view is fully rendered
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFocused = true
                }
            }
        }
        .onDisappear {
            isControllerInputActive = false
            cancellables.removeAll()
        }
        .onChange(of: viewModel.searchText) { _ in
            viewModel.syncSelectionWithFilteredGames()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
    }
    
    private func setupControllerHandlers() {
        guard cancellables.isEmpty else { return }
        // A Button - Launch game
        controllerManager.onButtonAPressed
            .sink { [weak viewModel] in
                guard isControllerInputActive else { return }
                viewModel?.launchSelectedGame()
            }
            .store(in: &cancellables)
        
        // Y Button - Toggle search
        controllerManager.onButtonYPressed
            .sink {
                guard isControllerInputActive else { return }
                isSearchBarVisible.toggle()
                if isSearchBarVisible {
                    isSearchFocused = true
                }
            }
            .store(in: &cancellables)
        
        // X Button - Toggle favourite
        controllerManager.onButtonXPressed
            .sink { [weak viewModel] in
                guard isControllerInputActive else { return }
                viewModel?.toggleFavoriteForSelectedGame()
            }
            .store(in: &cancellables)
        
        // B Button - Back
        controllerManager.onButtonBPressed
            .sink {
                guard isControllerInputActive else { return }
                if !coordinator.navigationPath.isEmpty {
                    coordinator.pop()
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Left - Previous game
        controllerManager.onDPadLeft
            .sink { [weak viewModel] in
                guard isControllerInputActive else { return }
                viewModel?.moveFocusLeft()
            }
            .store(in: &cancellables)
        
        // D-Pad Right - Next game
        controllerManager.onDPadRight
            .sink { [weak viewModel] in
                guard isControllerInputActive else { return }
                viewModel?.moveFocusRight()
            }
            .store(in: &cancellables)
        
        controllerManager.onDPadUp
            .sink { [weak viewModel] in
                guard isControllerInputActive else { return }
                viewModel?.moveFocusUp()
            }
            .store(in: &cancellables)
        
        controllerManager.onDPadDown
            .sink { [weak viewModel] in
                guard isControllerInputActive else { return }
                viewModel?.moveFocusDown()
            }
            .store(in: &cancellables)
    }
    
    private func clearSearchBar() {
        viewModel.searchText = ""
        viewModel.applySearch()
        viewModel.syncSelectionWithFilteredGames()
        withAnimation {
            isSearchBarVisible = false
        }
        isSearchFocused = false
    }
    
    @ViewBuilder
    private func customNavigationBar(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    coordinator.pop()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                }
                
                Spacer()
                
                Text("All Games")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.Colors.text)
                
                Spacer()
                
                Button(action: {
                    isSearchBarVisible.toggle()
                    if isSearchBarVisible {
                        isSearchFocused = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.15))
                            .frame(width: 36, height: 36)
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.text)
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
            .padding(.top, topInset + Spacing.sm)
            
            Divider()
                .background(AppTheme.Colors.text.opacity(0.2))
        }
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    NavigationStack {
        AllGamesView()
    }
}

