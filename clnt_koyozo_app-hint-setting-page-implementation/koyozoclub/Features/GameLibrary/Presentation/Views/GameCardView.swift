//
//  GameCardView.swift
import SwiftUI

struct GameCardView: View {
    let game: Game
    let isFocused: Bool
    var onTap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Game thumbnail - rectangular shape (wider, less tall)
            CachedAsyncImage(
                url: game.thumbnailURL.flatMap { URL(string: $0) },
                contentMode: .fill
            ) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(AppTheme.Colors.secondary.opacity(0.3))
            }
            .frame(height: 80)
            .clipped()
            .cornerRadius(12)
            .overlay(
                // Glowing border when focused - only around the image
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? AppTheme.Colors.accent : Color.clear,
                        lineWidth: isFocused ? 3 : 0
                    )
                    .shadow(
                        color: isFocused ? AppTheme.Colors.accent.opacity(0.8) : Color.clear,
                        radius: isFocused ? 10 : 0
                    )
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
            
            // Game title with marquee - always show
            MarqueeText(
                text: game.title,
                font: .system(size: 12, weight: .semibold),
                color: AppTheme.Colors.text,
                animationDuration: 8.0
            )
            .frame(maxWidth: .infinity)
            .frame(height: 20)
            .clipped()
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isFocused)
        .onTapGesture {
            onTap?()
        }
    }
}

// Helper extension for corner radius on specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        GameCardView(
            game: Game(
                id: "1",
                title: "This is a very long game title that will scroll",
                category: "Action, Adventure, Platformer",
                customURLScheme: "",
                thumbnailURL: "https://via.placeholder.com/400x600/0066FF/FFFFFF?text=Game",
                backgroundURL: nil,
                description: nil,
                launchURL: "sample://",
                appStoreID: "123456789"
            ),
            isFocused: true
        )
        .frame(width: 150)
        .padding()
    }
}

