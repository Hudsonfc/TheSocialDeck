//
//  GameDescriptionLayoutComponents.swift
//  The Social Deck
//
//  Shared tags, “how to play” copy, and numbered steps UI for game description
//  screens (Play grid overlay, online detail, online selection overlay).
//

import SwiftUI

// MARK: - Tag + steps UI

struct GameDescriptionTagPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .foregroundColor(.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.tertiaryBackground)
            .clipShape(Capsule())
    }
}

struct GameDescriptionTagRow: View {
    let tags: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    GameDescriptionTagPill(text: tag)
                }
            }
            .padding(.vertical, 2)
        }
    }
}

struct GameDescriptionNumberedStepsView: View {
    let steps: [(title: String, detail: String)]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(.primaryAccent)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(step.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)
                        Text(step.detail)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.secondaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.borderColor.opacity(0.35), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - Copy helpers

enum GameDescriptionLayoutContent {

    // MARK: Deck (Play grid)

    static func tags(for deck: Deck) -> [String] {
        var result: [String] = [
            playerCountLabel(for: deck.type),
            deck.estimatedTime
        ]
        if let category = categoryTag(for: deck) {
            result.append(category)
        }
        return result
    }

    static func playSteps(for deck: Deck) -> [(title: String, detail: String)] {
        switch deck.type {
        case .neverHaveIEver, .truthOrDare, .wouldYouRather, .mostLikelyTo, .takeItPersonally,
             .categoryClash, .bluffCall, .whatsMySecret, .spillTheEx:
            return chooseTopicsPlayAndRotate()
        case .twoTruthsAndALie:
            return [
                ("Pick categories", "Choose the card sets you want before you start."),
                ("Share three statements", "On your turn, read two truths and one lie about yourself."),
                ("Guess the lie", "Everyone votes; reveal the lie and pass to the next player.")
            ]
        case .spinTheBottle:
            return [
                ("Gather in a circle", "Sit so everyone can see the bottle in the middle."),
                ("Spin", "Take turns spinning; whoever it points to follows the on-screen prompt."),
                ("Keep it fun", "Skip or pass anytime — house rules win.")
            ]
        case .storyChain:
            return [
                ("Start the story", "Read the opening line and set the tone for the group."),
                ("Add one line each", "Go around and build the story one sentence at a time."),
                ("Wrap it up", "When the deck ends, read the full chain together.")
            ]
        case .memoryMaster:
            return [
                ("Memorize the grid", "Study the cards before they flip face down."),
                ("Take turns flipping two", "Try to find matching pairs; matched pairs stay revealed."),
                ("Clear the board", "Whoever collects the most pairs wins.")
            ]
        case .hotPotato:
            return [
                ("Pass the phone", "When the round starts, keep the “potato” moving quickly."),
                ("Watch the timer", "Whoever is holding it when time runs out takes the prompt."),
                ("Next round", "Reset and play again — keep the pace high.")
            ]
        case .rhymeTime:
            return [
                ("Get a starter word", "The app gives you the first word to rhyme with."),
                ("Rhyme back and forth", "Players take turns; invalid repeats or misses lose the round."),
                ("Crown a winner", "Play multiple rounds or first to a score you agree on.")
            ]
        case .tapDuel:
            return [
                ("Face off", "Two players get ready on opposite sides of the screen."),
                ("Wait for green", "Tap as soon as you see go — false starts cost you."),
                ("Fastest tap wins", "Best of several rounds or switch partners.")
            ]
        case .riddleMeThis:
            return [
                ("Read the riddle", "One player reads or reveals the clue for everyone."),
                ("Discuss or buzz in", "Use your group’s rules for guesses and hints."),
                ("Reveal and score", "Show the answer, then move to the next card.")
            ]
        case .actNatural:
            return [
                ("Choose packs", "Pick the word lists that fit your group."),
                ("Find the odd one out", "Everyone gets a word except one player — watch for tells."),
                ("Vote and reveal", "Discuss, vote, then see who was acting natural.")
            ]
        case .actItOut:
            return [
                ("Pick categories", "Select the acting prompts you want in play."),
                ("Act or guess", "Mime the clue without words while others shout guesses."),
                ("Rotate the actor", "Pass the phone or take turns being on stage.")
            ]
        case .quickfireCouples, .closerThanEver, .usAfterDark:
            return [
                ("Sit together", "Two players answer prompts side by side."),
                ("Take turns reading", "Read the card aloud, then both answer honestly."),
                ("Keep going", "Skip any card you’re not comfortable with — no pressure.")
            ]
        case .colorClash:
            return [
                ("Create or join a room", "Host a game or enter a friend’s room code."),
                ("Play your hand", "Match color or number, or play an action card when allowed."),
                ("Empty your hand first", "First player out wins — house rules for wilds apply.")
            ]
        case .flip21:
            return [
                ("Join the table", "Enter a room and wait for the host to start."),
                ("Hit or stand", "Try to get closer to 21 than the dealer without busting."),
                ("Settle the round", "Compare hands, then play the next round.")
            ]
        case .whatWouldYouDo:
            return [
                ("Read a prompt", "Everyone gets the same silly or tricky situation."),
                ("Pick in secret", "Choose what you would actually do — no judgment."),
                ("Reveal and laugh", "Compare answers and see who thinks alike. (Preview only for now.)")
            ]
        case .other:
            return chooseTopicsPlayAndRotate()
        }
    }

    private static func chooseTopicsPlayAndRotate() -> [(title: String, detail: String)] {
        [
            ("Choose topics", "Pick the categories you want in your deck before you start."),
            ("Play the cards", "Go around the group following each card’s prompt."),
            ("Pass the phone", "Take turns reading or let one host read for everyone.")
        ]
    }

