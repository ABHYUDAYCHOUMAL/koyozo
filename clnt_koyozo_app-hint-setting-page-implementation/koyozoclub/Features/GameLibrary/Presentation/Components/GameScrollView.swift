//
//  GameScrollView.swift
import SwiftUI

// Preference Key for tracking scroll offsets
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct GameScrollView: View {
    let gameItems: [GameItem]
    let selectedIndex: Int
    let geometry: GeometryProxy
    let onGameSelected: (Int) -> Void
    let onAllGamesTapped: () -> Void
    let onGameLaunched: (() -> Void)?
    let onScrollOffsetChanged: ([Int: CGFloat]) -> Void
    let onScrollEnded: (ScrollViewProxy, [Int: CGFloat]) -> Void
    let onProxyReady: ((ScrollViewProxy) -> Void)?
    
    @State private var lastScrollOffsets: [Int: CGFloat] = [:]
    @State private var snapTimer: Timer?
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: Spacing.lg) {
                    Spacer()
                        .frame(width: 40)
                    ForEach(Array(gameItems.enumerated()), id: \.element.id) { index, item in
                        GameItemIconView(
                            item: item,
                            isSelected: index == selectedIndex,
                            index: index
                        )
                        .id(index)
                        .frame(height: 200, alignment: .bottom)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: [index: geo.frame(in: .named("scroll")).minX]
                                    )
                            }
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if item.isAllGames {
                                    onAllGamesTapped()
                                } else {
                                    // If already selected, launch the game; otherwise just select it
                                    if index == selectedIndex {
                                        onGameLaunched?()
                                    } else {
                                        onGameSelected(index)
                                    }
                                }
                                let focusX: CGFloat = 100
                                let anchorX = focusX / geometry.size.width
                                proxy.scrollTo(index, anchor: UnitPoint(x: anchorX, y: 0.5))
                            }
                        }
                    }
                }
                .padding(.leading, 0)
                .padding(.trailing, geometry.size.width - 200)
                .padding(.vertical, Spacing.xl)
            }
            .coordinateSpace(name: "scroll")
            .contentShape(Rectangle())
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offsets in
                lastScrollOffsets = offsets
                onScrollOffsetChanged(offsets)
                
                snapTimer?.invalidate()
                let proxyCopy = proxy
                let offsetsCopy = offsets
                snapTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                    onScrollEnded(proxyCopy, offsetsCopy)
                }
            }
            .onAppear {
                if !gameItems.isEmpty {
                    let focusX: CGFloat = 100
                    let anchorX = focusX / geometry.size.width
                    proxy.scrollTo(0, anchor: UnitPoint(x: anchorX, y: 0.5))
                }
                // Notify parent that proxy is ready
                onProxyReady?(proxy)
            }
        }
    }
}

