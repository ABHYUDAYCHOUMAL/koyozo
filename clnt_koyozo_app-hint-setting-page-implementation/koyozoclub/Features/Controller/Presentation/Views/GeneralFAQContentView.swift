//
//  GeneralFAQContentView.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//
//
//  GeneralFAQContentView.swift
import SwiftUI

struct GeneralFAQContentView: View {
    let faqItems: [FAQItem]
    let expandedIds: Set<UUID>
    let onToggle: (UUID) -> Void
    let isLoading: Bool
    let errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                if isLoading {
                    // Loading state
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("Loading FAQs...")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, Spacing.sm)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else if let errorMessage = errorMessage {
                    // Error state
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text("Failed to Load FAQs")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Text(errorMessage)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                    .padding(.horizontal, Spacing.lg)
                } else if faqItems.isEmpty {
                    // Empty state
                    VStack(spacing: Spacing.md) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.white.opacity(0.3))
                        Text("No FAQs Available")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    // Success state - show FAQs
                    ForEach(faqItems) { item in
                        ExpandableFAQItem(
                            faqItem: item,
                            isExpanded: expandedIds.contains(item.id),
                            onToggle: { onToggle(item.id) }
                        )
                    }
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
        
        GeneralFAQContentView(
            faqItems: [
                FAQItem(
                    question: "Which devices does Koyozo One work with?",
                    answer: .multiSection([
                        FAQSection(title: "iOS (Purple Mode)", items: [
                            "iPhone, iPad (iOS 13+)",
                            "Apple TV"
                        ])
                    ])
                )
            ],
            expandedIds: [],
            onToggle: { _ in },
            isLoading: false,
            errorMessage: nil
        )
    }
}
