//
//  MemoryCache.swift
import Foundation

final class MemoryCache {
    private var cache: [String: CacheItem] = [:]
    private let queue = DispatchQueue(label: "com.koyozo.memorycache", attributes: .concurrent)
    
    struct CacheItem {
        let data: Data
        let expirationDate: Date?
    }
    
    func set<T: Encodable>(_ value: T, forKey key: String, expiration: TimeInterval? = nil) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        let expirationDate = expiration.map { Date().addingTimeInterval($0) }
        
        await queue.async(flags: .barrier) {
            self.cache[key] = CacheItem(data: data, expirationDate: expirationDate)
        }
    }
    
    func get<T: Decodable>(_ type: T.Type, forKey key: String) async throws -> T? {
        let item = await queue.sync {
            return self.cache[key]
        }
        
        guard let item = item else {
            return nil
        }
        
        // Check expiration
        if let expirationDate = item.expirationDate, expirationDate < Date() {
            await remove(forKey: key)
            return nil
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: item.data)
    }
    
    func remove(forKey key: String) async {
        await queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: key)
        }
    }
    
    func clear() async {
        await queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}

