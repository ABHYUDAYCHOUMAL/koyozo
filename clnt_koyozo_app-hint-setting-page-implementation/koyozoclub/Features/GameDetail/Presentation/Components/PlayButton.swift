//
//  PlayButton.swift
import SwiftUI

struct PlayButton: View {
    let action: () -> Void
    
    var body: some View {
        PrimaryButton(title: "Play Now") {
            action()
        }
    }
}

#Preview {
    PlayButton {
        print("Play tapped")
    }
}

