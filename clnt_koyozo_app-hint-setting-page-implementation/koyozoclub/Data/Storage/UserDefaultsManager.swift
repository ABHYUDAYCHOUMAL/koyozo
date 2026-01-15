//
//  UserDefaultsManager.swift
import Foundation

protocol UserDefaultsManagerProtocol {
    func save<T: Codable>(_ value: T, forKey key: String) async throws
    func fetch<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T?
    func delete(forKey key: String) async throws
}

final class UserDefaultsManager: UserDefaultsManagerProtocol {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save<T: Codable>(_ value: T, forKey key: String) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        userDefaults.set(data, forKey: key)
    }
    
    func fetch<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    func delete(forKey key: String) async throws {
        userDefaults.removeObject(forKey: key)
    }
}

