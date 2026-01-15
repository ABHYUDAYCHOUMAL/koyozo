//
//  CardView.swift
import SwiftUI

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}

#Preview {
    CardView {
        Text("Card Content")
            .padding()
    }
}

