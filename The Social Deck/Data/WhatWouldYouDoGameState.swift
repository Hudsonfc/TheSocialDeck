//
//  WhatWouldYouDoGameState.swift
//  The Social Deck
//

import Foundation

// MARK: - Game Phase

enum WWYDPhase: String, Codable, Equatable {
    case answering
    case revealing
    case voting
    case results
    case finished
}

// MARK: - Game State

struct WhatWouldYouDoGameState: Codable, Equatable {
    /// 0-based index of the current round.
    var currentRound: Int
    /// Total number of rounds for this session.
    var totalRounds: Int
    /// The prompt text shown to all players this round.
    var currentPrompt: String
    /// Player answers keyed by userId.
    var answers: [String: String]
    /// Current phase of the round.
    var phase: WWYDPhase
    /// Votes keyed by voter userId; each voter lists distinct answer-authors they voted for (1 vote if 2 players, up to 3 if 3+).
    var votes: [String: [String]]
    /// Scores keyed by userId.
    var scores: [String: Int]
    /// Index of the answer currently being revealed (0-based). -1 = nothing revealed yet.
    var revealIndex: Int
    /// Stable ordered list of player IDs for consistent reveal order (set when round starts).
    var revealOrder: [String]
    /// When true, answers are shown without names/avatars during play and scores stay hidden in the shell until the game ends.
    var anonymousMode: Bool

    init(
        currentRound: Int = 0,
        totalRounds: Int,
        currentPrompt: String,
        answers: [String: String] = [:],
        phase: WWYDPhase = .answering,
        votes: [String: [String]] = [:],
        scores: [String: Int] = [:],
        revealIndex: Int = -1,
        revealOrder: [String] = [],
        anonymousMode: Bool = false
    ) {
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.currentPrompt = currentPrompt
        self.answers = answers
        self.phase = phase
        self.votes = votes
        self.scores = scores
        self.revealIndex = revealIndex
        self.revealOrder = revealOrder
        self.anonymousMode = anonymousMode
    }

    enum CodingKeys: String, CodingKey {
        case currentRound, totalRounds, currentPrompt, answers, phase, votes, scores, revealIndex, revealOrder, anonymousMode
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currentRound = try c.decodeIfPresent(Int.self, forKey: .currentRound) ?? 0
        totalRounds = try c.decode(Int.self, forKey: .totalRounds)
        currentPrompt = try c.decode(String.self, forKey: .currentPrompt)
        answers = try c.decodeIfPresent([String: String].self, forKey: .answers) ?? [:]
        phase = try c.decodeIfPresent(WWYDPhase.self, forKey: .phase) ?? .answering
        if let arrMap = try? c.decode([String: [String]].self, forKey: .votes) {
            votes = arrMap
        } else if let strMap = try? c.decode([String: String].self, forKey: .votes) {
            votes = strMap.mapValues { [$0] }
        } else {
            votes = [:]
        }
        scores = try c.decodeIfPresent([String: Int].self, forKey: .scores) ?? [:]
        revealIndex = try c.decodeIfPresent(Int.self, forKey: .revealIndex) ?? -1
        revealOrder = try c.decodeIfPresent([String].self, forKey: .revealOrder) ?? []
        anonymousMode = try c.decodeIfPresent(Bool.self, forKey: .anonymousMode) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(currentRound, forKey: .currentRound)
        try c.encode(totalRounds, forKey: .totalRounds)
        try c.encode(currentPrompt, forKey: .currentPrompt)
        try c.encode(answers, forKey: .answers)
        try c.encode(phase, forKey: .phase)
        try c.encode(votes, forKey: .votes)
        try c.encode(scores, forKey: .scores)
        try c.encode(revealIndex, forKey: .revealIndex)
        try c.encode(revealOrder, forKey: .revealOrder)
        try c.encode(anonymousMode, forKey: .anonymousMode)
    }
}

extension WhatWouldYouDoGameState {
    /// Votes required from each player: 1 in a 2-player game; otherwise up to 3, capped by how many other players exist.
    static func requiredVotesPerPlayer(playerCount: Int) -> Int {
        if playerCount <= 2 { return 1 }
        return min(3, max(1, playerCount - 1))
    }

    /// Total votes (across all voters) cast for this answer author.
    func votesReceived(by authorId: String) -> Int {
        votes.values.flatMap { $0 }.filter { $0 == authorId }.count
    }
}

// MARK: - Prompts

let allWhatWouldYouDoPrompts: [String] = [
    "What would you do if you woke up famous overnight?",
    "What would you do if you had 24 hours left on earth?",
    "What would you do if you found $10,000 in cash on the street?",
    "What would you do if you swapped bodies with your best friend for a week?",
    "What would you do if you could read everyone's minds for one day?",
    "What would you do if you won the lottery tomorrow?",
    "What would you do if your boss offered you a promotion but you had to move countries?",
    "What would you do if your ex texted you 'we need to talk' right now?",
    "What would you do if you had no phone for an entire month?",
    "What would you do if you could go back and change one decision in your life?",
    "What would you do if you discovered your best friend had been lying to you for years?",
    "What would you do if someone paid you $1 million to never use social media again?",
    "What would you do if you woke up as a different gender for a week?",
    "What would you do if you could live anywhere in the world rent free?",
    "What would you do if you found out your partner had been reading all your messages?",
    "What would you do if a stranger offered you $500 to sit with them at dinner?",
    "What would you do if you had one hour to spend however you want, completely alone?",
    "What would you do if your coworker got the promotion you worked a year for?",
    "What would you do if you could only eat one food for the rest of your life?",
    "What would you do if someone filmed you without permission and it went viral?",
    "What would you do if you had to give up either Netflix or music forever?",
    "What would you do if your doctor told you to cut out your biggest bad habit immediately?",
    "What would you do if your childhood dream job suddenly became an option?",
    "What would you do if you could know exactly how you'll die but not when?"
]
