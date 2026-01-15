//
//  PrimaryButton.swift
import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isFocused: Bool
    let action: () -> Void
    var isDisabled: Bool = false
    
    init(title: String, isFocused: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isFocused = isFocused
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(isDisabled ? Color.gray.opacity(0.5) : AppTheme.Colors.primary)
                .foregroundColor(isDisabled ? Color.white.opacity(0.6) : .white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused && !isDisabled ? Color.white : Color.clear, lineWidth: isFocused && !isDisabled ? 3 : 0)
                )
                .scaleEffect(isFocused && !isDisabled ? 1.05 : 1.0)
        }
        .disabled(isDisabled)
    }
}

#Preview {
    PrimaryButton(title: "Button") {
        print("Tapped")
    }
}

