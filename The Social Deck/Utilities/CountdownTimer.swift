//
//  CountdownTimer.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import Combine

@MainActor
class CountdownTimer: ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var isExpired: Bool = false
    
    private var timer: Timer?
    private let targetDate: Date
    
    init(targetDate: Date) {
        self.targetDate = targetDate
        updateTimeRemaining()
    }
    
    func start() {
        timer?.invalidate()
        updateTimeRemaining()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateTimeRemaining()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimeRemaining() {
        let now = Date()
        timeRemaining = max(0, targetDate.timeIntervalSince(now))
        isExpired = timeRemaining <= 0
        
        if isExpired {
            stop()
        }
    }
    
    var formattedTime: String {
        let hours = Int(timeRemaining) / 3600
        let minutes = Int(timeRemaining) / 60 % 60
        let seconds = Int(timeRemaining) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

