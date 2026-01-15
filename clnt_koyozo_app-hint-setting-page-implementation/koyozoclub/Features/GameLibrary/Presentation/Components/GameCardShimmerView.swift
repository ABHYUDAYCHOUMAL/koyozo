//
//  GameCardShimmerView.swift
import SwiftUI

struct GameCardShimmerView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Game thumbnail shimmer - matches GameCardView structure
            Rectangle()
                .fill(AppTheme.Colors.secondary.opacity(0.3))
                .frame(height: 80)
                .cornerRadius(12)
                .shimmer()
            
            // Game title area - blank space
            Color.clear
                .frame(height: 20)
        }
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        GameCardShimmerView()
            .frame(width: 150)
            .padding()
    }
}
