//
//  AppTheme.swift
import SwiftUI

struct AppTheme {
    // MARK: - Colors
    struct Colors {
        static let primary = Color(hex: "0066FF") // Blue for primary buttons
        static let secondary = Color(hex: "6C757D") // Gray for secondary
        static let accent = Color(hex: "FF6600") // Orange - secondary brand color
        static let background = Color(hex: "000637")
        static let text = Color.white
        static let darkBlue = Color(hex: "000637")
        static let white = Color.white
        static let linkBlue = Color(hex: "000637") // For links and actionable text
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

