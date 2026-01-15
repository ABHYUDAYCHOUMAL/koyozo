//
//  DashboardHintView.swift
import SwiftUI

struct DashboardHintView: View {
    let hint: String
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill")
            Text(hint)
                .font(.caption)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    DashboardHintView(hint: "Tap on a game to view details")
}

