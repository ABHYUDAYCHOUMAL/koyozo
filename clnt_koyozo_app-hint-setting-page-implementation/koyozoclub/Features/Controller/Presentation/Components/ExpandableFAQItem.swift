//
//  ExpandableFAQItem.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  ExpandableFAQItem.swift
import SwiftUI

struct ExpandableFAQItem: View {
    let faqItem: FAQItem
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Question header (clickable)
            Button(action: onToggle) {
                HStack {
                    Text(faqItem.question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "minus" : "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, Spacing.md)
                .padding(.horizontal, Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            // Answer content (expandable)
            if isExpanded {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    switch faqItem.answer {
                    case .text(let text):
                        Text(text)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .fixedSize(horizontal: false, vertical: true)
                        
                    case .steps(let steps):
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: Spacing.sm) {
                                if step.hasPrefix("  •") {
                                    // Sub-item (bullet point)
                                    Text("•")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.leading, Spacing.md)
                                    Text(step.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "• ", with: ""))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                        .fixedSize(horizontal: false, vertical: true)
                                } else if step.contains(":") && !step.contains("(") {
                                    // Item with colon (like "Check Home light:")
                                    Text(step)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                } else {
                                    // Regular numbered step
                                    Text(step)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        
                    case .stepsWithTable(let steps, let table):
                        ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                            Text(step)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        if let table = table {
                            ControllerInfoTableView(table: table)
                                .padding(.top, Spacing.sm)
                        }
                        
                    case .multiSection(let sections):
                        ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                            if let title = section.title {
                                Text(title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.top, Spacing.xs)
                            }
                            
                            ForEach(Array(section.items.enumerated()), id: \.offset) { _, item in
                                HStack(alignment: .top, spacing: Spacing.sm) {
                                    Text("•")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                    Text(item)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.6))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.leading, Spacing.sm)
                            }
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        VStack(spacing: Spacing.md) {
            ExpandableFAQItem(
                faqItem: FAQItem(
                    question: "Bluetooth not pairing",
                    answer: .steps([
                        "Double-press M → Home light turns Blue.",
                        "Check Home light:",
                        "  • Blue Breathing = reconnecting",
                        "  • Blue Fast Flashing = searching"
                    ])
                ),
                isExpanded: true,
                onToggle: {}
            )
            
            ExpandableFAQItem(
                faqItem: FAQItem(
                    question: "USB not recognized",
                    answer: .text("Remove your phone's case cover and try reconnecting.")
                ),
                isExpanded: false,
                onToggle: {}
            )
        }
        .padding()
    }
}
