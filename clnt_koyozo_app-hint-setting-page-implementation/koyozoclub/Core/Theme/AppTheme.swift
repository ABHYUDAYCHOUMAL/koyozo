//
//  AppTheme.swift
import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "E0552E") // Orange for primary buttons
        static let secondary = Color(hex: "6C757D") // Gray for secondary
        static let accent = Color(hex: "FF6600") // Orange - secondary brand color
        static let background = Color(hex: "1F1F1F")
        static let text = Color.white
        static let darkBlue = Color(hex: "1A1A1A")
        static let white = Color.white
        static let linkBlue = Color(hex: "E0552E") // For links and actionable text
        
        // Surfaces / inputs (auth theme)
        static let surface = Color(hex: "1F1F1F")
        static let inputBackground = Color(hex: "1F1F1F")
        static let inputBorder = Color.white.opacity(0.35)
        static let inputBorderFocused = primary
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle
        static let title = Font.title
        static let body = Font.body
        static let caption = Font.caption
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
    }
}

