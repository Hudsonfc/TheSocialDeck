//
//  HotPotatoGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import UIKit

class HotPotatoGameManager: ObservableObject {
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var isGameActive: Bool = false
    @Published var timerExpired: Bool = false
    @Published var roundNumber: Int = 1
    @Published var totalRounds: Int = 5
    @Published var loser: String? = nil
    @Published var heatLevel: Double = 0.0 // 0.0 to 1.0, represents how close to expiration
    @Published var passCount: Int = 0
    @Published var lastPassTime: TimeInterval = 0
    @Published var wasCloseCall: Bool = false
    @Published var activePerk: Perk? = nil
    @Published var showPerkAlert: Bool = false
    @Published var perkAccepted: Bool = false
    @Published var isTimerPausedForPerk: Bool = false
    
    private var timer: Timer?
    private var timerDuration: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private let minTimerDuration: TimeInterval = 5.0 // Minimum 5 seconds
    private let maxTimerDuration: TimeInterval = 15.0 // Maximum 15 seconds
    private let closeCallThreshold: TimeInterval = 0.5 // If passed within 0.5 seconds of expiration
    private var perkTriggerTime: TimeInterval? = nil // When to trigger next perk
    private let perkChance: Double = 0.5 // 50% chance per check (increased from 30%)
    var perksEnabled: Bool = true // Whether perks are enabled
    @Published var timerSpeedMultiplier: Double = 1.0 // 1.0 = normal, 2.0 = 2x speed, 0.0 = frozen
    @Published var isTimerFrozen: Bool = false
    private var frozenTimeRemaining: TimeInterval = 0
    
    enum GamePhase {
        case waitingToStart // Before round starts
        case active // Timer is running, phone is being passed
        case choosingPlayer // Player is choosing who to pass to
        case expired // Timer expired, showing loser
    }
    
    enum Perk: String, CaseIterable {
        // Save perks
        case timeExtension = "Time Extension"
        case freezeTimer = "Freeze Timer"
        case cooling = "Cooling"
        
        // Destroy perks
        case timeReduction = "Time Reduction"
        case forcePass = "Force Pass"
        case doubleHeat = "Double Heat"
        case speedTime = "Speed Time"
        
        // Neutral perks
        case swapPlayers = "Swap Players"
        case choosePlayer = "Choose Player"
        
        var description: String {
            switch self {
            case .timeExtension:
                return "Timer extended by 3 seconds!"
            case .freezeTimer:
                return "Timer frozen for 2 seconds!"
            case .cooling:
                return "Heat reduced by 30%!"
            case .timeReduction:
                return "Timer reduced by 2 seconds!"
            case .forcePass:
                return "Must pass immediately!"
            case .doubleHeat:
                return "Heat level doubled!"
            case .speedTime:
                return "Timer speeds up 2x for 3 seconds!"
            case .swapPlayers:
                return "Swap with random player!"
            case .choosePlayer:
                return "Choose who to pass to!"
            }
        }
        
        var icon: String {
            switch self {
            case .timeExtension:
                return "plus.circle.fill"
            case .freezeTimer:
                return "snowflake"
            case .cooling:
                return "thermometer.snowflake"
            case .timeReduction:
                return "minus.circle.fill"
            case .forcePass:
                return "arrow.right.circle.fill"
            case .doubleHeat:
                return "flame.fill"
            case .speedTime:
                return "bolt.fill"
            case .swapPlayers:
                return "arrow.triangle.2.circlepath"
            case .choosePlayer:
                return "hand.point.up.fill"
            }
        }
        
        var iconColor: Color {
            switch self {
            case .timeExtension:
                return Color(red: 0x34/255.0, green: 0xC7/255.0, blue: 0x59/255.0) // Green
            case .freezeTimer:
                return Color(red: 0x5A/255.0, green: 0xC9/255.0, blue: 0xFF/255.0) // Light blue
            case .cooling:
                return Color(red: 0x87/255.0, green: 0xCE/255.0, blue: 0xEB/255.0) // Sky blue
            case .timeReduction:
                return Color(red: 0xFF/255.0, green: 0x3B/255.0, blue: 0x30/255.0) // Red
            case .forcePass:
                return Color(red: 0xFF/255.0, green: 0x6B/255.0, blue: 0x00/255.0) // Orange-red
            case .doubleHeat:
                return Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0) // Orange
            case .speedTime:
                return Color(red: 0xFF/255.0, green: 0xD7/255.0, blue: 0x00/255.0) // Yellow
            case .swapPlayers:
                return Color(red: 0xAF/255.0, green: 0x52/255.0, blue: 0xDE/255.0) // Purple
            case .choosePlayer:
                return Color(red: 0xFF/255.0, green: 0x95/255.0, blue: 0x00/255.0) // Orange
            }
        }
        
