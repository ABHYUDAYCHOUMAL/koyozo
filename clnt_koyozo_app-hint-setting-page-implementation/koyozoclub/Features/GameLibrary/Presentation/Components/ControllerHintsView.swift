//
//  ControllerHintsView.swift
import SwiftUI

struct ControllerHintsView: View {
    let onConfirmTap: (() -> Void)?
    let onFavoriteTap: (() -> Void)?
    let isFavorite: Bool
    let showsFavorite: Bool
    
    init(
        onConfirmTap: (() -> Void)? = nil,
        onFavoriteTap: (() -> Void)? = nil,
        isFavorite: Bool = false,
        showsFavorite: Bool = true
    ) {
        self.onConfirmTap = onConfirmTap
        self.onFavoriteTap = onFavoriteTap
        self.isFavorite = isFavorite
        self.showsFavorite = showsFavorite
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: Spacing.lg) {
                Spacer()
                
                if showsFavorite {
                    HintButton(
                        buttonText: "X",
                        labelText: isFavorite ? "Unfavourite" : "Favourite",
                        action: onFavoriteTap
                    )
                }
                
                HintButton(
                    buttonText: "A",
                    labelText: "Confirm",
                    action: onConfirmTap
                )
            }
            .padding(.trailing, Spacing.lg)
            .padding(.bottom, Spacing.lg)
        }
    }
}

