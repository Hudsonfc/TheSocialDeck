//
//  SelectedGameDisplayCard.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import SwiftUI

// MARK: - Selected Game Display Card (for non-host players)

struct SelectedGameDisplayCard: View {
    let gameType: DeckType
    let category: String?
    
    private var gameTitle: String {
        switch gameType {
        case .neverHaveIEver: return "Never Have I Ever"
        case .truthOrDare: return "Truth or Dare"
        case .wouldYouRather: return "Would You Rather"
        case .mostLikelyTo: return "Most Likely To"
        case .twoTruthsAndALie: return "Two Truths and a Lie"
        case .popCultureTrivia: return "Pop Culture Trivia"
        case .historyTrivia: return "History Trivia"
        case .scienceTrivia: return "Science Trivia"
        case .sportsTrivia: return "Sports Trivia"
        case .movieTrivia: return "Movie Trivia"
        case .musicTrivia: return "Music Trivia"
        case .truthOrDrink: return "Truth or Drink"
        case .categoryClash: return "Category Clash"
        case .spinTheBottle: return "Spin the Bottle"
        case .storyChain: return "Story Chain"
        case .memoryMaster: return "Memory Master"
        case .bluffCall: return "Bluff Call"
        case .hotPotato: return "Hot Potato"
        case .rhymeTime: return "Rhyme Time"
        case .tapDuel: return "Tap Duel"
        case .whatsMySecret: return "What's My Secret?"
        case .riddleMeThis: return "Riddle Me This"
        case .colorClash: return "Color Clash"
        case .other: return "Game"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Game")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
            
            HStack(spacing: 16) {
                // Game icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0xF8/255.0, green: 0xF8/255.0, blue: 0xF8/255.0))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameTitle)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0x0A/255.0, green: 0x0A/255.0, blue: 0x0A/255.0))
                    
                    if let category = category {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                            Text(category)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0xD9/255.0, green: 0x3A/255.0, blue: 0x3A/255.0))
                        }
                    } else {
                        Text("Waiting for host to start...")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color.gray)
                    }
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

