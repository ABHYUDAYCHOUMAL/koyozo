//
//  HintButton.swift
import SwiftUI

struct HintButton: View {
    let buttonText: String
    let labelText: String
    let action: (() -> Void)?
    let buttonColor: Color
    let buttonSize: CGFloat
    let fontSize: CGFloat
    
    init(
        buttonText: String,
        labelText: String,
        buttonColor: Color = AppTheme.Colors.primary,
        buttonSize: CGFloat = 22,
        fontSize: CGFloat = 10,
        action: (() -> Void)? = nil
    ) {
        self.buttonText = buttonText
        self.labelText = labelText
        self.action = action
        self.buttonColor = buttonColor
        self.buttonSize = buttonSize
        self.fontSize = fontSize
    }
    
    var body: some View {
        let isStartButton = labelText.lowercased() == "start"
        let circleColor = isStartButton ? AppTheme.Colors.accent : AppTheme.Colors.white
        let textColor = isStartButton ? AppTheme.Colors.white : AppTheme.Colors.darkBlue
        
        return Button(action: { action?() }) {
            HStack(spacing: Spacing.sm) {
                // Round button
                ZStack {
                    Circle()
                        .fill(circleColor)
                        .frame(width: buttonSize, height: buttonSize)
                    
                    Text(buttonText)
                        .font(.system(size: fontSize, weight: .bold))
                        .foregroundColor(textColor)
                }
                
                Text(labelText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.Colors.white)
            }
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xs)
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        VStack(spacing: Spacing.md) {
            HintButton(
                buttonText: "A",
                labelText: "Confirm",
                action: {
                    print("A pressed")
                }
            )
            
            HintButton(
                buttonText: "A",
                labelText: "Start",
                action: {
                    print("Start pressed")
                }
            )
            
            HintButton(
                buttonText: "Y",
                labelText: "Search",
                action: {
                    print("Y pressed")
                }
            )
        }
        .padding()
    }
}

