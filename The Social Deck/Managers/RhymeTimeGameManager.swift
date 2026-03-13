//
//  RhymeTimeGameManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation
import SwiftUI
import UIKit

class RhymeTimeGameManager: ObservableObject {
    @Published var players: [String] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var isGameActive: Bool = false
    @Published var timerExpired: Bool = false
    @Published var roundNumber: Int = 1
    @Published var loser: String? = nil
    @Published var baseWord: String = ""
    @Published var usedRhymes: [String] = []      // words used this round (for display)
    @Published var timeRemaining: Double = 0.0
    @Published var roundComplete: Bool = false
    @Published var lossReason: LossReason = .timerExpired
    @Published var scores: [String: Int] = [:]
    @Published var gameWinner: String? = nil
    @Published var lastSubmitCorrect: Bool = false
    /// Which players failed this round and why — used on the round-complete screen
    @Published var failedThisRound: [String: LossReason] = [:]
    let winningScore: Int = 5

    /// True when there are still players left who haven't had their turn this round
    var hasMorePlayersThisRound: Bool { playersGoneThisRound < players.count }

    private var playersGoneThisRound: Int = 0
    private var timer: Timer?
    private var turnDuration: TimeInterval = 10.0
    private var cards: [Card] = []
    private var currentCardIndex: Int = 0

    func clearCorrectConfirmation() {
        lastSubmitCorrect = false
    }

    enum LossReason {
        case timerExpired
        case badRhyme
        case repeatedRhyme
        case notARealWord
    }

    enum GamePhase {
        case waitingToStart
        case active
        case roundComplete
        case expired
        case gameOver
    }

    // MARK: - Rhyme Checking

    static func rhymes(_ input: String, with base: String) -> Bool {
        let w1 = normalizedRhymeForm(input)
        let w2 = normalizedRhymeForm(base)
        guard w1 != w2, !w1.isEmpty, !w2.isEmpty else { return false }
        let r1 = rhymingEnding(w1)
        let r2 = rhymingEnding(w2)
        return !r1.isEmpty && r1 == r2
    }

    // Applies sound-alike normalizations so spelling variants map to the same form.
    private static func normalizedRhymeForm(_ word: String) -> String {
        var w = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !w.isEmpty else { return w }

        // Longest suffix match wins — order matters: longer entries first within each group.
        let substitutions: [(String, String)] = [
            // -tion / -cion / -ssion / -sion family  (ocean→oshun, passion→pashun, motion→moshun)
            ("ation",  "ayshun"), ("ition",  "ishun"), ("ution",  "ushun"),
            ("cean",   "shun"),                        // ocean → oshun
            ("ssion",  "shun"),                        // passion, mission → pashun
            ("sion",   "shun"),                        // vision, tension → vishun
            ("tion",   "shun"),
            // -ture (adventure, capture, nature, picture, creature)
            ("ture",   "cher"),
            // -ight (light, night, right, bright, fight)
            ("ight",   "ite"),
            // -ould (could, would, should)
            ("ould",   "ood"),
            // silent-letter / alternate spelling endings
            ("eight",  "ate"),          // weight/late/gate
            ("eigh",   "ay"),           // weigh/day/way
            ("iece",   "eece"),         // piece/peace
            ("ouble",  "ubble"),        // double/trouble/bubble
            // -ery / -ory / -ary all share the same trailing vowel sound
            ("atory",  "oree"), ("itory", "oree"),
            ("ery",    "eree"), ("ory",   "oree"), ("ary",   "oree"),
            // -ic / -ick / -ics (magic, tragic, pick, trick)
            ("icks",   "ik"),  ("ick",   "ik"),  ("ics",   "ik"),  ("ic",    "ik"),
            // -ack / -ax (sack, tax, wax, back)
            ("acks",   "ak"),  ("ack",   "ak"),  ("ax",    "ak"),
            // -ock / -ox / -ocks (rock, box, sock, locks)
            ("ocks",   "ok"),  ("ock",   "ok"),  ("ox",    "ok"),
            // -eck / -ex (deck, flex, vex)
            ("ecks",   "ek"),  ("eck",   "ek"),  ("ex",    "ek"),
            // -ect (respect, connect)
            ("ects",   "ekt"), ("ect",   "ekt"),
            // long-i sound variants (prime/kind → ine, dry/pry → y)
            ("ime",    "ine"), ("ind",   "ine"),
            // -alk (walk, talk, chalk)
            ("alk",    "awk"),
            // -ung / -ong (lung/song, young/long)
            ("ung",    "ong"),
            // -each (beach, reach, teach, speech)
            ("each",   "eech"),
            // -ear / -ere / -are / -air (bear, care, fair, pair, stair, wear)
            ("ear",    "air"), ("ere",   "air"), ("are",   "air"),
            // -ence / -ance (sentence/dance, chance/balance)
            ("ence",   "ance"),
            // -our / -or / -ore (your, door, more, floor)
            ("our",    "or"),
            // -ew / -ue / -oo / -oe (new, blue, shoe, too)
            ("ew",     "oo"),  ("ue",    "oo"),  ("oe",    "oo"),
            // -ey / -ea / -ee (key, sea, tree)
            ("ey",     "ee"),  ("ea",    "ee"),
            // -ogue / -og (dialogue, dog, log)
            ("ogue",   "og"),
            // -acle / -icle
            ("acle",   "akel"), ("icle",  "ikel"),
        ]

        for (from, to) in substitutions {
            if w.hasSuffix(from) {
                w = String(w.dropLast(from.count)) + to
                break
            }
        }
        return w
    }

