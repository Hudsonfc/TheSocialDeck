//
//  GameOfTheDayManager.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

struct GameOfTheDayInfo {
    let title: String
    let description: String
    let imageName: String
    let type: DeckType
}

class GameOfTheDayManager {
    static let shared = GameOfTheDayManager()
    
    private let lastSelectionDateKey = "gameOfTheDayLastSelectionDate"
    private let selectedGameTypeKey = "gameOfTheDaySelectedType"
    
    // All available games for Game of the Day
    private let allGames: [GameOfTheDayInfo] = [
        // Classic Games
        GameOfTheDayInfo(title: "Never Have I Ever", description: "Reveal your wildest experiences and learn about your friends.", imageName: "NHIE 2.0", type: .neverHaveIEver),
        GameOfTheDayInfo(title: "Truth or Dare", description: "Choose truth or dare and see where the night takes you.", imageName: "TOD 2.0", type: .truthOrDare),
        GameOfTheDayInfo(title: "Would You Rather", description: "Make tough choices and discover what your friends prefer.", imageName: "WYR 2.0", type: .wouldYouRather),
        GameOfTheDayInfo(title: "Most Likely To", description: "Find out who's most likely to do crazy things.", imageName: "MLT 2.0", type: .mostLikelyTo),
        
        // Social Deck Games
        GameOfTheDayInfo(title: "Hot Potato", description: "Pass the phone quickly as the heat builds! The player holding it when time expires loses.", imageName: "HP 2.0", type: .hotPotato),
        GameOfTheDayInfo(title: "Rhyme Time", description: "Say a word that rhymes with the base word before time runs out!", imageName: "RT 2.0", type: .rhymeTime),
        GameOfTheDayInfo(title: "Tap Duel", description: "Fast head-to-head reaction game. Wait for GO, then tap first to win!", imageName: "TD 2.0", type: .tapDuel),
        GameOfTheDayInfo(title: "What's My Secret?", description: "One player gets a secret rule to follow. Can the group figure out what it is?", imageName: "WMS 2.0", type: .whatsMySecret),
        GameOfTheDayInfo(title: "Riddle Me This", description: "Solve riddles quickly! The first player to say the correct answer wins the round.", imageName: "RMT 2.0", type: .riddleMeThis),
        GameOfTheDayInfo(title: "Act It Out", description: "Act out prompts silently while others guess! First to guess correctly wins the round.", imageName: "AIO 2.0", type: .actItOut),
        GameOfTheDayInfo(title: "Category Clash", description: "Name items in a category before time runs out! Hesitate or repeat an answer and you're out.", imageName: "CC 2.0", type: .categoryClash),
        GameOfTheDayInfo(title: "Spin the Bottle", description: "Tap to spin and let the bottle decide everyone's fate. No strategy, no mercy, just pure chaos.", imageName: "STB 2.0", type: .spinTheBottle),
        GameOfTheDayInfo(title: "Story Chain", description: "Add one sentence to continue the story. Pass the phone and watch the chaos unfold.", imageName: "SC 2.0", type: .storyChain),
        GameOfTheDayInfo(title: "Memory Master", description: "A timed card-matching game. Flip cards to find pairs and clear the board as fast as possible!", imageName: "MM 2.0", type: .memoryMaster),
        GameOfTheDayInfo(title: "Bluff Call", description: "Convince the group your answer is true, or call their bluff!", imageName: "BC 2.0", type: .bluffCall)
    ]
    
    private init() {}
    
    /// Get today's game of the day, selecting a new one if it's a new day
    func getTodaysGame() -> GameOfTheDayInfo {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we have a stored selection and date
        if let lastSelectionDate = UserDefaults.standard.object(forKey: lastSelectionDateKey) as? Date,
           let selectedTypeString = UserDefaults.standard.string(forKey: selectedGameTypeKey),
           let selectedType = DeckType(rawValue: selectedTypeString) {
            let lastDate = calendar.startOfDay(for: lastSelectionDate)
            if calendar.isDate(lastDate, inSameDayAs: today) {
                // Same day, return the stored game
                if let game = allGames.first(where: { $0.type == selectedType }) {
                    return game
                }
            }
        }
        
        // New day or no stored game, select a random one
        let randomGame = allGames.randomElement() ?? allGames[0]
        
        // Store the selection
        UserDefaults.standard.set(today, forKey: lastSelectionDateKey)
        UserDefaults.standard.set(randomGame.type.rawValue, forKey: selectedGameTypeKey)
        
        return randomGame
    }
}

