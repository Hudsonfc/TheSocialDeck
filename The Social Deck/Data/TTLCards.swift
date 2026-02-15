//
//  TTLCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// All Two Truths and a Lie cards organized by category
// Note: For TTL, we'll use text field for statement 1, optionA for statement 2, optionB for statement 3
// The lie will be indicated in a separate property if needed, or we can use the first one as truth by default
let allTTLCards: [Card] = [
    // Party cards - placeholder
    Card(text: "I once danced on a table", category: "Party", cardType: nil, optionA: "I've never been to a concert", optionB: "I've been to 50+ parties"),
    Card(text: "I stayed until the very end of a party", category: "Party", cardType: nil, optionA: "I've never played ping pong", optionB: "I've kissed 10 strangers"),
    
    // Wild cards - placeholder
    Card(text: "I've been skydiving", category: "Wild", cardType: nil, optionA: "I've never traveled alone", optionB: "I've been to 20+ countries"),
    Card(text: "I've gone streaking", category: "Wild", cardType: nil, optionA: "I've never broken a bone", optionB: "I've jumped off a cliff"),
    
    // Couples cards - placeholder
    Card(text: "I've been in a long-distance relationship", category: "Couples", cardType: nil, optionA: "I've never been cheated on", optionB: "I've been engaged twice"),
    
    // Teens cards - placeholder
    Card(text: "I skipped school regularly", category: "Teens", cardType: nil, optionA: "I never got detention", optionB: "I was valedictorian"),
    
    // Dirty cards - placeholder
    Card(text: "I've sent nudes", category: "Dirty", cardType: nil, optionA: "I've never watched porn", optionB: "I've had a threesome"),
    
    // Friends cards - placeholder
    Card(text: "I've betrayed a friend", category: "Friends", cardType: nil, optionA: "I've never lied to a friend", optionB: "I have 100+ friends")
]

