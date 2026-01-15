//
//  AppCoordinator.swift
import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    func navigate(to route: Route) {
        navigationPath.append(route)
    }
    
    func pop() {
        navigationPath.removeLast()
    }
    
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    /// Navigate to a route and clear the navigation path (useful when transitioning from auth to authenticated state)
    func navigateAndClearPath(to route: Route) {
        // Remove all items from the path first
        let count = navigationPath.count
        if count > 0 {
            navigationPath.removeLast(count)
        }
        // Then append the new route
        navigationPath.append(route)
    }
}

