//
//  GameItem.swift
import Foundation

enum GameItem: Identifiable, Hashable {
    case game(Game)
    case allGames
    
    var id: String {
        switch self {
        case .game(let game):
            return game.id
        case .allGames:
            return "all_games"
        }
    }
    
    var title: String {
        switch self {
        case .game(let game):
            return game.title
        case .allGames:
            return "All Games"
        }
    }
    
    var thumbnailURL: String? {
        switch self {
        case .game(let game):
            return game.thumbnailURL
        case .allGames:
            return "" // Will use default background
        }
    }
    
    var isAllGames: Bool {
        if case .allGames = self {
            return true
        }
        return false
    }
}