        var isSavePerk: Bool {
            switch self {
            case .timeExtension, .freezeTimer, .cooling:
                return true
            default:
                return false
            }
        }
        
        var isDestroyPerk: Bool {
            switch self {
            case .timeReduction, .forcePass, .doubleHeat, .speedTime:
                return true
            default:
                return false
            }
        }
    }
    
    @Published var gamePhase: GamePhase = .waitingToStart
    
    init(players: [String], perksEnabled: Bool = true, totalRounds: Int = 5) {
        // Randomize player order
        if players.isEmpty {
            self.players = ["Player 1"]
        } else {
            self.players = players.shuffled()
        }
        self.perksEnabled = perksEnabled
        self.totalRounds = totalRounds
    }
    
    var isGameComplete: Bool {
        return roundNumber > totalRounds
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    func startRound() {
        // Reset state
        timerExpired = false
        loser = nil
        gamePhase = .active
        isGameActive = true
        heatLevel = 0.0
        passCount = 0
        lastPassTime = 0
        wasCloseCall = false
        activePerk = nil
        perkTriggerTime = nil
        timerSpeedMultiplier = 1.0
        isTimerFrozen = false
        frozenTimeRemaining = 0
        perkAccepted = false
        isTimerPausedForPerk = false
        
        // Generate random timer duration
        timerDuration = Double.random(in: minTimerDuration...maxTimerDuration)
        elapsedTime = 0
        
        // Schedule first perk check (after 3 seconds)
        perkTriggerTime = 3.0
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Handle timer speed and freezing
            if self.isTimerFrozen {
                // Timer is frozen, don't increment
                if self.frozenTimeRemaining > 0 {
                    self.frozenTimeRemaining -= 0.1
                    if self.frozenTimeRemaining <= 0 {
                        self.isTimerFrozen = false
                    }
                }
            } else {
                // Normal or sped up timer
                // Only increment timer if not paused for perk
            if !self.isTimerPausedForPerk {
                self.elapsedTime += 0.1 * self.timerSpeedMultiplier
            }
            }
            
            // Check for perk trigger (only if perks are enabled)
            if self.perksEnabled, let triggerTime = self.perkTriggerTime, self.elapsedTime >= triggerTime {
                self.checkForPerk()
                // Schedule next perk check (random between 1.5-3.5 seconds later - more frequent)
                self.perkTriggerTime = self.elapsedTime + Double.random(in: 1.5...3.5)
            }
            
            // Update heat level (0.0 to 1.0)
            self.heatLevel = min(1.0, self.elapsedTime / self.timerDuration)
            
            if self.elapsedTime >= self.timerDuration {
                self.handleTimerExpired()
                timer.invalidate()
            }
        }
    }
    
    private func checkForPerk() {
        // Only trigger if no active perk and random chance
        guard activePerk == nil, Double.random(in: 0...1) < perkChance else { return }
        
        // Select random perk
        let allPerks = Perk.allCases
        let selectedPerk = allPerks.randomElement()!
        
        // Apply perk immediately
        applyPerk(selectedPerk)
    }
    
    private func applyPerk(_ perk: Perk) {
        activePerk = perk
        showPerkAlert = true
        perkAccepted = false
        isTimerPausedForPerk = true // Pause timer until perk is accepted
        
        // Haptic feedback based on perk type
        let impactFeedback = UIImpactFeedbackGenerator(style: perk.isDestroyPerk ? .heavy : .medium)
        impactFeedback.impactOccurred()
        
        // Don't apply perk effects yet - wait for acceptance
        // Effects will be applied in acceptPerk()
    }
    
    func acceptPerk() {
        guard let perk = activePerk, !perkAccepted else { return }
        
        perkAccepted = true
        isTimerPausedForPerk = false // Resume timer
        
        // Now apply the perk effects
        switch perk {
        case .timeExtension:
            // Extend timer by 3 seconds
            timerDuration += 3.0
            // Recalculate heat level
            heatLevel = min(1.0, elapsedTime / timerDuration)
            
        case .freezeTimer:
            // Freeze timer for 2 seconds - actually pause it
            isTimerFrozen = true
            frozenTimeRemaining = 2.0
            // Reset speed multiplier in case it was sped up
            timerSpeedMultiplier = 1.0
            
        case .cooling:
            // Reduce heat level by 30% (move elapsed time back)
            let heatReduction = 0.3
            let timeToReduce = timerDuration * heatReduction
            elapsedTime = max(0, elapsedTime - timeToReduce)
            // Recalculate heat level
            heatLevel = min(1.0, elapsedTime / timerDuration)
            
        case .timeReduction:
            // Reduce timer by 2 seconds (but don't go below 1 second)
            timerDuration = max(1.0, timerDuration - 2.0)
            // Recalculate heat level
            heatLevel = min(1.0, elapsedTime / timerDuration)
            
        case .forcePass:
            // Force pass to next player
            passPhone()
            
        case .doubleHeat:
            // Double the heat level (make timer closer to expiring)
            let newElapsedTime = elapsedTime + (timerDuration - elapsedTime) * 0.5
            elapsedTime = newElapsedTime
            heatLevel = min(1.0, elapsedTime / timerDuration)
            
        case .speedTime:
            // Speed up timer 2x for 3 seconds
            timerSpeedMultiplier = 2.0
            isTimerFrozen = false // Unfreeze if frozen
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.timerSpeedMultiplier = 1.0
            }
            
        case .swapPlayers:
            // Swap current player with random other player
            if players.count > 1 {
                var otherIndex = Int.random(in: 0..<players.count)
                while otherIndex == currentPlayerIndex {
                    otherIndex = Int.random(in: 0..<players.count)
                }
                currentPlayerIndex = otherIndex
            }
            
        case .choosePlayer:
            // Allow current player to choose who to pass to
            gamePhase = .choosingPlayer
            // Don't clear perk yet - wait for selection
            // Perk will be cleared in choosePlayer() function
            return // Exit early, perk will be cleared after selection
        }
        
        // Clear perk after 3 seconds (unless it's choosePlayer which handles its own clearing)
        if perk != .choosePlayer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.activePerk = nil
                self?.showPerkAlert = false
                self?.perkAccepted = false
            }
        }
    }
    
    func passPhone() {
        guard isGameActive && !timerExpired else { return }
        
        // Check if this was a close call
        let timeRemaining = timerDuration - elapsedTime
        if timeRemaining <= closeCallThreshold {
            wasCloseCall = true
        }
        
        lastPassTime = elapsedTime
        passCount += 1
        
        // Move to random next player (not in order)
        if players.count > 1 {
            var nextIndex = Int.random(in: 0..<players.count)
            // Make sure it's a different player
            while nextIndex == currentPlayerIndex {
                nextIndex = Int.random(in: 0..<players.count)
            }
            currentPlayerIndex = nextIndex
        }
    }
    
    func choosePlayer(_ playerIndex: Int) {
        guard playerIndex >= 0 && playerIndex < players.count else { return }
        guard gamePhase == .choosingPlayer else { return }
        guard playerIndex != currentPlayerIndex else { return } // Can't choose yourself
        
        // Increment pass count
        passCount += 1
        lastPassTime = elapsedTime
        
        // Check if this was a close call
        let timeRemaining = timerDuration - elapsedTime
        if timeRemaining <= closeCallThreshold {
            wasCloseCall = true
        }
        
        // Set the chosen player
        currentPlayerIndex = playerIndex
        
        // Return to active game
        gamePhase = .active
        
        // Clear the perk
        activePerk = nil
        showPerkAlert = false
        perkAccepted = false
    }
    
    var availablePlayersToChoose: [String] {
        // Return all players except current player
        return players.enumerated().filter { $0.offset != currentPlayerIndex }.map { $0.element }
    }
    
    var heatLevelText: String {
        if heatLevel < 0.33 {
            return "WARM"
        } else if heatLevel < 0.66 {
            return "HOT"
        } else {
            return "SCORCHING"
        }
    }
    
    var heatColor: Color {
        if heatLevel < 0.33 {
            return Color(red: 0xFF/255.0, green: 0x8C/255.0, blue: 0x42/255.0) // Orange
        } else if heatLevel < 0.66 {
            return Color(red: 0xFF/255.0, green: 0x45/255.0, blue: 0x00/255.0) // Red-orange
        } else {
            return Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0) // Deep red
        }
    }
    
    private func handleTimerExpired() {
        timer?.invalidate()
        timer = nil
        timerExpired = true
        isGameActive = false
        loser = currentPlayer
        gamePhase = .expired
    }
    
    func nextRound() {
        roundNumber += 1
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count // Start with next player
        gamePhase = .waitingToStart
        wasCloseCall = false
    }
    
    func resetGame() {
        roundNumber = 1
        currentPlayerIndex = 0
        gamePhase = .waitingToStart
        timerExpired = false
        loser = nil
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}

