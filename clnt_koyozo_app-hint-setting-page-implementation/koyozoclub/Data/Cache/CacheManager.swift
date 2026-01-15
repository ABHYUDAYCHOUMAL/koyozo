//
//  CacheManager.swift
import Foundation

protocol CacheManagerProtocol {
    func set<T: Encodable>(_ value: T, forKey key: String, expiration: TimeInterval?) async throws
    func get<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
    func clear() async throws
}

final class CacheManager: CacheManagerProtocol {
    private let memoryCache: MemoryCache
    private let diskCache: DiskCache
    
    init(memoryCache: MemoryCache = MemoryCache(), diskCache: DiskCache = DiskCache()) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
    
    func set<T: Encodable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) async throws {
        try await memoryCache.set(value, forKey: key, expiration: expiration)
        try await diskCache.set(value, forKey: key, expiration: expiration)
    }
    
    func get<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        // Try memory first
        if let value = try await memoryCache.get(type, forKey: key) {
            return value
        }
        
        // Try disk
        if let value = try await diskCache.get(type, forKey: key) {
            // Restore to memory
            try await memoryCache.set(value, forKey: key)
            return value
        }
        
        return nil
    }
    
    func remove(forKey key: String) async throws {
        try await memoryCache.remove(forKey: key)
        try await diskCache.remove(forKey: key)
    }
    
    func clear() async throws {
        try await memoryCache.clear()
        try await diskCache.clear()
    }
}

