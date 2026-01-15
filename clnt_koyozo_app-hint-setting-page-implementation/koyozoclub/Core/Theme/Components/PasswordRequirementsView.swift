//
//  PasswordRequirementsView.swift
import SwiftUI

struct PasswordRequirementsView: View {
    let requirements: [PasswordRequirement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Your password must contain")
                .font(.caption2)
                .foregroundColor(AppTheme.Colors.white)
            
            ForEach(Array(requirements.enumerated()), id: \.offset) { index, requirement in
                HStack(alignment: .top, spacing: 4) {
                    Text("•")
                        .foregroundColor(
                            requirement.isMet ? .green :
                            requirement.showError ? .red :
                            AppTheme.Colors.white
                        )
                        .font(.caption2)
                    
                    Text(requirement.text)
                        .font(.caption2)
                        .foregroundColor(
                            requirement.isMet ? .green :
                            requirement.showError ? .red :
                            AppTheme.Colors.white
                        )
                }
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.darkBlue)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.Colors.white, lineWidth: 1)
        )
    }
}

#Preview {
    PasswordRequirementsView(requirements: [
        PasswordRequirement(text: "8 characters", isMet: true),
        PasswordRequirement(text: "1 number", isMet: false, showError: true)
    ])
    .padding()
    .background(AppTheme.Colors.darkBlue)
}

