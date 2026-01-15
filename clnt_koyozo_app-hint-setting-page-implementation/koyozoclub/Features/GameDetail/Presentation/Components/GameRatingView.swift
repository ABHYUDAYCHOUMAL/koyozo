//
//  GameRatingView.swift
import SwiftUI

struct GameRatingView: View {
    let rating: Double
    
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            Text(String(format: "%.1f", rating))
                .font(.subheadline)
        }
    }
}

#Preview {
    GameRatingView(rating: 4.5)
}

