//
//  GameScreenshotsView.swift
import SwiftUI

struct GameScreenshotsView: View {
    let screenshots: [GameScreenshot]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(screenshots) { screenshot in
                    AsyncImage(url: URL(string: screenshot.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 200, height: 150)
                    .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    GameScreenshotsView(screenshots: [])
}

