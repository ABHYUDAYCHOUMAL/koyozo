//
//  ScreenMappingContentView.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  ScreenMappingContentView.swift
import SwiftUI

struct ScreenMappingContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Screenmapping")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            // Video/Image placeholder for screen mapping
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .frame(height: 400)
                .overlay(
                    VStack {
                        Image(systemName: "map.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        Text("Screen Mapping Guide")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, Spacing.sm)
                    }
                )
            
            Spacer()
        }
        .padding(Spacing.lg)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        ScreenMappingContentView()
    }
}
