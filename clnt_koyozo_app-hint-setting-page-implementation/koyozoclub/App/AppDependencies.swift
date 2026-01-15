//
//  AppDependencies.swift
import Foundation

/// Dependency injection container for the app
final class AppDependencies {
    
    // MARK: - Singleton
    static let shared = AppDependencies()
    
    // MARK: - Configuration
    private var baseURL: String {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let url = plist["API_BASE_URL"] as? String else {
            return ""
        }
        return url
    }
    
    // MARK: - Network
    lazy var apiClient: APIClient = {
        APIClient(baseURL: baseURL)
    }()
    
    // MARK: - Storage
    lazy var keychainManager: KeychainManager = {
        KeychainManager()
    }()
    
    lazy var userDefaultsManager: UserDefaultsManager = {
        UserDefaultsManager()
    }()
    
    // MARK: - Cache
    lazy var cacheManager: CacheManager = {
        CacheManager()
    }()
    
    // MARK: - Repositories
    // Add repository instances here as they are created
    
    private init() {}
}

