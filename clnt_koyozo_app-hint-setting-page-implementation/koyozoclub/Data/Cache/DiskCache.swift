//
//  DiskCache.swift
import Foundation

final class DiskCache {
    private let cacheDirectory: URL
    
    init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = cacheDir.appendingPathComponent("KoyozoCache")
        
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func set<T: Encodable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        let fileURL = cacheDirectory.appendingPathComponent(key)
        try data.write(to: fileURL)
        
        // Store expiration date if provided
        if let expiration = expiration {
            let expirationDate = Date().addingTimeInterval(expiration)
            let expirationURL = cacheDirectory.appendingPathComponent("\(key).expiration")
            let expirationData = try JSONEncoder().encode(expirationDate)
            try expirationData.write(to: expirationURL)
        }
    }
    
    func get<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        // Check expiration
        let expirationURL = cacheDirectory.appendingPathComponent("\(key).expiration")
        if FileManager.default.fileExists(atPath: expirationURL.path) {
            if let expirationData = try? Data(contentsOf: expirationURL),
               let expirationDate = try? JSONDecoder().decode(Date.self, from: expirationData),
               expirationDate < Date() {
                try? await remove(forKey: key)
                return nil
            }
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    func remove(forKey key: String) async throws {
        let fileURL = cacheDirectory.appendingPathComponent(key)
        let expirationURL = cacheDirectory.appendingPathComponent("\(key).expiration")
        
        try? FileManager.default.removeItem(at: fileURL)
        try? FileManager.default.removeItem(at: expirationURL)
    }
    
    func clear() async throws {
        let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for file in files {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

