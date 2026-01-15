//
//  MarqueeText.swift
import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font
    let color: Color
    let animationDuration: Double
    
    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var needsScrolling: Bool = false
    
    init(
        text: String,
        font: Font = .caption,
        color: Color = AppTheme.Colors.darkBlue,
        animationDuration: Double = 8.0
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.animationDuration = animationDuration
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Always use scrolling text (no truncation with "...")
                HStack(spacing: 30) {
                    Text(text)
                        .font(font)
                        .foregroundColor(color)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    // Only show duplicate if text needs scrolling
                    if needsScrolling {
                        Text(text) // Duplicate for seamless loop
                            .font(font)
                            .foregroundColor(color)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .offset(x: needsScrolling ? offset : 0)
                .onAppear {
                    if needsScrolling {
                        startAnimation()
                    }
                }
            }
            .frame(width: geometry.size.width)
            .background(
                // Measure text width - use fixedSize to get actual width
                Text(text)
                    .font(font)
                    .fixedSize(horizontal: true, vertical: false)
                    .background(
                        GeometryReader { textGeometry in
                            Color.clear
                                .onAppear {
                                    textWidth = textGeometry.size.width
                                    containerWidth = geometry.size.width
                                    needsScrolling = textWidth > containerWidth
                                    if needsScrolling {
                                        offset = 0
                                        startAnimation()
                                    }
                                }
                                .onChange(of: geometry.size.width) { newWidth in
                                    containerWidth = newWidth
                                    let wasScrolling = needsScrolling
                                    needsScrolling = textWidth > newWidth
                                    
                                    if needsScrolling && !wasScrolling {
                                        // Just started needing scroll
                                        offset = 0
                                        startAnimation()
                                    } else if !needsScrolling {
                                        // No longer needs scroll, reset
                                        offset = 0
                                    }
                                }
                        }
                    )
                    .opacity(0)
            )
            .clipped()
        }
        .frame(height: 20) // Fixed height for text
    }
    
    private func startAnimation() {
        guard needsScrolling, textWidth > 0 else { return }
        
        // Reset offset
        offset = 0
        
        // Start animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.linear(duration: animationDuration).repeatForever(autoreverses: false)) {
                offset = -textWidth - 30 // Move left by text width + spacing
            }
        }
    }
}

#Preview {
    VStack {
        MarqueeText(text: "Short Text")
        MarqueeText(text: "This is a very long game title that will scroll horizontally")
            .frame(width: 100)
    }
    .padding()
}

