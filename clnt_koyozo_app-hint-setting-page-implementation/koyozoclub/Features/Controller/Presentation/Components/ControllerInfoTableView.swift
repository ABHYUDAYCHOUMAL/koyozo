//
//  ControllerInfoTableView.swift
//  koyozoclub
//
//  Created by Rakshit Kanwal on 17/01/26.
//

//
//  ControllerInfoTableView.swift
import SwiftUI

struct ControllerInfoTableView: View {
    let table: FAQTable
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                ForEach(Array(table.headers.enumerated()), id: \.offset) { index, header in
                    Text(header)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.xs)
                        .background(Color.white.opacity(0.1))
                    
                    if index < table.headers.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.2))
                    }
                }
            }
            
            // Data rows
            ForEach(Array(table.rows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { colIndex, cell in
                        Text(cell)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.xs)
                            .background(rowIndex % 2 == 0 ? Color.clear : Color.white.opacity(0.03))
                        
                        if colIndex < row.count - 1 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                        }
                    }
                }
                
                if rowIndex < table.rows.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.1))
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

#Preview {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()
        
        ControllerInfoTableView(
            table: FAQTable(
                headers: ["Mode", "Turbo LED", "Home LED"],
                rows: [
                    ["iOS", "Purple (#A615EA)", "BT Connected: Blue"],
                    ["Android HID", "Green (#35D200)", "BT Reconnecting: Blue"],
                    ["Switch Mode", "Red (#EC354C)", "USB: Purple"]
                ]
            )
        )
        .padding()
    }
}
