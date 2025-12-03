//
//  ScienceTriviaCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// All Science Trivia cards organized by difficulty category
let allScienceTriviaCards: [Card] = [
    // Easy cards (7 cards)
    Card(text: "What is the chemical symbol for water?", category: "Easy", optionA: "H2O", optionB: "CO2", optionC: "O2", optionD: "NaCl", correctAnswer: "A"),
    Card(text: "How many planets are in our solar system?", category: "Easy", optionA: "7", optionB: "8", optionC: "9", optionD: "10", correctAnswer: "B"),
    Card(text: "What is the largest planet in our solar system?", category: "Easy", optionA: "Saturn", optionB: "Neptune", optionC: "Jupiter", optionD: "Uranus", correctAnswer: "C"),
    Card(text: "What gas do plants absorb from the atmosphere?", category: "Easy", optionA: "Oxygen", optionB: "Nitrogen", optionC: "Carbon Dioxide", optionD: "Hydrogen", correctAnswer: "C"),
    Card(text: "What is the hardest natural substance on Earth?", category: "Easy", optionA: "Gold", optionB: "Iron", optionC: "Diamond", optionD: "Platinum", correctAnswer: "C"),
    Card(text: "What is the speed of light in a vacuum?", category: "Easy", optionA: "186,000 miles per second", optionB: "299,792,458 meters per second", optionC: "3 x 10^8 m/s", optionD: "All of the above", correctAnswer: "D"),
    Card(text: "Which blood type is known as the universal donor?", category: "Easy", optionA: "A", optionB: "B", optionC: "AB", optionD: "O", correctAnswer: "D"),
    
    // Medium cards (7 cards)
    Card(text: "What is the smallest unit of matter?", category: "Medium", optionA: "Molecule", optionB: "Atom", optionC: "Electron", optionD: "Proton", correctAnswer: "B"),
    Card(text: "Which scientist proposed the theory of relativity?", category: "Medium", optionA: "Isaac Newton", optionB: "Albert Einstein", optionC: "Stephen Hawking", optionD: "Niels Bohr", correctAnswer: "B"),
    Card(text: "What is the process by which plants make food?", category: "Medium", optionA: "Respiration", optionB: "Photosynthesis", optionC: "Transpiration", optionD: "Digestion", correctAnswer: "B"),
    Card(text: "How many bones are in the human body?", category: "Medium", optionA: "196", optionB: "206", optionC: "216", optionD: "226", correctAnswer: "B"),
    Card(text: "What is the most abundant gas in Earth's atmosphere?", category: "Medium", optionA: "Oxygen", optionB: "Carbon Dioxide", optionC: "Nitrogen", optionD: "Argon", correctAnswer: "C"),
    Card(text: "Which organ produces insulin?", category: "Medium", optionA: "Liver", optionB: "Kidney", optionC: "Pancreas", optionD: "Stomach", correctAnswer: "C"),
    Card(text: "What is the study of fossils called?", category: "Medium", optionA: "Paleontology", optionB: "Archeology", optionC: "Geology", optionD: "Anthropology", correctAnswer: "A"),
    
    // Hard cards (6 cards)
    Card(text: "What is the name of the process that powers the sun?", category: "Hard", optionA: "Fusion", optionB: "Fission", optionC: "Combustion", optionD: "Oxidation", correctAnswer: "A"),
    Card(text: "What is Schrödinger's cat a thought experiment about?", category: "Hard", optionA: "Time dilation", optionB: "Quantum superposition", optionC: "Wave-particle duality", optionD: "Entanglement", correctAnswer: "B"),
    Card(text: "What is the approximate age of the universe?", category: "Hard", optionA: "10.5 billion years", optionB: "13.8 billion years", optionC: "15.2 billion years", optionD: "18.6 billion years", correctAnswer: "B"),
    Card(text: "What is the name of the largest moon of Saturn?", category: "Hard", optionA: "Europa", optionB: "Ganymede", optionC: "Titan", optionD: "Callisto", correctAnswer: "C"),
    Card(text: "What is the Pauli exclusion principle?", category: "Hard", optionA: "No two electrons can have the same quantum state", optionB: "Energy cannot be created or destroyed", optionC: "Matter and energy are equivalent", optionD: "The speed of light is constant", correctAnswer: "A"),
    Card(text: "What is the name of the particle that mediates the strong nuclear force?", category: "Hard", optionA: "Photon", optionB: "Gluon", optionC: "W boson", optionD: "Higgs boson", correctAnswer: "B")
]

