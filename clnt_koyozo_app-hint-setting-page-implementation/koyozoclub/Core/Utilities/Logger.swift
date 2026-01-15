//
//  Logger.swift
import Foundation
import OSLog

final class Logger {
    static let shared = Logger()
    
    private let logger = os.Logger(subsystem: "com.koyozo.koyozoclub", category: "App")
    
    private init() {}
    
    func debug(_ message: String) {
        #if DEBUG
        logger.debug("\(message)")
        #endif
    }
    
    func info(_ message: String) {
        logger.info("\(message)")
    }
    
    func warning(_ message: String) {
        logger.warning("\(message)")
    }
    
    func error(_ message: String) {
        logger.error("\(message)")
    }
}

