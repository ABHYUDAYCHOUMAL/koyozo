//
//  ControllerTestingContentView.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  ControllerTestingContentView.swift
import SwiftUI

struct ControllerTestingContentView: View {
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            Text("Controller testing steps")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            // Steps list
            VStack(alignment: .leading, spacing: Spacing.sm) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: Spacing.sm) {
                        Text("\(index + 1).")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text(step)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Video/Image placeholder
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .frame(height: 280)
                .overlay(
                    VStack {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        Text("Controller Testing Video")
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
        
        ControllerTestingContentView(
            steps: [
                "Open Controller Testing in the app.",
                "Press any button",
                "Move a joystick",
                "Press triggers (L2/R2)",
                "Check Home & Turbo lights"
            ]
        )
    }
}
