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
    @Published var currentCardIndex: Int = 0
    @Published var roundNumber: Int = 1
    @Published var winner: String? = nil
    @Published var isFinished: Bool = false
    let timerEnabled: Bool
    let timerDuration: Int
    @Published var timeRemaining: TimeInterval = 0
    @Published var timerStarted: Bool = false
    private var countdownTimer: Timer?
    
    enum GamePhase {
        case showingRiddle // Riddle is displayed
        case showingSolution // Solution revealed, waiting for next round
    }
    
    @Published var gamePhase: GamePhase = .showingRiddle
    
    init(deck: Deck, cardCount: Int, timerEnabled: Bool = false, timerDuration: Int = 30) {
        self.timerEnabled = timerEnabled
        self.timerDuration = timerDuration
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
        
        // If correct answer is empty (nil), no answer can be correct
        guard !correctAnswer.isEmpty else { return false }
        
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
        gamePhase = .showingRiddle
        
        // Reset timer (but don't start it yet - will start when card is flipped)
        if timerEnabled {
            timeRemaining = TimeInterval(timerDuration)
            timerStarted = false
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func startTimer() {
        // Start timer if enabled, in riddle phase, and hasn't been started yet
        if timerEnabled && gamePhase == .showingRiddle && !timerStarted && timeRemaining > 0 {
            timerStarted = true
            startCountdownTimer()
        }
    }
    
    private func startCountdownTimer() {
        // Stop any existing timer
        countdownTimer?.invalidate()
        
        // Start new countdown timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Only countdown if we're in showingRiddle phase
            guard self.gamePhase == .showingRiddle else {
                timer.invalidate()
                return
            }
            
            self.timeRemaining -= 1
            
            // When timer reaches 0, automatically show answer
            if self.timeRemaining <= 0 {
                timer.invalidate()
                self.showAnswer()
            }
        }
    }
    
    func stopTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    func submitCorrectAnswer() {
        // Set winner (no specific name needed)
        winner = "Someone"
        
        // Move to solution phase
        gamePhase = .showingSolution
        
        // Haptic feedback for correct answer
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    func submitIncorrectAnswer() {
        // Haptic feedback for incorrect answer
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Error haptic
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    func showAnswer() {
        // Stop timer
        stopTimer()
        
        // No winner when showing answer directly
        winner = nil
        
        // Move to solution phase
        gamePhase = .showingSolution
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func nextRound() {
        // Stop timer
        stopTimer()
        
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
    
    deinit {
        stopTimer()
    }
    
}
