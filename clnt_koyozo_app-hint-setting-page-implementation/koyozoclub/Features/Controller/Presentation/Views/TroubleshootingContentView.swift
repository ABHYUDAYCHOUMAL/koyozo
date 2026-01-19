//
//  TroubleshootingContentView.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  TroubleshootingContentView.swift
import SwiftUI

struct TroubleshootingContentView: View {
    let faqItems: [FAQItem]
    let expandedIds: Set<UUID>
    let onToggle: (UUID) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                ForEach(faqItems) { item in
                    ExpandableFAQItem(
                        faqItem: item,
                        isExpanded: expandedIds.contains(item.id),
                        onToggle: { onToggle(item.id) }
                    )
                }
            }
            .padding(Spacing.lg)
        }
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        TroubleshootingContentView(
            faqItems: [
                FAQItem(
                    question: "Bluetooth not pairing",
                    answer: .steps([
                        "Double-press M → Home light turns Blue.",
                        "Check Home light:",
                        "  • Blue Breathing = reconnecting"
                    ])
                ),
                FAQItem(
                    question: "USB not recognized",
                    answer: .text("Remove your phone's case cover.")
                )
            ],
            expandedIds: [],
            onToggle: { _ in }
        )
    }
}
