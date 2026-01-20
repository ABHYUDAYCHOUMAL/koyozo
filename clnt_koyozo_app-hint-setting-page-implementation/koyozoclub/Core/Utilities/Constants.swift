//
//  Constants.swift
import Foundation

enum Constants {
    // App-wide constants
    
    /// API Configuration
    /// Note: Base URL is configured in Config.plist
    enum API {
        /// Default number of games per page for pagination
        static let defaultPageSize = 20
        
        /// Number of top games to show on Dashboard (first row only)
        static let dashboardGameCount = 10
        
        /// Default sort field for games
        /// Note: Backend automatically filters games with popularity_score < 1
        static let defaultSortBy = "popularity_score"
        
        /// Default sort order for games
        static let defaultSortOrder = "desc"
    }
    
    /// Cache Configuration
    enum Cache {
        /// Maximum number of games to cache locally
        static let maxCachedGames = 100
        
        /// Cache expiration time in seconds (1 hour)
        static let cacheExpirationSeconds: TimeInterval = 3600
    }
}