    private static func playerCountLabel(for type: DeckType) -> String {
        switch type {
        case .spinTheBottle:
            return "3+ players"
        case .memoryMaster, .rhymeTime, .tapDuel, .quickfireCouples, .closerThanEver, .usAfterDark:
            return "2 players"
        case .hotPotato:
            return "3–10 players"
        case .colorClash:
            return "2–6 players"
        case .flip21:
            return "2–8 players"
        case .storyChain:
            return "2+ players"
        case .whatWouldYouDo:
            return "3–8 players"
        default:
            return "2+ players"
        }
    }

    private static func categoryTag(for deck: Deck) -> String? {
        if let first = deck.availableCategories.first {
            if deck.availableCategories.count > 1 {
                return "Multi-topic"
            }
            return first
        }
        switch deck.type {
        case .spinTheBottle, .hotPotato, .tapDuel, .memoryMaster, .rhymeTime:
            return "Party"
        case .colorClash, .flip21:
            return "Cards"
        case .quickfireCouples, .closerThanEver, .usAfterDark:
            return "Couples"
        case .riddleMeThis:
            return "Trivia"
        case .actItOut, .actNatural:
            return "Acting"
        case .whatWouldYouDo:
            return "Party"
        default:
            return "Party"
        }
    }

    // MARK: Online-only entry

    static func tags(for game: OnlineGameEntry) -> [String] {
        [
            "\(game.minPlayers)–\(game.maxPlayers) players",
            estimatedTimeForOnlineGameType(game.gameType),
            onlineCategoryPill(game.gameType)
        ]
    }

    static func playSteps(for game: OnlineGameEntry) -> [(title: String, detail: String)] {
        onlineSteps(forGameType: game.gameType, title: game.title)
    }

    // MARK: Online selection placeholder

    static func tags(for game: OnlineGamePlaceholder) -> [String] {
        var tags = ["\(game.minPlayers)–\(game.maxPlayers) players"]
        tags.append(estimatedTimeForOnlineGameType(game.gameType))
        if let first = game.availableCategories.first {
            tags.append(game.availableCategories.count > 1 ? "Multi-topic" : first)
        } else {
            tags.append(onlineCategoryPill(game.gameType))
        }
        return tags
    }

    static func playSteps(for game: OnlineGamePlaceholder) -> [(title: String, detail: String)] {
        onlineSteps(forGameType: game.gameType, title: game.title)
    }

    private static func estimatedTimeForOnlineGameType(_ gameType: String?) -> String {
        switch gameType {
        case "colorClash":
            return "~15 min"
        case "whatWouldYouDo":
            return "~20 min"
        case "flip21":
            return "~20 min"
        case "neverHaveIEver", "wouldYouRather", "truthOrDare", "mostLikelyTo", "twoTruthsAndALie", "storyChain":
            return "~20 min"
        case "actNatural":
            return "~25 min"
        default:
            return "~15 min"
        }
    }

    private static func onlineCategoryPill(_ gameType: String?) -> String {
        guard let gameType else { return "Online" }
        switch gameType {
        case "colorClash", "flip21":
            return "Cards"
        case "whatWouldYouDo":
            return "Party"
        case "neverHaveIEver", "wouldYouRather", "truthOrDare", "mostLikelyTo", "twoTruthsAndALie", "storyChain":
            return "Party"
        case "actNatural":
            return "Deduction"
        default:
            return "Online"
        }
    }

    private static func onlineSteps(forGameType gameType: String?, title: String) -> [(title: String, detail: String)] {
        switch gameType {
        case "colorClash":
            return [
                ("Create a room", "Tap Continue, then host a room for your friends."),
                ("Invite players", "Share the room code so everyone can join from Play."),
                ("Play your cards", "Match color or number, use action cards, and race to go out.")
            ]
        case "flip21":
            return [
                ("Join the table", "Create or join a room from the online lobby."),
                ("Play your hand", "Hit or stand against the dealer like classic 21."),
                ("Best hand wins", "Compare totals each round and keep score your way.")
            ]
        case "whatWouldYouDo":
            return [
                ("Read a prompt", "Everyone gets the same silly or tricky situation."),
                ("Pick in secret", "Choose what you would actually do — no judgment."),
                ("Reveal and laugh", "Compare answers and see who thinks alike. (Preview only for now.)")
            ]
        case "storyChain":
            return [
                ("Join the same room", "Host or enter a code so everyone is in one lobby."),
                ("Start the chain", "Read the opening line, then go in turn."),
                ("Finish together", "When the deck ends, read the full story from the top.")
            ]
        case "twoTruthsAndALie":
            return [
                ("Everyone joins", "Get into one online room with your group."),
                ("Share three statements", "On your turn, post or read two truths and one lie."),
                ("Vote and reveal", "Guess the lie, show the answer, then pass the turn.")
            ]
        case "mostLikelyTo":
            return [
                ("Start the room", "One host creates the game; others join with the code."),
                ("Read each prompt", "The card asks who’s most likely — discuss as a group."),
                ("Point and move on", "Agree on an answer, then reveal the next card.")
            ]
        case "actNatural":
            return [
                ("Join the lobby", "Everyone enters the same Act Natural room."),
                ("Learn your role", "Most players know the secret word; one player fakes it."),
                ("Talk, vote, reveal", "Discuss, pick who seems off, then see who was Unknown.")
            ]
        default:
            return [
                ("Open a room", "Host a game for \(title) or join with a code."),
                ("Wait in the lobby", "When everyone is ready, the host starts the match."),
                ("Follow the prompts", "Use on-screen cards and rules — same fun as in person.")
            ]
        }
    }
}
