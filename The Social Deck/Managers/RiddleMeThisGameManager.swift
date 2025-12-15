//
//  RiddleMeThisGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import UIKit

class RiddleMeThisGameManager: ObservableObject {
    @Published var cards: [Card] = []
    @Published var players: [String] = []
    @Published var currentCardIndex: Int = 0
    @Published var roundNumber: Int = 1
    @Published var timeRemaining: Double = 0.0
    @Published var winner: String? = nil
    @Published var isFinished: Bool = false
    @Published var lockedOutPlayers: Set<String> = []
    
    private var timer: Timer?
    let roundDuration: TimeInterval = 90.0 // 90 seconds per riddle
    
    enum GamePhase {
        case showingRiddle // Riddle is displayed, timer running
        case showingSolution // Solution revealed, waiting for next round
    }
    
    @Published var gamePhase: GamePhase = .showingRiddle
    
    init(deck: Deck, cardCount: Int, players: [String]) {
        // Initialize players - randomize order
        if players.isEmpty {
            self.players = ["Player 1"]
        } else {
            self.players = players.shuffled()
        }
        
        // Get cards - shuffle and take cardCount
        if cardCount == 0 {
            self.cards = deck.cards.shuffled()
        } else {
            let shuffled = deck.cards.shuffled()
            self.cards = Array(shuffled.prefix(cardCount))
        }
        
        // Start the first round
        if !self.cards.isEmpty {
            startRound()
        }
    }
    
    var currentRiddle: Card? {
        guard currentCardIndex < cards.count else { return nil }
        return cards[currentCardIndex]
    }
    
    var currentRiddleText: String {
        return currentRiddle?.text ?? ""
    }
    
    var currentAnswer: String {
        return currentRiddle?.correctAnswer ?? ""
    }
    
    func checkAnswer(_ userAnswer: String) -> Bool {
        let correctAnswer = currentAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let userAnswerLower = userAnswer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Exact match
        if userAnswerLower == correctAnswer {
            return true
        }
        
        // Remove common articles and punctuation for fuzzy matching
        let cleanCorrect = correctAnswer
            .replacingOccurrences(of: "an ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "a ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "the ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: "?", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let cleanUser = userAnswerLower
            .replacingOccurrences(of: "an ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "a ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "the ", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "!", with: "")
            .replacingOccurrences(of: "?", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if cleaned versions match
        if cleanUser == cleanCorrect {
            return true
        }
        
        // Check if user answer contains the correct answer (for partial matches like "an echo" vs "echo")
        if cleanUser.contains(cleanCorrect) || cleanCorrect.contains(cleanUser) {
            // But only if they're similar length (within 5 characters) to avoid false positives
            let lengthDiff = abs(cleanUser.count - cleanCorrect.count)
            if lengthDiff <= 5 {
                return true
            }
        }
        
        return false
    }
    
    var canGoToNextRound: Bool {
        return currentCardIndex < cards.count - 1
    }
    
    func startRound() {
        // Reset state for new round
        winner = nil
        lockedOutPlayers.removeAll()
        gamePhase = .showingRiddle
        timeRemaining = roundDuration
        
        // Start timer
        startTimer()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.timeRemaining -= 0.1
            
            // Haptic feedback when timer is low (last 10 seconds, once per second)
            if self.timeRemaining <= 10 && self.timeRemaining > 0 {
                let currentSecond = Int(self.timeRemaining)
                let previousSecond = Int(self.timeRemaining + 0.1)
                if currentSecond != previousSecond {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
            }
            
            if self.timeRemaining <= 0 {
                self.handleTimerExpired()
                timer.invalidate()
            }
        }
    }
    
    func submitCorrectAnswer(winnerName: String) {
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // Set winner
        winner = winnerName
        
        // Move to solution phase
        gamePhase = .showingSolution
        
        // Haptic feedback for correct answer
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func submitIncorrectAnswer(playerName: String) {
        // Lock out the player for this round
        lockedOutPlayers.insert(playerName)
        
        // Haptic feedback for incorrect answer
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Error haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    func showAnswer() {
        // Stop timer
        timer?.invalidate()
        timer = nil
        
        // No winner when showing answer directly
        winner = nil
        
        // Move to solution phase
        gamePhase = .showingSolution
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func handleTimerExpired() {
        timer?.invalidate()
        timer = nil
        
        // No winner this round
        winner = nil
        
        // Move to solution phase
        gamePhase = .showingSolution
        
        // Haptic feedback for timer expiration
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func nextRound() {
        // Move to next card
        currentCardIndex += 1
        roundNumber += 1
        
        // Check if game is finished
        if currentCardIndex >= cards.count {
            isFinished = true
        } else {
            // Start next round
            startRound()
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, seconds)
        } else {
            return String(format: "%d", seconds)
        }
    }
    
    deinit {
        timer?.invalidate()
    }
}
