//
//  GoogleSignInButton.swift
import SwiftUI

struct GoogleSignInButton: View {
    let isFocused: Bool
    let action: () -> Void
    
    init(isFocused: Bool = false, action: @escaping () -> Void) {
        self.isFocused = isFocused
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Google Logo
                Image("GoogleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                Text("Continue with Google")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(AppTheme.Colors.inputBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.Colors.primary, lineWidth: isFocused ? 3 : 1)
            )
            .scaleEffect(isFocused ? 1.05 : 1.0)
        }
    }
}

#Preview {
    GoogleSignInButton(isFocused: false) {
        print("Google Sign-In tapped")
    }
}