    // Extracts the rhyming ending: last vowel cluster + everything after it.
    // No minimum length enforced — single-vowel rimes like "y" (dry/pry/fly) are valid.
    private static func rhymingEnding(_ word: String) -> String {
        let vowels: Set<Character> = ["a", "e", "i", "o", "u", "y"]
        var chars = Array(word)
        var n = chars.count
        guard n > 0 else { return "" }

        // Strip trailing silent 'e': must have a non-vowel before it (cake→cak, love→lov)
        if n >= 3 && chars[n - 1] == "e" && !vowels.contains(chars[n - 2]) {
            n -= 1
        }

        // Walk backwards past any trailing consonants to find the last vowel
        var i = n - 1
        while i >= 0 && !vowels.contains(chars[i]) { i -= 1 }
        guard i >= 0 else { return String(chars.prefix(n)) }

        // Walk backwards through any contiguous vowels to get the full vowel nucleus
        while i > 0 && vowels.contains(chars[i - 1]) { i -= 1 }

        // Return from the start of the vowel nucleus to the end of the word
        return String(chars[i..<n])
    }

    /// Returns true if the word exists in the iOS English dictionary.
    static func isRealWord(_ word: String) -> Bool {
        let lower = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !lower.isEmpty else { return false }
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: lower.utf16.count)
        let misspelled = checker.rangeOfMisspelledWord(
            in: lower, range: range, startingAt: 0, wrap: false, language: "en"
        )
        return misspelled.location == NSNotFound
    }

    @Published var gamePhase: GamePhase = .waitingToStart
    
    init(deck: Deck, players: [String], timerDuration: Int = 10) {
        let orderedPlayers = players.isEmpty ? ["Player 1"] : players.shuffled()
        self.players = orderedPlayers
        self.turnDuration = TimeInterval(timerDuration)
        self.cards = deck.cards.isEmpty ? [] : deck.cards.shuffled()
        // Initialise every player at 0 points
        var initialScores: [String: Int] = [:]
        for p in orderedPlayers { initialScores[p] = 0 }
        self.scores = initialScores
    }
    
    var currentPlayer: String {
        guard currentPlayerIndex < players.count else { return "" }
        return players[currentPlayerIndex]
    }
    
    func startRound() {
        lastSubmitCorrect = false
        timerExpired = false
        loser = nil
        gamePhase = .active
        isGameActive = true
        usedRhymes = []
        roundComplete = false
        failedThisRound = [:]
        playersGoneThisRound = 0
        currentPlayerIndex = 0
        drawNextBaseWord()
        startTurnTimer()
    }

    private func drawNextBaseWord() {
        if cards.isEmpty {
            baseWord = "cat"
        } else if currentCardIndex < cards.count {
            baseWord = cards[currentCardIndex].text
            currentCardIndex += 1
        } else {
            currentCardIndex = 0
            cards = cards.shuffled()
            baseWord = cards[currentCardIndex].text
            currentCardIndex += 1
        }
    }
    
    private func startTurnTimer() {
        timeRemaining = turnDuration
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.handleTimerExpired()
                timer.invalidate()
            }
        }
    }
    
    /// Submit a rhyme typed by the current player. Validates word existence, uniqueness, and rhyme.
    func submitRhyme(rhyme: String) {
        guard isGameActive && !timerExpired, !players.isEmpty else { return }

        let trimmed = rhyme.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 1. Must be a real word
        if !RhymeTimeGameManager.isRealWord(trimmed) {
            lossReason = .notARealWord
            handlePlayerLost()
            return
        }

        // 2. Cannot repeat a word already used this round
        if usedRhymes.contains(trimmed) {
            lossReason = .repeatedRhyme
            handlePlayerLost()
            return
        }

        // 3. Must actually rhyme with the base word
        if !RhymeTimeGameManager.rhymes(trimmed, with: baseWord) {
            lossReason = .badRhyme
            handlePlayerLost()
            return
        }

        // Valid — award point, pause timer, show confirmation overlay.
        // The VIEW calls advanceAfterSuccess() once the overlay finishes so the
        // next player's timer doesn't start while the confirmation is visible.
        timer?.invalidate()
        timer = nil
        scores[currentPlayer, default: 0] += 1
        playersGoneThisRound += 1
        usedRhymes.append(trimmed)
        lastSubmitCorrect = true
        if checkForWinner() { return }
    }

    /// Called by the view after the "Correct!" overlay has been shown.
    /// Advances to the next player or ends the round if everyone has gone.
    func advanceAfterSuccess() {
        lastSubmitCorrect = false
        if !hasMorePlayersThisRound {
            endRound()
        } else {
            moveToNextPlayer()
        }
    }

    /// Called by the view when the user taps "Next Player" on the failure screen.
    /// Advances to the next player or ends the round if everyone has gone.
    func advanceAfterFailure() {
        if !hasMorePlayersThisRound {
            endRound()
        } else {
            moveToNextPlayer()
        }
    }

    private func moveToNextPlayer() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        timerExpired = false
        loser = nil
        isGameActive = true
        drawNextBaseWord()
        startTurnTimer()
        gamePhase = .active
    }

    private func endRound() {
        roundComplete = true
        gamePhase = .roundComplete
        isGameActive = false
    }

    @discardableResult
    private func checkForWinner() -> Bool {
        if let winner = players.first(where: { (scores[$0] ?? 0) >= winningScore }) {
            gameWinner = winner
            gamePhase = .gameOver
            isGameActive = false
            return true
        }
        return false
    }

    private func handleTimerExpired() {
        timer?.invalidate()
        timer = nil
        timerExpired = true
        isGameActive = false
        loser = currentPlayer
        lossReason = .timerExpired
        failedThisRound[currentPlayer] = .timerExpired
        scores[currentPlayer, default: 0] -= 1
        playersGoneThisRound += 1
        if checkForWinner() { return }
        gamePhase = .expired
    }

    private func handlePlayerLost() {
        timer?.invalidate()
        timer = nil
        timerExpired = true
        isGameActive = false
        loser = currentPlayer
        failedThisRound[currentPlayer] = lossReason
        scores[currentPlayer, default: 0] -= 1
        playersGoneThisRound += 1
        if checkForWinner() { return }
        gamePhase = .expired
    }

    func nextRound() {
        roundNumber += 1
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        gamePhase = .waitingToStart
        roundComplete = false
        failedThisRound = [:]
    }

    func resetGame() {
        roundNumber = 1
        currentPlayerIndex = 0
        gamePhase = .waitingToStart
        timerExpired = false
        loser = nil
        lossReason = .timerExpired
        gameWinner = nil
        usedRhymes = []
        roundComplete = false
        failedThisRound = [:]
        playersGoneThisRound = 0
        timer?.invalidate()
        timer = nil
        currentCardIndex = 0
        for p in players { scores[p] = 0 }
    }
    
    deinit {
        timer?.invalidate()
    }
}

