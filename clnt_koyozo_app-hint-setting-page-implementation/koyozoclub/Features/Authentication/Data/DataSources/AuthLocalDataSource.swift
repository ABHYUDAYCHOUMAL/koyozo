//
//  AuthLocalDataSource.swift
import Foundation

protocol AuthLocalDataSourceProtocol {
    func saveToken(_ token: AuthToken) async throws
    func getToken() async throws -> AuthToken?
    func clearToken() async throws
}

final class AuthLocalDataSource: AuthLocalDataSourceProtocol {
    private let keychainManager: KeychainManager
    private let tokenKey = "auth_token"
    
    init(keychainManager: KeychainManager? = nil) {
        self.keychainManager = keychainManager ?? KeychainManager()
    }
    
    func saveToken(_ token: AuthToken) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(token)
        try keychainManager.save(data, forKey: tokenKey)
    }
    
    func getToken() async throws -> AuthToken? {
        guard let data = try keychainManager.fetch(forKey: tokenKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(AuthToken.self, from: data)
    }
    
    func clearToken() async throws {
        try keychainManager.delete(forKey: tokenKey)
    }
}

