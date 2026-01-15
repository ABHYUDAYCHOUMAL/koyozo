//
//  GameTitleView.swift
import SwiftUI

struct GameTitleView: View {
    let title: String
    let selectedGameIndex: Int
    
    var body: some View {
        Text(title)
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, Spacing.lg)
            .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)
            .shadow(color: Color.black.opacity(0.6), radius: 8, x: 0, y: 4)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.3), value: selectedGameIndex)
    }
}

