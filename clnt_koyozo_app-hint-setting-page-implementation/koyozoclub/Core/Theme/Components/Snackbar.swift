//
//  Snackbar.swift
import SwiftUI

struct Snackbar: View {
    let message: String
    @Binding var isShowing: Bool
    var duration: Double = 3.0
    
    var body: some View {
        VStack {
            if isShowing {
                HStack(spacing: Spacing.sm) {
                    Text(message)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background {
                    // iOS-native blur effect
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.top, Spacing.md)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
            
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
        .onChange(of: isShowing) { oldValue, newValue in
            if newValue {
                // Auto-dismiss after duration
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isShowing = false
                    }
                }
            }
        }
    }
}

