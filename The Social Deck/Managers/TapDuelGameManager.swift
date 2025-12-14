//
//  TapDuelGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import UIKit

class TapDuelGameManager: ObservableObject {
    @Published var player1Name: String
    @Published var player2Name: String
    @Published var currentPlayer1Side: String // Tracks which player is on which side (left/right)
    @Published var currentPlayer2Side: String
    @Published var roundNumber: Int = 1
    @Published var player1Score: Int = 0
    @Published var player2Score: Int = 0
    
    // Game state
    @Published var gamePhase: GamePhase = .ready
    
    enum GamePhase {
        case ready // Ready to start round
        case countdown // Random countdown before GO
        case goSignal // GO signal is showing, waiting for tap
        case finished // Round finished, showing winner
        case falseStart // False start detected
    }
    
    @Published var countdownTime: TimeInterval = 0
    @Published var winner: String? = nil
    @Published var falseStartPlayer: String? = nil
    @Published var goSignalOpacity: Double = 0.0
    
    private var timer: Timer?
    private var countdownDuration: TimeInterval = 0
    private let minCountdownDuration: TimeInterval = 1.5 // Minimum 1.5 seconds
    private let maxCountdownDuration: TimeInterval = 4.0 // Maximum 4 seconds
    private var goSignalTime: TimeInterval = 0
    private var goSignalShown: Bool = false
    
    init(player1Name: String, player2Name: String) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        self.currentPlayer1Side = player1Name
        self.currentPlayer2Side = player2Name
    }
    
    func startRound() {
        // Reset state
        gamePhase = .countdown
        winner = nil
        falseStartPlayer = nil
        goSignalShown = false
        goSignalOpacity = 0.0
        countdownTime = 0
        
        // Generate random countdown duration
        countdownDuration = Double.random(in: minCountdownDuration...maxCountdownDuration)
        
        // Start countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.countdownTime += 0.01
            
            // Check if countdown is complete
            if self.countdownTime >= self.countdownDuration {
                self.showGoSignal()
                timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    private func showGoSignal() {
        goSignalShown = true
        gamePhase = .goSignal
        
        // Animate GO signal appearance
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
            goSignalOpacity = 1.0
        }
        
        // Haptic feedback for GO signal
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Record when GO signal was shown
        goSignalTime = countdownTime
    }
    
    func handleTap(isLeftSide: Bool) {
        guard gamePhase == .countdown || gamePhase == .goSignal else { return }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if gamePhase == .countdown {
            // False start - determine which player tapped
            let tappedPlayer = isLeftSide ? currentPlayer1Side : currentPlayer2Side
            handleFalseStart(player: tappedPlayer)
        } else if gamePhase == .goSignal {
            // Valid tap after GO signal
            let tappedPlayer = isLeftSide ? currentPlayer1Side : currentPlayer2Side
            handleWin(player: tappedPlayer)
        }
    }
    
    private func handleFalseStart(player: String) {
        timer?.invalidate()
        timer = nil
        
        falseStartPlayer = player
        
        // Determine winner (the other player wins)
        let winningPlayer = (player == currentPlayer1Side) ? currentPlayer2Side : currentPlayer1Side
        winner = winningPlayer
        
        // Update scores
        if winningPlayer == player1Name {
            player1Score += 1
        } else {
            player2Score += 1
        }
        
        gamePhase = .falseStart
        
        // Strong haptic feedback for false start
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    private func handleWin(player: String) {
        timer?.invalidate()
        timer = nil
        
        winner = player
        
        // Update scores
        if player == player1Name {
            player1Score += 1
        } else {
            player2Score += 1
        }
        
        gamePhase = .finished
        
        // Success haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func rematch() {
        roundNumber += 1
        gamePhase = .ready
        winner = nil
        falseStartPlayer = nil
    }
    
    func swapSides() {
        // Swap which player is on which side
        let temp = currentPlayer1Side
        currentPlayer1Side = currentPlayer2Side
        currentPlayer2Side = temp
        
        // Note: Scores stay with the original player names (player1Name/player2Name)
        // and are not swapped, so scores follow the players regardless of which side they're on
        
        rematch()
    }
    
    // Helper to get score for a player name
    func score(for playerName: String) -> Int {
        if playerName == player1Name {
            return player1Score
        } else {
            return player2Score
        }
    }
    
    // Helper to get score for left side player
    var leftSideScore: Int {
        return score(for: currentPlayer1Side)
    }
    
    // Helper to get score for right side player
    var rightSideScore: Int {
        return score(for: currentPlayer2Side)
    }
    
    deinit {
        timer?.invalidate()
    }
}

