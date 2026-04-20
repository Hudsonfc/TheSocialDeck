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
    /// User IDs who have claimed their Social Deck online win for this match (each client records self; prevents double-counting).
    var socialDeckWinRecordedUserIds: [String]

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
        anonymousMode: Bool = false,
        socialDeckWinRecordedUserIds: [String] = []
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
        self.socialDeckWinRecordedUserIds = socialDeckWinRecordedUserIds
    }

    enum CodingKeys: String, CodingKey {
        case currentRound, totalRounds, currentPrompt, answers, phase, votes, scores, revealIndex, revealOrder, anonymousMode
        case socialDeckWinRecordedUserIds
        case onlineWinStatsRecorded // legacy bool — migrated in decoder
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
        if let ids = try c.decodeIfPresent([String].self, forKey: .socialDeckWinRecordedUserIds) {
            socialDeckWinRecordedUserIds = ids
        } else if (try c.decodeIfPresent(Bool.self, forKey: .onlineWinStatsRecorded)) == true {
            socialDeckWinRecordedUserIds = Array(scores.keys)
        } else {
            socialDeckWinRecordedUserIds = []
        }
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
        try c.encode(socialDeckWinRecordedUserIds, forKey: .socialDeckWinRecordedUserIds)
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
    "What would you do if you could know exactly how you'll die but not when?",
    "What would you do if your group chat got accidentally screenshotted to the wrong person?",
    "What would you do if you found out your therapist talks about you to their friends?",
    "What would you do if your phone started reading every notification out loud at the worst possible moment?",
    "What would you do if you woke up and your face was on a billboard you never agreed to?",
    "What would you do if your last Google search appeared above your head for everyone to see?",
    "What would you do if you had to read every text you've ever sent out loud at a wedding?",
    "What would you do if you could permanently delete one app from existence?",
    "What would you do if everyone you've ever ghosted showed up at your door at the same time?",
    "What would you do if you could force one person to be honest with you for ten minutes?",
    "What would you do if your boss accidentally added you to the company gossip group chat?",
    "What would you do if you discovered the person you've been crushing on has a secret diary about you?",
    "What would you do if your barista started telling you life advice based on your usual order?",
    "What would you do if you woke up next to a person you don't recognize in a country you've never been to?",
    "What would you do if you could swap lives with one person in this room for a week?",
    "What would you do if your most embarrassing photo was set as everyone's lock screen worldwide?",
    "What would you do if you had to live the same Tuesday on repeat for six months?",
    "What would you do if you got handed an envelope right now with the truth about your future inside?",
    "What would you do if you suddenly couldn't lie for a year?",
    "What would you do if your reflection started giving you unsolicited feedback every morning?",
    "What would you do if you found out one of your friends has been secretly recording your conversations?",
    "What would you do if your bank account showed a million dollars but you knew it would be gone in 24 hours?",
    "What would you do if you could replay any one moment of your life with full editing power?",
    "What would you do if your name became a slang word and you didn't know what it meant?",
    "What would you do if everyone could see exactly how many hours you've spent on your phone this week?",
    "What would you do if you got a notification that your soulmate just walked past you and you had 60 seconds to find them?",
    "What would you do if you could un-meet one person you've ever dated?",
    "What would you do if a stranger handed you their car keys and said 'it's yours, but don't ask questions'?",
    "What would you do if your dog could suddenly speak but only roasts you?",
    "What would you do if you found out you were on a hidden-camera show your entire life?",
    "What would you do if everyone you ever turned down got to vote on your next relationship?",
    "What would you do if the universe gave you one free 'undo' button for any decision you've made?",
    "What would you do if you discovered your favorite influencer was just a really committed AI?",
    "What would you do if you had to give your most-watched YouTube video as a presentation tomorrow?",
    "What would you do if your future kid time-traveled back to give you one warning?",
    "What would you do if your DMs were projected onto the side of a building for an hour?",
    "What would you do if you woke up engaged to someone and couldn't remember saying yes?",
    "What would you do if you could remove one memory permanently?",
    "What would you do if your photos app sorted everyone you've ever kissed into one folder and showed it to your partner?",
    "What would you do if your last argument was put on TikTok and went viral?",
    "What would you do if you could trade three years of your life for fluency in any skill?",
    "What would you do if a famous person started copying your style and you couldn't prove it was yours first?",
    "What would you do if you got stuck in an elevator with the last person who ghosted you?",
    "What would you do if you woke up tomorrow and everyone treated you like you were the main character?",
    "What would you do if you found out your group of friends has a separate group chat without you?",
    "What would you do if every compliment you gave came true but every insult also did?",
    "What would you do if your future self called you right now and only had time for one sentence?",
    "What would you do if your favorite restaurant told you they've been watching your order patterns and were 'concerned'?",
    "What would you do if you could only respond in song lyrics for 24 hours?",
    "What would you do if your worst fear got an Instagram account and started posting?",
    "What would you do if you woke up and everyone you know swapped personalities for a day?"
]
