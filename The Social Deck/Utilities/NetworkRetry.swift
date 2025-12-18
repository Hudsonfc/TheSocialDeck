//
//  NetworkRetry.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

/// Retry network operations with exponential backoff
actor NetworkRetry {
    static let shared = NetworkRetry()
    
    private init() {}
    
    /// Execute an async operation with retry logic
    func execute<T>(
        operation: @escaping () async throws -> T,
        maxRetries: Int = 3,
        initialDelay: TimeInterval = 1.0
    ) async throws -> T {
        var lastError: Error?
        var delay = initialDelay
        
        for attempt in 0...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't retry on certain errors
                if shouldNotRetry(error) {
                    throw error
                }
                
                // If this was the last attempt, throw the error
                if attempt >= maxRetries {
                    throw error
                }
                
                // Wait before retrying (exponential backoff)
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                delay *= 2.0 // Exponential backoff
            }
        }
        
        throw lastError ?? NSError(domain: "NetworkRetry", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])
    }
    
    private func shouldNotRetry(_ error: Error) -> Bool {
        // Don't retry authentication errors
        if let nsError = error as NSError? {
            return nsError.domain.contains("auth") || nsError.code == 401 || nsError.code == 403
        }
        return false
    }
}

