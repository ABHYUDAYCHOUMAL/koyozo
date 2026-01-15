//
//  Route.swift
import Foundation

enum Route: Hashable {
    case login
    case enterPassword(email: String)
    case signup(email: String)
    case verification(email: String, type: Int = 1) // 1 = signup, 2 = reset password
    case userInformation(email: String, password: String)
    case resetPassword
    case setPassword(email: String, isSignup: Bool = false) // isSignup = true means it's part of signup flow
    case gameLibrary
    case allGames(showSearch: Bool)
    case search
    case favorites
    case profile
    case settings
}

