//
//  GameLibraryView.swift
import SwiftUI
import Combine

// Preference Key for tracking vertical scroll offsets
struct VerticalScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]
    
    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct GameLibraryView: View {
    @StateObject private var viewModel: GameLibraryViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var snapTimer: Timer?
    @State private var verticalSnapTimer: Timer?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var scrollProxy: ScrollViewProxy?
    @State private var screenWidth: CGFloat = 0
    @State private var showLoginSnackbar = false
    @State private var selectedRowIndex: Int = 0
    @State private var rowScrollProxies: [Int: ScrollViewProxy] = [:]
    @State private var verticalScrollProxy: ScrollViewProxy?
    @State private var verticalScrollOffsets: [String: CGFloat] = [:]
    @State private var isTopBarFocused: Bool = false
    @State private var topBarSelectedIndex: Int = 0 // 0 = search, 1 = controller, 2 = settings, 3 = question mark
    
    private let controllerManager = ControllerManager.shared
    
    init(viewModel: GameLibraryViewModel = GameLibraryViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                GameLibraryBackgroundView(
                    selectedItem: getSelectedItem(),
                    geometry: geometry
                )
                
                // Top bar with icons
                // Top bar with icons
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: Spacing.md) {
                            // Search icon in transparent circle
                            Button(action: {
                                coordinator.navigate(to: .allGames(showSearch: true))
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.text)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isTopBarFocused && topBarSelectedIndex == 0 ? AppTheme.Colors.accent : Color.clear,
                                            lineWidth: isTopBarFocused && topBarSelectedIndex == 0 ? 1.5 : 0
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: isTopBarFocused && topBarSelectedIndex == 0 ? AppTheme.Colors.accent.opacity(0.8) : Color.clear,
                                            radius: isTopBarFocused && topBarSelectedIndex == 0 ? 8 : 0
                                        )
                                )
                                .scaleEffect(isTopBarFocused && topBarSelectedIndex == 0 ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTopBarFocused && topBarSelectedIndex == 0)
                            }
                            
                            // Controller Settings icon in transparent circle - NEW
                            Button(action: {
                                coordinator.navigate(to: .controllerSettings)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.text)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isTopBarFocused && topBarSelectedIndex == 1 ? AppTheme.Colors.accent : Color.clear,
                                            lineWidth: isTopBarFocused && topBarSelectedIndex == 1 ? 1.5 : 0
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: isTopBarFocused && topBarSelectedIndex == 1 ? AppTheme.Colors.accent.opacity(0.8) : Color.clear,
                                            radius: isTopBarFocused && topBarSelectedIndex == 1 ? 8 : 0
                                        )
                                )
                                .scaleEffect(isTopBarFocused && topBarSelectedIndex == 1 ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTopBarFocused && topBarSelectedIndex == 1)
                            }
                            
                            // Settings icon in transparent circle
                            Button(action: {
                                coordinator.navigate(to: .settings)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.text)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isTopBarFocused && topBarSelectedIndex == 2 ? AppTheme.Colors.accent : Color.clear,
                                            lineWidth: isTopBarFocused && topBarSelectedIndex == 2 ? 1.5 : 0
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: isTopBarFocused && topBarSelectedIndex == 2 ? AppTheme.Colors.accent.opacity(0.8) : Color.clear,
                                            radius: isTopBarFocused && topBarSelectedIndex == 2 ? 8 : 0
                                        )
                                )
                                .scaleEffect(isTopBarFocused && topBarSelectedIndex == 2 ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTopBarFocused && topBarSelectedIndex == 2)
                            }
                            
                            // Question mark icon (Help/Onboarding)
                            Button(action: {
                                coordinator.navigate(to: .onboarding)
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.text)
                                }
                                .overlay(
                                    Circle()
                                        .stroke(
                                            isTopBarFocused && topBarSelectedIndex == 3 ? AppTheme.Colors.accent : Color.clear,
                                            lineWidth: isTopBarFocused && topBarSelectedIndex == 3 ? 1.5 : 0
                                        )
                                        .frame(width: 36, height: 36)
                                        .shadow(
                                            color: isTopBarFocused && topBarSelectedIndex == 3 ? AppTheme.Colors.accent.opacity(0.8) : Color.clear,
                                            radius: isTopBarFocused && topBarSelectedIndex == 3 ? 8 : 0
                                        )
                                )
                                .scaleEffect(isTopBarFocused && topBarSelectedIndex == 3 ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTopBarFocused && topBarSelectedIndex == 3)
                            }
                            
                            // App icon
                            Image("AppIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                        }
                        .padding(.trailing, Spacing.xl + Spacing.md)
                        .padding(.top, geometry.safeAreaInsets.top + Spacing.md)
                    }
                    Spacer()
                }
                .ignoresSafeArea(edges: .top)
                
                // Content with vertical scrolling
                VStack(spacing: 0) {
                    // Top spacer to keep top area clean
                    Spacer()
                        .frame(height: Spacing.xl + Spacing.lg)
                    
                    // Scrollable rows of games
                    ScrollViewReader { verticalProxy in
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                // First Row - Games
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionTitleView(
                                        title: "Games",
                                        isSelected: selectedRowIndex == 0
                                    )
                                    .padding(.leading, Spacing.xl + Spacing.xl)
                                    
                                    GameScrollView(
                                        gameItems: viewModel.gameItems,
                                        selectedIndex: selectedRowIndex == 0 ? viewModel.selectedGameIndex : -1,
                                        geometry: geometry,
                                        onGameSelected: { index in
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedRowIndex = 0
                                                viewModel.selectGame(at: index)
                                                // Snap to this row when a game is selected
                                                verticalScrollProxy?.scrollTo("row-0", anchor: .center)
                                            }
                                        },
                                        onAllGamesTapped: {
                                            viewModel.handleAllGamesTap()
                                            coordinator.navigate(to: .allGames(showSearch: false))
                                        },
                                        onGameLaunched: {
                                            viewModel.launchSelectedGame()
                                        },
                                        onScrollOffsetChanged: { offsets in
                                            if selectedRowIndex == 0 {
                                                updateSelectedGameFromScroll(offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onScrollEnded: { proxy, offsets in
                                            if selectedRowIndex == 0 {
                                                snapToClosestGame(proxy: proxy, offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onProxyReady: { proxy in
                                            rowScrollProxies[0] = proxy
                                            scrollProxy = proxy
                                        }
                                    )
                                    .frame(height: 170)
                                    .offset(y: -Spacing.sm)
                                }
                                .contentShape(Rectangle())
                                .id("row-0")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: VerticalScrollOffsetPreferenceKey.self,
                                                value: ["row-0": geo.frame(in: .named("verticalScroll")).minY]
                                            )
                                    }
                                )
                                
                                // Divider between rows
                                Rectangle()
                                    .fill(AppTheme.Colors.text.opacity(0.2))
                                    .frame(height:1)
                                    .padding(.horizontal, Spacing.xl + Spacing.xl)
                                    .padding(.top, Spacing.xl)
                                    .padding(.bottom, Spacing.sm)
                                
                                // Second Row - Favourites
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionTitleView(
                                        title: "Favourites",
                                        isSelected: selectedRowIndex == 1
                                    )
                                    .padding(.leading, Spacing.xl + Spacing.xl)
                                    
                                    GameScrollView(
                                        gameItems: viewModel.favoriteItems,
                                        selectedIndex: selectedRowIndex == 1 ? viewModel.selectedFavoriteIndex : -1,
                                        geometry: geometry,
                                        onGameSelected: { index in
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedRowIndex = 1
                                                viewModel.selectFavorite(at: index)
                                                // Snap to this row when a game is selected
                                                verticalScrollProxy?.scrollTo("row-1", anchor: .center)
                                            }
                                        },
                                        onAllGamesTapped: {
                                            // Navigate to All Games page
                                            coordinator.navigate(to: .allGames(showSearch: false))
                                        },
                                        onGameLaunched: {
                                            // Launch favorite game
                                            if let favoriteItem = viewModel.selectedFavoriteItem,
                                               case .game(let game) = favoriteItem {
                                                viewModel.launchGame(game)
                                            }
                                        },
                                        onScrollOffsetChanged: { offsets in
                                            if selectedRowIndex == 1 {
                                                updateSelectedFavoriteFromScroll(offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onScrollEnded: { proxy, offsets in
                                            if selectedRowIndex == 1 {
                                                snapToClosestFavorite(proxy: proxy, offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onProxyReady: { proxy in
                                            rowScrollProxies[1] = proxy
                                        }
                                    )
                                    .frame(height: 170)
                                    .offset(y: -Spacing.sm)
                                }
                                .contentShape(Rectangle())
                                .id("row-1")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: VerticalScrollOffsetPreferenceKey.self,
                                                value: ["row-1": geo.frame(in: .named("verticalScroll")).minY]
                                            )
                                    }
                                )
                                
                                // Divider between rows
                                Rectangle()
                                    .fill(AppTheme.Colors.text.opacity(0.2))
                                    .frame(height:1)
                                    .padding(.horizontal, Spacing.xl + Spacing.xl)
                                    .padding(.top, Spacing.xl)
                                    .padding(.bottom, Spacing.sm)

                                // Third Row - New Tryouts
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionTitleView(
                                        title: "New Tryouts",
                                        isSelected: selectedRowIndex == 2
                                    )
                                    .padding(.leading, Spacing.xl + Spacing.xl)
                                    
                                    GameScrollView(
                                        gameItems: viewModel.newTryoutsItems,
                                        selectedIndex: selectedRowIndex == 2 ? viewModel.selectedNewTryoutsIndex : -1,
                                        geometry: geometry,
                                        onGameSelected: { index in
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedRowIndex = 2
                                                viewModel.selectNewTryout(at: index)
                                                verticalScrollProxy?.scrollTo("row-2", anchor: .center)
                                            }
                                        },
                                        onAllGamesTapped: {
                                            coordinator.navigate(to: .allGames(showSearch: false))
                                        },
                                        onGameLaunched: {
                                            if let item = viewModel.selectedNewTryoutItem,
                                               case .game(let game) = item {
                                                viewModel.launchGame(game)
                                            }
                                        },
                                        onScrollOffsetChanged: { offsets in
                                            if selectedRowIndex == 2 {
                                                updateSelectedNewTryoutFromScroll(offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onScrollEnded: { proxy, offsets in
                                            if selectedRowIndex == 2 {
                                                snapToClosestNewTryout(proxy: proxy, offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onProxyReady: { proxy in
                                            rowScrollProxies[2] = proxy
                                        }
                                    )
                                    .frame(height: 170)
                                    .offset(y: -Spacing.sm)
                                }
                                .contentShape(Rectangle())
                                .id("row-2")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: VerticalScrollOffsetPreferenceKey.self,
                                                value: ["row-2": geo.frame(in: .named("verticalScroll")).minY]
                                            )
                                    }
                                )

                                // Divider between rows
                                Rectangle()
                                    .fill(AppTheme.Colors.text.opacity(0.2))
                                    .frame(height:1)
                                    .padding(.horizontal, Spacing.xl + Spacing.xl)
                                    .padding(.top, Spacing.xl)
                                    .padding(.bottom, Spacing.sm)

                                // Fourth Row - Popular in India Today
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionTitleView(
                                        title: "Popular in India Today",
                                        isSelected: selectedRowIndex == 3
                                    )
                                    .padding(.leading, Spacing.xl + Spacing.xl)
                                    
                                    GameScrollView(
                                        gameItems: viewModel.popularInIndiaItems,
                                        selectedIndex: selectedRowIndex == 3 ? viewModel.selectedPopularInIndiaIndex : -1,
                                        geometry: geometry,
                                        onGameSelected: { index in
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedRowIndex = 3
                                                viewModel.selectPopularInIndia(at: index)
                                                verticalScrollProxy?.scrollTo("row-3", anchor: .center)
                                            }
                                        },
                                        onAllGamesTapped: {
                                            coordinator.navigate(to: .allGames(showSearch: false))
                                        },
                                        onGameLaunched: {
                                            if let item = viewModel.selectedPopularInIndiaItem,
                                               case .game(let game) = item {
                                                viewModel.launchGame(game)
                                            }
                                        },
                                        onScrollOffsetChanged: { offsets in
                                            if selectedRowIndex == 3 {
                                                updateSelectedPopularInIndiaFromScroll(offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onScrollEnded: { proxy, offsets in
                                            if selectedRowIndex == 3 {
                                                snapToClosestPopularInIndia(proxy: proxy, offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onProxyReady: { proxy in
                                            rowScrollProxies[3] = proxy
                                        }
                                    )
                                    .frame(height: 170)
                                    .offset(y: -Spacing.sm)
                                }
                                .contentShape(Rectangle())
                                .id("row-3")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: VerticalScrollOffsetPreferenceKey.self,
                                                value: ["row-3": geo.frame(in: .named("verticalScroll")).minY]
                                            )
                                    }
                                )

                                // Divider between rows
                                Rectangle()
                                    .fill(AppTheme.Colors.text.opacity(0.2))
                                    .frame(height:1)
                                    .padding(.horizontal, Spacing.xl + Spacing.xl)
                                    .padding(.top, Spacing.xl)
                                    .padding(.bottom, Spacing.sm)

                                // Fifth Row - Play with Friends
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionTitleView(
                                        title: "Play with Friends",
                                        isSelected: selectedRowIndex == 4
                                    )
                                    .padding(.leading, Spacing.xl + Spacing.xl)
                                    
                                    GameScrollView(
                                        gameItems: viewModel.playWithFriendsItems,
                                        selectedIndex: selectedRowIndex == 4 ? viewModel.selectedPlayWithFriendsIndex : -1,
                                        geometry: geometry,
                                        onGameSelected: { index in
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedRowIndex = 4
                                                viewModel.selectPlayWithFriends(at: index)
                                                verticalScrollProxy?.scrollTo("row-4", anchor: .center)
                                            }
                                        },
                                        onAllGamesTapped: {
                                            coordinator.navigate(to: .allGames(showSearch: false))
                                        },
                                        onGameLaunched: {
                                            if let item = viewModel.selectedPlayWithFriendsItem,
                                               case .game(let game) = item {
                                                viewModel.launchGame(game)
                                            }
                                        },
                                        onScrollOffsetChanged: { offsets in
                                            if selectedRowIndex == 4 {
                                                updateSelectedPlayWithFriendsFromScroll(offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onScrollEnded: { proxy, offsets in
                                            if selectedRowIndex == 4 {
                                                snapToClosestPlayWithFriends(proxy: proxy, offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onProxyReady: { proxy in
                                            rowScrollProxies[4] = proxy
                                        }
                                    )
                                    .frame(height: 170)
                                    .offset(y: -Spacing.sm)
                                }
                                .contentShape(Rectangle())
                                .id("row-4")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: VerticalScrollOffsetPreferenceKey.self,
                                                value: ["row-4": geo.frame(in: .named("verticalScroll")).minY]
                                            )
                                    }
                                )

                                // Divider between rows
                                Rectangle()
                                    .fill(AppTheme.Colors.text.opacity(0.2))
                                    .frame(height:1)
                                    .padding(.horizontal, Spacing.xl + Spacing.xl)
                                    .padding(.top, Spacing.xl)
                                    .padding(.bottom, Spacing.sm)

                                // Sixth Row - Platforms
                                VStack(alignment: .leading, spacing: 0) {
                                    SectionTitleView(
                                        title: "Platforms",
                                        isSelected: selectedRowIndex == 5
                                    )
                                    .padding(.leading, Spacing.xl + Spacing.xl)
                                    
                                    GameScrollView(
                                        gameItems: viewModel.platformsItems,
                                        selectedIndex: selectedRowIndex == 5 ? viewModel.selectedPlatformsIndex : -1,
                                        geometry: geometry,
                                        onGameSelected: { index in
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                selectedRowIndex = 5
                                                viewModel.selectPlatforms(at: index)
                                                verticalScrollProxy?.scrollTo("row-5", anchor: .center)
                                            }
                                        },
                                        onAllGamesTapped: {
                                            coordinator.navigate(to: .allGames(showSearch: false))
                                        },
                                        onGameLaunched: {
                                            if let item = viewModel.selectedPlatformsItem,
                                               case .game(let game) = item {
                                                viewModel.launchGame(game)
                                            }
                                        },
                                        onScrollOffsetChanged: { offsets in
                                            if selectedRowIndex == 5 {
                                                updateSelectedPlatformsFromScroll(offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onScrollEnded: { proxy, offsets in
                                            if selectedRowIndex == 5 {
                                                snapToClosestPlatforms(proxy: proxy, offsets: offsets, geometry: geometry)
                                            }
                                        },
                                        onProxyReady: { proxy in
                                            rowScrollProxies[5] = proxy
                                        }
                                    )
                                    .frame(height: 170)
                                    .offset(y: -Spacing.sm)
                                }
                                .contentShape(Rectangle())
                                .id("row-5")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear
                                            .preference(
                                                key: VerticalScrollOffsetPreferenceKey.self,
                                                value: ["row-5": geo.frame(in: .named("verticalScroll")).minY]
                                            )
                                    }
                                )
                            }
                            .padding(.top, Spacing.sm)
                            .padding(.bottom, 100) // Add bottom padding to show peek of second row (half visible)
                        }
                        .coordinateSpace(name: "verticalScroll")
                        .onPreferenceChange(VerticalScrollOffsetPreferenceKey.self) { offsets in
                            verticalScrollOffsets = offsets
                            
                            // Reset timer for vertical snap
                            verticalSnapTimer?.invalidate()
                            let offsetsCopy = offsets
                            let proxyCopy = verticalProxy
                            verticalSnapTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                                snapToClosestRow(proxy: proxyCopy, offsets: offsetsCopy, geometry: geometry)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onAppear {
                            DispatchQueue.main.async {
                                verticalScrollProxy = verticalProxy
                            }
                        }
                    }
                    .layoutPriority(1) // Force the ScrollView to expand and fill available space
                }
                // Force the main VStack to take full screen height
                .frame(width: geometry.size.width, height: geometry.size.height)
                
                // Floating Controller Hints overlay at bottom
                VStack {
                    Spacer()
                ControllerHintsView(
                    onConfirmTap: {
                        guard let selectedItem = getSelectedItem() else { return }
                        switch selectedItem {
                        case .allGames:
                            coordinator.navigate(to: .allGames(showSearch: false))
                        case .game(let game):
                            viewModel.launchGame(game)
                        }
                    },
                    onFavoriteTap: canFavoriteCurrentSelection ? {
                        viewModel.toggleFavoriteForCurrentGame(inRow: selectedRowIndex)
                    } : nil,
                    isFavorite: isCurrentGameFavorite,
                    showsFavorite: canFavoriteCurrentSelection
                )
                    .padding(.bottom, Spacing.md)
                }
                
                // Snackbar overlay
                if let userEmail = UserSessionManager.shared.getUserEmail() {
                    Snackbar(
                        message: "Logged in as \(userEmail)",
                        isShowing: $showLoginSnackbar,
                        duration: 3.0
                    )
                }
            }
            .onAppear {
                screenWidth = geometry.size.width
            viewModel.fetchGames()
            setupControllerHandlers()
                
                // Show login snackbar only if user just logged in
                if UserSessionManager.shared.shouldShowLoginSnackbar(),
                   let _ = UserSessionManager.shared.getUserEmail() {
                    showLoginSnackbar = true
                    // Clear the flag after showing snackbar
                    UserSessionManager.shared.setShouldShowLoginSnackbar(false)
                }
            }
            .onChange(of: geometry.size.width) { newWidth in
                screenWidth = newWidth
            }
        }                                                                                                                        
        .ignoresSafeArea()
        // Hide default nav bar/back button when on dashboard
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden()
        .onDisappear {
            snapTimer?.invalidate()
            verticalSnapTimer?.invalidate()
            cancellables.removeAll()
        }
    }
    
    private func updateSelectedGameFromScroll(offsets: [Int: CGFloat], geometry: GeometryProxy) {
        // Calculate which game is closest to the focus position
        // Focus position is 100px from left edge of screen
        let focusPosition: CGFloat = 100
        let threshold: CGFloat = 80 // Threshold for considering an item "in focus" (reduced for smoother transitions)
        
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            // Calculate distance from focus position
            let distance = abs(offset - focusPosition)
            
            // Find the item closest to the focus position
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        // Update selected game if it changed and is within threshold
        if let index = closestIndex,
           minDistance < threshold,
           index != viewModel.selectedGameIndex,
           index < viewModel.gameItems.count {
            // Use a lighter animation for scroll-based updates
            DispatchQueue.main.async {
                viewModel.selectGame(at: index)
            }
        }
    }
    
    private func snapToClosestGame(proxy: ScrollViewProxy, offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        // Snap to the closest game
        if let index = closestIndex, index < viewModel.gameItems.count {
            withAnimation(.easeOut(duration: 0.3)) {
                let focusX: CGFloat = 100
                let anchorX = focusX / geometry.size.width
                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                viewModel.selectGame(at: index)
            }
        }
    }
    
    private func updateSelectedFavoriteFromScroll(offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        let threshold: CGFloat = 80
        
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex,
           minDistance < threshold,
           index != viewModel.selectedFavoriteIndex,
           index < viewModel.favoriteItems.count {
            DispatchQueue.main.async {
                viewModel.selectFavorite(at: index)
            }
        }
    }
    
    //new methods
    private func updateSelectedNewTryoutFromScroll(offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        let threshold: CGFloat = 80
        
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex,
           minDistance < threshold,
           index != viewModel.selectedNewTryoutsIndex,
           index < viewModel.newTryoutsItems.count {
            DispatchQueue.main.async {
                viewModel.selectNewTryout(at: index)
            }
        }
    }

    private func updateSelectedPopularInIndiaFromScroll(offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        let threshold: CGFloat = 80
        
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex,
           minDistance < threshold,
           index != viewModel.selectedPopularInIndiaIndex,
           index < viewModel.popularInIndiaItems.count {
            DispatchQueue.main.async {
                viewModel.selectPopularInIndia(at: index)
            }
        }
    }

    private func updateSelectedPlayWithFriendsFromScroll(offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        let threshold: CGFloat = 80
        
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex,
           minDistance < threshold,
           index != viewModel.selectedPlayWithFriendsIndex,
           index < viewModel.playWithFriendsItems.count {
            DispatchQueue.main.async {
                viewModel.selectPlayWithFriends(at: index)
            }
        }
    }

    private func updateSelectedPlatformsFromScroll(offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        let threshold: CGFloat = 80
        
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex,
           minDistance < threshold,
           index != viewModel.selectedPlatformsIndex,
           index < viewModel.platformsItems.count {
            DispatchQueue.main.async {
                viewModel.selectPlatforms(at: index)
            }
        }
    }
    
    private func snapToClosestFavorite(proxy: ScrollViewProxy, offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex, index < viewModel.favoriteItems.count {
            withAnimation(.easeOut(duration: 0.3)) {
                let focusX: CGFloat = 100
                let anchorX = focusX / geometry.size.width
                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                viewModel.selectFavorite(at: index)
            }
        }
    }
    
    //added from here
    private func snapToClosestNewTryout(proxy: ScrollViewProxy, offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex, index < viewModel.newTryoutsItems.count {
            withAnimation(.easeOut(duration: 0.3)) {
                let focusX: CGFloat = 100
                let anchorX = focusX / geometry.size.width
                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                viewModel.selectNewTryout(at: index)
            }
        }
    }

    private func snapToClosestPopularInIndia(proxy: ScrollViewProxy, offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex, index < viewModel.popularInIndiaItems.count {
            withAnimation(.easeOut(duration: 0.3)) {
                let focusX: CGFloat = 100
                let anchorX = focusX / geometry.size.width
                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                viewModel.selectPopularInIndia(at: index)
            }
        }
    }

    private func snapToClosestPlayWithFriends(proxy: ScrollViewProxy, offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex, index < viewModel.playWithFriendsItems.count {
            withAnimation(.easeOut(duration: 0.3)) {
                let focusX: CGFloat = 100
                let anchorX = focusX / geometry.size.width
                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                viewModel.selectPlayWithFriends(at: index)
            }
        }
    }

    private func snapToClosestPlatforms(proxy: ScrollViewProxy, offsets: [Int: CGFloat], geometry: GeometryProxy) {
        let focusPosition: CGFloat = 100
        var closestIndex: Int?
        var minDistance: CGFloat = .infinity
        
        for (index, offset) in offsets {
            let distance = abs(offset - focusPosition)
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        if let index = closestIndex, index < viewModel.platformsItems.count {
            withAnimation(.easeOut(duration: 0.3)) {
                let focusX: CGFloat = 100
                let anchorX = focusX / geometry.size.width
                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                viewModel.selectPlatforms(at: index)
            }
        }
    }
    
    private func snapToClosestRow(proxy: ScrollViewProxy, offsets: [String: CGFloat], geometry: GeometryProxy) {
        // Calculate the center of the visible scroll area
        // Account for title at top (approximately 80pt) and controller hints at bottom (approximately 100pt)
        let titleHeight: CGFloat = 80
        let controllerHeight: CGFloat = 100
        let scrollAreaHeight = geometry.size.height - titleHeight - controllerHeight
        let visibleCenter = titleHeight + (scrollAreaHeight / 2)
        
        var closestRow: String?
        var minDistance: CGFloat = .infinity
        
        for (rowId, offset) in offsets {
            // The offset is the top of the row, approximate row center is offset + half row height
            // Each row is approximately 200pt tall (title + divider + scroll view)
            let rowHeight: CGFloat = 200
            let rowCenter = offset + (rowHeight / 2)
            let distance = abs(rowCenter - visibleCenter)
            
            if distance < minDistance {
                minDistance = distance
                closestRow = rowId
            }
        }
        
        // Snap to the closest row
        if let rowId = closestRow {
            // row ids are "row-0" ... "row-5"
            let targetRowIndex = Int(rowId.split(separator: "-").last ?? "") ?? 0
            
            withAnimation(.easeOut(duration: 0.3)) {
                if targetRowIndex != selectedRowIndex {
                    selectedRowIndex = targetRowIndex
                }
                proxy.scrollTo(rowId, anchor: .center)
            }
        }
    }
    
    private func getSelectedItem() -> GameItem? {
        switch selectedRowIndex {
        case 0:
            return viewModel.selectedItem
        case 1:
            return viewModel.selectedFavoriteItem
        case 2:
            return viewModel.selectedNewTryoutItem
        case 3:
            return viewModel.selectedPopularInIndiaItem
        case 4:
            return viewModel.selectedPlayWithFriendsItem
        case 5:
            return viewModel.selectedPlatformsItem
        default:
            return nil
        }
    }
    
    /// Check if the currently selected game is a favorite
    private var isCurrentGameFavorite: Bool {
        guard let selectedItem = getSelectedItem(),
              case .game(let game) = selectedItem else {
            return false
        }
        return viewModel.isFavorite(gameId: game.id)
    }
    
    private var canFavoriteCurrentSelection: Bool {
        guard let selectedItem = getSelectedItem() else {
            return false
        }
        if case .game = selectedItem {
            return true
        }
        return false
    }
    
    private func setupControllerHandlers() {
        guard cancellables.isEmpty else { return }
        let focusX: CGFloat = 100
        
        // A Button - Launch/Confirm or Top Bar Action
        controllerManager.onButtonAPressed
            .sink { [weak viewModel] in
                guard coordinator.navigationPath.isEmpty else { return }
                
                // Handle top bar actions
                if isTopBarFocused {
                    if topBarSelectedIndex == 0 {
                        // Search icon
                        coordinator.navigate(to: .allGames(showSearch: true))
                    } else if topBarSelectedIndex == 1 {
                        // Controller Settings icon
                        coordinator.navigate(to: .controllerSettings)
                    } else if topBarSelectedIndex == 2 {
                        // Settings icon
                        coordinator.navigate(to: .settings)
                    } else if topBarSelectedIndex == 3 {
                        // Question mark icon (Help/Onboarding)
                        coordinator.navigate(to: .onboarding)
                    }
                    // Exit top bar mode after action
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTopBarFocused = false
                    }
                    return
                }
                
                // Handle normal game selection
                guard let viewModel = viewModel else { return }
                guard let selectedItem = getSelectedItem() else { return }
                
                switch selectedItem {
                case .allGames:
                    coordinator.navigate(to: .allGames(showSearch: false))
                case .game(let game):
                    viewModel.launchGame(game)
                }
            }
            .store(in: &cancellables)
        
        // X Button - Toggle Favourite
        controllerManager.onButtonXPressed
            .sink { [weak viewModel] in
                guard coordinator.navigationPath.isEmpty else { return }
                guard !isTopBarFocused else { return } // Don't handle favorites when in top bar mode
                guard let viewModel = viewModel else { return }
                guard canFavoriteCurrentSelection else { return }
                viewModel.toggleFavoriteForCurrentGame(inRow: selectedRowIndex)
            }
            .store(in: &cancellables)
        
        // Menu Button
        controllerManager.onMenuButtonPressed
            .sink {
                guard coordinator.navigationPath.isEmpty else { return }
                // TODO: Navigate to menu/settings
                print("Menu button pressed")
            }
            .store(in: &cancellables)
        
        // D-Pad Left - Previous game in current row or navigate top bar
        controllerManager.onDPadLeft
            .sink { [weak viewModel] in
                guard coordinator.navigationPath.isEmpty else { return }
                
                // Handle top bar navigation
                if isTopBarFocused {
                    let previousIndex = max(0, topBarSelectedIndex - 1)
                    if previousIndex != topBarSelectedIndex {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            topBarSelectedIndex = previousIndex
                        }
                    }
                    return
                }
                
                // Handle normal game navigation
                guard let viewModel = viewModel,
                      let rowProxy = rowScrollProxies[selectedRowIndex],
                      screenWidth > 0 else { return }
                
                
                // added here new
                switch selectedRowIndex {
                case 0:
                    let currentIndex = viewModel.selectedGameIndex
                    let previousIndex = max(0, currentIndex - 1)
                    
                    if previousIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectGame(at: previousIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(previousIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 1:
                    let currentIndex = viewModel.selectedFavoriteIndex
                    let previousIndex = max(0, currentIndex - 1)
                    
                    if previousIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectFavorite(at: previousIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(previousIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 2:
                    let currentIndex = viewModel.selectedNewTryoutsIndex
                    let previousIndex = max(0, currentIndex - 1)
                    
                    if previousIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectNewTryout(at: previousIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(previousIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 3:
                    let currentIndex = viewModel.selectedPopularInIndiaIndex
                    let previousIndex = max(0, currentIndex - 1)
                    
                    if previousIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectPopularInIndia(at: previousIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(previousIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 4:
                    let currentIndex = viewModel.selectedPlayWithFriendsIndex
                    let previousIndex = max(0, currentIndex - 1)
                    
                    if previousIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectPlayWithFriends(at: previousIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(previousIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 5:
                    let currentIndex = viewModel.selectedPlatformsIndex
                    let previousIndex = max(0, currentIndex - 1)
                    
                    if previousIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectPlatforms(at: previousIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(previousIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Right - Next game in current row or navigate top bar
        controllerManager.onDPadRight
            .sink { [weak viewModel] in
                guard coordinator.navigationPath.isEmpty else { return }
                
                // Handle top bar navigation
                if isTopBarFocused {
                    let nextIndex = min(3, topBarSelectedIndex + 1) // 4 icons: search (0), controller (1), settings (2), question mark (3)
                    if nextIndex != topBarSelectedIndex {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            topBarSelectedIndex = nextIndex
                        }
                    }
                    return
                }
                
                // Handle normal game navigation
                guard let viewModel = viewModel,
                      let rowProxy = rowScrollProxies[selectedRowIndex],
                      screenWidth > 0 else { return }
                
                // added here
                switch selectedRowIndex {
                case 0:
                    let currentIndex = viewModel.selectedGameIndex
                    let nextIndex = min(viewModel.gameItems.count - 1, currentIndex + 1)
                    
                    if nextIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectGame(at: nextIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(nextIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 1:
                    let currentIndex = viewModel.selectedFavoriteIndex
                    let nextIndex = min(viewModel.favoriteItems.count - 1, currentIndex + 1)
                    
                    if nextIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectFavorite(at: nextIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(nextIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 2:
                    let currentIndex = viewModel.selectedNewTryoutsIndex
                    let nextIndex = min(viewModel.newTryoutsItems.count - 1, currentIndex + 1)
                    
                    if nextIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectNewTryout(at: nextIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(nextIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 3:
                    let currentIndex = viewModel.selectedPopularInIndiaIndex
                    let nextIndex = min(viewModel.popularInIndiaItems.count - 1, currentIndex + 1)
                    
                    if nextIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectPopularInIndia(at: nextIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(nextIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 4:
                    let currentIndex = viewModel.selectedPlayWithFriendsIndex
                    let nextIndex = min(viewModel.playWithFriendsItems.count - 1, currentIndex + 1)
                    
                    if nextIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectPlayWithFriends(at: nextIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(nextIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                case 5:
                    let currentIndex = viewModel.selectedPlatformsIndex
                    let nextIndex = min(viewModel.platformsItems.count - 1, currentIndex + 1)
                    
                    if nextIndex != currentIndex {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.selectPlatforms(at: nextIndex)
                            let anchorX = focusX / screenWidth
                            rowProxy.scrollTo(nextIndex, anchor: UnitPoint(x: anchorX, y: 0.5))
                        }
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Up - Previous row or navigate to top bar
        controllerManager.onDPadUp
            .sink { [weak viewModel] in
                guard coordinator.navigationPath.isEmpty else { return }
                
                // If already in top bar, do nothing
                if isTopBarFocused {
                    return
                }
                
                // If at row 0, navigate to top bar
                if selectedRowIndex == 0 {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTopBarFocused = true
                        topBarSelectedIndex = 0 // Start with search icon
                    }
                    return
                }
                
                // Otherwise, navigate to previous row
                guard let viewModel = viewModel else { return }
                
                // Cancel auto-snap timer when using controller
                verticalSnapTimer?.invalidate()
                
                let previousRow = max(0, selectedRowIndex - 1)
                if previousRow != selectedRowIndex {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedRowIndex = previousRow
                        // Scroll vertically to show the row
                        verticalScrollProxy?.scrollTo("row-\(previousRow)", anchor: .center)
                        // Keep the same game index when switching rows
                        if let rowProxy = rowScrollProxies[previousRow],
                           screenWidth > 0 {
                            let anchorX = focusX / screenWidth
                            let indexToScroll: Int
                            switch previousRow {
                            case 0:
                                indexToScroll = viewModel.selectedGameIndex
                            case 1:
                                indexToScroll = viewModel.selectedFavoriteIndex
                            case 2:
                                indexToScroll = viewModel.selectedNewTryoutsIndex
                            case 3:
                                indexToScroll = viewModel.selectedPopularInIndiaIndex
                            case 4:
                                indexToScroll = viewModel.selectedPlayWithFriendsIndex
                            case 5:
                                indexToScroll = viewModel.selectedPlatformsIndex
                            default:
                                indexToScroll = 0
                            }
                            rowProxy.scrollTo(indexToScroll, anchor: UnitPoint(x: anchorX, y: 0.5))
                            scrollProxy = rowProxy
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        // D-Pad Down - Next row or exit top bar
        controllerManager.onDPadDown
            .sink { [weak viewModel] in
                guard coordinator.navigationPath.isEmpty else { return }
                
                // If in top bar mode, exit to row 0
                if isTopBarFocused {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isTopBarFocused = false
                    }
                    return
                }
                
                // Otherwise, navigate to next row
                guard let viewModel = viewModel else { return }
                
                // Cancel auto-snap timer when using controller
                verticalSnapTimer?.invalidate()
                
                let nextRow = min(5, selectedRowIndex + 1) // Support 6 rows (0-5)
                if nextRow != selectedRowIndex {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedRowIndex = nextRow
                        // Scroll vertically to show the row
                        verticalScrollProxy?.scrollTo("row-\(nextRow)", anchor: .center)
                        // Keep the same game index when switching rows
//                        if let rowProxy = rowScrollProxies[nextRow],
//                           screenWidth > 0 {
//                            let anchorX = focusX / screenWidth
//                            let indexToScroll = nextRow == 0 ? viewModel.selectedGameIndex : viewModel.selectedFavoriteIndex
//                            rowProxy.scrollTo(indexToScroll, anchor: UnitPoint(x: anchorX, y: 0.5))
//                            scrollProxy = rowProxy
//                        }
                        
                        // added here
                        if let rowProxy = rowScrollProxies[nextRow],
                           screenWidth > 0 {
                            let anchorX = focusX / screenWidth
                            let indexToScroll: Int
                            switch nextRow {
                            case 0:
                                indexToScroll = viewModel.selectedGameIndex
                            case 1:
                                indexToScroll = viewModel.selectedFavoriteIndex
                            case 2:
                                indexToScroll = viewModel.selectedNewTryoutsIndex
                            case 3:
                                indexToScroll = viewModel.selectedPopularInIndiaIndex
                            case 4:
                                indexToScroll = viewModel.selectedPlayWithFriendsIndex
                            case 5:
                                indexToScroll = viewModel.selectedPlatformsIndex
                            default:
                                indexToScroll = 0
                            }
                            rowProxy.scrollTo(indexToScroll, anchor: UnitPoint(x: anchorX, y: 0.5))
                            scrollProxy = rowProxy
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
}


// Game Icon View Component
struct GameItemIconView: View {
    let item: GameItem
    let isSelected: Bool
    let index: Int
    
    // Icon sizes
    private let selectedSize: CGFloat = 120
    private let unselectedSize: CGFloat = 100
    
    private var iconSize: CGFloat {
        isSelected ? selectedSize : unselectedSize
    }
    
    // Calculate horizontal offset for the title based on position
    // First item has no game to its left, so no offset needed
    // Other items need slight adjustment to account for the HStack spacing
    private var titleHorizontalOffset: CGFloat {
        index == 0 ? 0 : 0
    }
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Spacer() // Push content to bottom
            ZStack(alignment: .bottomLeading) {
                // Icon content
                if item.isAllGames {
                    // "All Games" icon - 3D cube
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "87CEEB"),
                                        Color(hex: "4169E1")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        // Grid icon instead of cube with eyes
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                            }
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                            }
                            HStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.4))
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                    .frame(width: unselectedSize, height: unselectedSize)
                    .cornerRadius(12)
                } else if case .game(let game) = item {
                    CachedAsyncImage(
                        url: game.thumbnailURL.flatMap { URL(string: $0) },
                        contentMode: .fill
                    ) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ZStack {
                            Color.gray.opacity(0.3)
                            Text(game.title)
                                .font(.caption2)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(4)
                        }
                    }
                    .frame(width: iconSize, height: iconSize)
                    .cornerRadius(12)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppTheme.Colors.accent : Color.clear, lineWidth: isSelected ? 3 : 0)
            )
            .shadow(color: isSelected ? AppTheme.Colors.accent.opacity(0.6) : Color.clear, radius: isSelected ? 15 : 0)
            .scaleEffect(isSelected ? 1.1 : 1.0, anchor: .bottom)
            .opacity(isSelected ? 1.0 : 0.75)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            
            // Game title below the icon - only show for selected items
            if isSelected {
                Text(item.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(width: selectedSize * 1.1) // Same width as scaled selected icon
                    .offset(x: titleHorizontalOffset)
                    .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 4)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            } else {
                // Placeholder to maintain consistent height
                Text(" ")
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: unselectedSize)
                    .opacity(0)
            }
        }
    }
}

// Helper component for Row Titles with Dynamic offset logic
struct SectionTitleView: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Orange vertical line
            Rectangle()
                .fill(AppTheme.Colors.accent)
                .frame(width: 3)
                .frame(height: 20)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? AppTheme.Colors.text : AppTheme.Colors.text.opacity(0.6))
                .shadow(color: Color.black.opacity(0.7), radius: 3, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 2)
        }
        // Dynamic Y Offset Calculation:
        // When row is selected, items grow UP (anchor bottom). Title stays put (0).
        // When row is UNSELECTED, items shrink DOWN. Title moves DOWN (15) to close the gap.
        .offset(y: isSelected ? 0 : 15)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    GameLibraryView()
        .environmentObject(AppCoordinator())
}
