//
//  GameLibraryBackgroundView.swift
import SwiftUI

struct GameLibraryBackgroundView: View {
    let selectedItem: GameItem?
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            if let item = selectedItem {
                if item.isAllGames {
                    // For "All Games", use a light orange gradient background
                    LinearGradient(
                        colors: [
                            Color(hex: "FFE5CC"), // Very light peach/cream
                            Color(hex: "FFB366"), // Light orange
                            Color(hex: "FF8533")  // Medium bright orange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    .transition(.opacity.animation(.easeInOut(duration: 0.5)))
                } else if case .game(let game) = item {
                    // Use backgroundURL if available, fallback to thumbnailURL
                    let imageURLString = game.backgroundURL ?? game.thumbnailURL
                    
                    if let imageURLString = imageURLString,
                       let imageURL = URL(string: imageURLString) {
                        CachedAsyncImage(
                            url: imageURL,
                            contentMode: .fill
                        ) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .brightness(-0.1) // Darken the background image
                                .saturation(0.9) // Slightly desaturate for darker effect
                                .blur(radius: 0.1) // Add blur to hide quality issues and create depth
                                // Adjust blur radius: 4-6 (subtle), 8-10 (moderate), 12-15 (strong)
                                // Optional: Add contrast for more pop - uncomment next line
                                // .contrast(1.1)
                        } placeholder: {
                            // Use same dark color as fallback to prevent brightness flash
                            AppTheme.Colors.darkBlue
                                .brightness(-0.2) // Keep placeholder dark too
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .id(imageURLString) // Use URL as ID for proper view identity tracking
                    } else {
                        // Fallback background if URLs are missing
                        AppTheme.Colors.darkBlue
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .ignoresSafeArea()
                    }
                }
            } else {
                AppTheme.Colors.darkBlue
            }
            
            // Gradient overlay for text readability - darker at top and bottom, lighter in middle
            LinearGradient(
                stops: [
                    .init(color: Color.black.opacity(0.55), location: 0.0),      // Top - very dark
                    .init(color: Color.black.opacity(0.25), location: 0.3),      // Upper-middle - less dark
                    .init(color: Color.black.opacity(0.05), location: 0.5),      // Center - least dark (but still dark)
                    .init(color: Color.black.opacity(0.25), location: 0.7),      // Lower-middle - less dark
                    .init(color: Color.black.opacity(0.55), location: 1.0)       // Bottom - very dark
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

