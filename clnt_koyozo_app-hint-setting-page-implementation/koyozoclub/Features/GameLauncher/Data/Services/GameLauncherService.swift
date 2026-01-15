//
//  GameLauncherService.swift
import Foundation
import UIKit

protocol GameLauncherServiceProtocol {
    func launch(game: Game)
}

final class GameLauncherService: GameLauncherServiceProtocol {
    func launch(game: Game) {
        // Safely unwrap launch URL; fallback to App Store if missing/invalid
        guard let launchURLString = game.launchURL,
              let appURL = URL(string: launchURLString) else {
            openAppStore(for: game.appStoreID)
            return
        }
        
        // Build App Store URL for fallback
        let storeURL = URL(string: "https://apps.apple.com/app/id\(game.appStoreID)")
        
        // Try to open the app first
        // Note: canOpenURL may return false for custom schemes not in Info.plist,
        // so we try opening and use completion handler to detect failure
        UIApplication.shared.open(appURL, options: [:]) { success in
            if !success, let storeURL = storeURL {
                // Failed to open app → open App Store
                UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func openAppStore(for appStoreID: String) {
        guard let storeURL = URL(string: "https://apps.apple.com/app/id\(appStoreID)") else { return }
        UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
    }
}

