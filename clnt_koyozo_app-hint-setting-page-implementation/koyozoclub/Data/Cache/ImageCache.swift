//
//  ImageCache.swift
import Foundation
import UIKit

protocol ImageCacheProtocol {
    func getImage(for url: URL) async -> UIImage?
    func setImage(_ image: UIImage, for url: URL)
    func removeImage(for url: URL)
    func clearCache()
}

final class ImageCache: ImageCacheProtocol {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache: DiskCache
    private let fileManager = FileManager.default
    private let cacheQueue = DispatchQueue(label: "com.koyozo.imagecache", attributes: .concurrent)
    
    private var cacheDirectory: URL {
        let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cacheDir.appendingPathComponent("ImageCache")
    }
    
    init(diskCache: DiskCache = DiskCache()) {
        self.diskCache = diskCache
        memoryCache.countLimit = 100 // Limit memory cache to 100 images
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
        
        // Create cache directory if it doesn't exist
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getImage(for url: URL) async -> UIImage? {
        let key = url.absoluteString
        
        // Try memory cache first
        if let cachedImage = memoryCache.object(forKey: key as NSString) {
            return cachedImage
        }
        
        // Try disk cache
        return await cacheQueue.sync {
            let fileName = self.fileName(for: url)
            let fileURL = self.cacheDirectory.appendingPathComponent(fileName)
            
            guard fileManager.fileExists(atPath: fileURL.path),
                  let data = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: data) else {
                return nil
            }
            
            // Restore to memory cache
            self.memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        let key = url.absoluteString
        
        // Store in memory cache
        memoryCache.setObject(image, forKey: key as NSString)
        
        // Store in disk cache asynchronously
        cacheQueue.async(flags: .barrier) {
            guard let data = image.jpegData(compressionQuality: 0.8) else { return }
            
            let fileName = self.fileName(for: url)
            let fileURL = self.cacheDirectory.appendingPathComponent(fileName)
            
            try? data.write(to: fileURL)
        }
    }
    
    func removeImage(for url: URL) {
        let key = url.absoluteString
        memoryCache.removeObject(forKey: key as NSString)
        
        cacheQueue.async(flags: .barrier) {
            let fileName = self.fileName(for: url)
            let fileURL = self.cacheDirectory.appendingPathComponent(fileName)
            try? self.fileManager.removeItem(at: fileURL)
        }
    }
    
    func clearCache() {
        memoryCache.removeAllObjects()
        
        cacheQueue.async(flags: .barrier) {
            let files = try? self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil)
            files?.forEach { try? self.fileManager.removeItem(at: $0) }
        }
    }
    
    private func fileName(for url: URL) -> String {
        // Create a safe filename from URL
        let urlString = url.absoluteString
        let hash = urlString.hash
        let pathExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
        return "\(abs(hash)).\(pathExtension)"
    }
}

