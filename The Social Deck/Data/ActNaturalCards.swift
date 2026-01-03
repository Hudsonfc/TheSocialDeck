//
//  ActNaturalCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 1/2/26.
//

import Foundation

struct ActNaturalWord: Identifiable {
    let id = UUID()
    let word: String
    let category: String
}

// Word list for Act Natural game
let actNaturalWords: [ActNaturalWord] = [
    // Animals
    ActNaturalWord(word: "Elephant", category: "Animals"),
    ActNaturalWord(word: "Penguin", category: "Animals"),
    ActNaturalWord(word: "Giraffe", category: "Animals"),
    ActNaturalWord(word: "Kangaroo", category: "Animals"),
    ActNaturalWord(word: "Dolphin", category: "Animals"),
    ActNaturalWord(word: "Butterfly", category: "Animals"),
    ActNaturalWord(word: "Octopus", category: "Animals"),
    ActNaturalWord(word: "Peacock", category: "Animals"),
    ActNaturalWord(word: "Hamster", category: "Animals"),
    ActNaturalWord(word: "Flamingo", category: "Animals"),
    ActNaturalWord(word: "Koala", category: "Animals"),
    ActNaturalWord(word: "Sloth", category: "Animals"),
    ActNaturalWord(word: "Parrot", category: "Animals"),
    ActNaturalWord(word: "Jellyfish", category: "Animals"),
    ActNaturalWord(word: "Chameleon", category: "Animals"),
    
    // Food & Drinks
    ActNaturalWord(word: "Pizza", category: "Food"),
    ActNaturalWord(word: "Sushi", category: "Food"),
    ActNaturalWord(word: "Taco", category: "Food"),
    ActNaturalWord(word: "Pancakes", category: "Food"),
    ActNaturalWord(word: "Ice Cream", category: "Food"),
    ActNaturalWord(word: "Popcorn", category: "Food"),
    ActNaturalWord(word: "Hamburger", category: "Food"),
    ActNaturalWord(word: "Chocolate", category: "Food"),
    ActNaturalWord(word: "Avocado", category: "Food"),
    ActNaturalWord(word: "Coffee", category: "Food"),
    ActNaturalWord(word: "Donut", category: "Food"),
    ActNaturalWord(word: "Smoothie", category: "Food"),
    ActNaturalWord(word: "Nachos", category: "Food"),
    ActNaturalWord(word: "Cupcake", category: "Food"),
    ActNaturalWord(word: "Pretzel", category: "Food"),
    
    // Places
    ActNaturalWord(word: "Beach", category: "Places"),
    ActNaturalWord(word: "Library", category: "Places"),
    ActNaturalWord(word: "Airport", category: "Places"),
    ActNaturalWord(word: "Museum", category: "Places"),
    ActNaturalWord(word: "Hospital", category: "Places"),
    ActNaturalWord(word: "Gym", category: "Places"),
    ActNaturalWord(word: "Restaurant", category: "Places"),
    ActNaturalWord(word: "Movie Theater", category: "Places"),
    ActNaturalWord(word: "Amusement Park", category: "Places"),
    ActNaturalWord(word: "Zoo", category: "Places"),
    ActNaturalWord(word: "Supermarket", category: "Places"),
    ActNaturalWord(word: "Casino", category: "Places"),
    ActNaturalWord(word: "Spa", category: "Places"),
    ActNaturalWord(word: "Nightclub", category: "Places"),
    ActNaturalWord(word: "Wedding", category: "Places"),
    
    // Objects
    ActNaturalWord(word: "Umbrella", category: "Objects"),
    ActNaturalWord(word: "Sunglasses", category: "Objects"),
    ActNaturalWord(word: "Backpack", category: "Objects"),
    ActNaturalWord(word: "Headphones", category: "Objects"),
    ActNaturalWord(word: "Candle", category: "Objects"),
    ActNaturalWord(word: "Mirror", category: "Objects"),
    ActNaturalWord(word: "Keyboard", category: "Objects"),
    ActNaturalWord(word: "Pillow", category: "Objects"),
    ActNaturalWord(word: "Balloon", category: "Objects"),
    ActNaturalWord(word: "Camera", category: "Objects"),
    ActNaturalWord(word: "Guitar", category: "Objects"),
    ActNaturalWord(word: "Skateboard", category: "Objects"),
    ActNaturalWord(word: "Telescope", category: "Objects"),
    ActNaturalWord(word: "Microphone", category: "Objects"),
    ActNaturalWord(word: "Suitcase", category: "Objects"),
    
    // Activities
    ActNaturalWord(word: "Swimming", category: "Activities"),
    ActNaturalWord(word: "Dancing", category: "Activities"),
    ActNaturalWord(word: "Cooking", category: "Activities"),
    ActNaturalWord(word: "Camping", category: "Activities"),
    ActNaturalWord(word: "Yoga", category: "Activities"),
    ActNaturalWord(word: "Surfing", category: "Activities"),
    ActNaturalWord(word: "Karaoke", category: "Activities"),
    ActNaturalWord(word: "Bowling", category: "Activities"),
    ActNaturalWord(word: "Hiking", category: "Activities"),
    ActNaturalWord(word: "Fishing", category: "Activities"),
    ActNaturalWord(word: "Painting", category: "Activities"),
    ActNaturalWord(word: "Gardening", category: "Activities"),
    ActNaturalWord(word: "Meditation", category: "Activities"),
    ActNaturalWord(word: "Shopping", category: "Activities"),
    ActNaturalWord(word: "Skydiving", category: "Activities"),
    
    // Professions
    ActNaturalWord(word: "Chef", category: "Professions"),
    ActNaturalWord(word: "Doctor", category: "Professions"),
    ActNaturalWord(word: "Pilot", category: "Professions"),
    ActNaturalWord(word: "Firefighter", category: "Professions"),
    ActNaturalWord(word: "Teacher", category: "Professions"),
    ActNaturalWord(word: "Astronaut", category: "Professions"),
    ActNaturalWord(word: "Detective", category: "Professions"),
    ActNaturalWord(word: "Magician", category: "Professions"),
    ActNaturalWord(word: "Lifeguard", category: "Professions"),
    ActNaturalWord(word: "DJ", category: "Professions"),
    ActNaturalWord(word: "Barista", category: "Professions"),
    ActNaturalWord(word: "Comedian", category: "Professions"),
    ActNaturalWord(word: "Tattoo Artist", category: "Professions"),
    ActNaturalWord(word: "Personal Trainer", category: "Professions"),
    ActNaturalWord(word: "Tour Guide", category: "Professions"),
    
    // Movies & TV
    ActNaturalWord(word: "Star Wars", category: "Movies"),
    ActNaturalWord(word: "Harry Potter", category: "Movies"),
    ActNaturalWord(word: "The Office", category: "Movies"),
    ActNaturalWord(word: "Friends", category: "Movies"),
    ActNaturalWord(word: "Titanic", category: "Movies"),
    ActNaturalWord(word: "Stranger Things", category: "Movies"),
    ActNaturalWord(word: "Game of Thrones", category: "Movies"),
    ActNaturalWord(word: "The Lion King", category: "Movies"),
    ActNaturalWord(word: "Breaking Bad", category: "Movies"),
    ActNaturalWord(word: "Spider-Man", category: "Movies"),
    ActNaturalWord(word: "The Avengers", category: "Movies"),
    ActNaturalWord(word: "Jurassic Park", category: "Movies"),
    ActNaturalWord(word: "Finding Nemo", category: "Movies"),
    ActNaturalWord(word: "The Matrix", category: "Movies"),
    ActNaturalWord(word: "Shrek", category: "Movies"),
    
    // Celebrities
    ActNaturalWord(word: "Beyoncé", category: "Celebrities"),
    ActNaturalWord(word: "Taylor Swift", category: "Celebrities"),
    ActNaturalWord(word: "LeBron James", category: "Celebrities"),
    ActNaturalWord(word: "Oprah", category: "Celebrities"),
    ActNaturalWord(word: "Elon Musk", category: "Celebrities"),
    ActNaturalWord(word: "Kim Kardashian", category: "Celebrities"),
    ActNaturalWord(word: "Dwayne Johnson", category: "Celebrities"),
    ActNaturalWord(word: "Ariana Grande", category: "Celebrities"),
    ActNaturalWord(word: "Drake", category: "Celebrities"),
    ActNaturalWord(word: "Rihanna", category: "Celebrities"),
    ActNaturalWord(word: "Cristiano Ronaldo", category: "Celebrities"),
    ActNaturalWord(word: "Lady Gaga", category: "Celebrities"),
    ActNaturalWord(word: "Bruno Mars", category: "Celebrities"),
    ActNaturalWord(word: "Selena Gomez", category: "Celebrities"),
    ActNaturalWord(word: "Post Malone", category: "Celebrities"),
    
    // Holidays & Events
    ActNaturalWord(word: "Halloween", category: "Holidays"),
    ActNaturalWord(word: "Christmas", category: "Holidays"),
    ActNaturalWord(word: "Birthday Party", category: "Holidays"),
    ActNaturalWord(word: "New Year's Eve", category: "Holidays"),
    ActNaturalWord(word: "Super Bowl", category: "Holidays"),
    ActNaturalWord(word: "Graduation", category: "Holidays"),
    ActNaturalWord(word: "Valentine's Day", category: "Holidays"),
    ActNaturalWord(word: "Prom", category: "Holidays"),
    ActNaturalWord(word: "Concert", category: "Holidays"),
    ActNaturalWord(word: "Road Trip", category: "Holidays"),
    ActNaturalWord(word: "Barbecue", category: "Holidays"),
    ActNaturalWord(word: "Pool Party", category: "Holidays"),
    ActNaturalWord(word: "Bachelor Party", category: "Holidays"),
    ActNaturalWord(word: "Thanksgiving", category: "Holidays"),
    ActNaturalWord(word: "Spring Break", category: "Holidays"),
    
    // Emotions & States
    ActNaturalWord(word: "Hangover", category: "States"),
    ActNaturalWord(word: "Jet Lag", category: "States"),
    ActNaturalWord(word: "First Date", category: "States"),
    ActNaturalWord(word: "Job Interview", category: "States"),
    ActNaturalWord(word: "Monday Morning", category: "States"),
    ActNaturalWord(word: "Friday Night", category: "States"),
    ActNaturalWord(word: "Food Coma", category: "States"),
    ActNaturalWord(word: "All-Nighter", category: "States"),
    ActNaturalWord(word: "Vacation Mode", category: "States"),
    ActNaturalWord(word: "Gym Session", category: "States"),
    ActNaturalWord(word: "Netflix Binge", category: "States"),
    ActNaturalWord(word: "Late Night Snack", category: "States"),
    ActNaturalWord(word: "Awkward Silence", category: "States"),
    ActNaturalWord(word: "Group Project", category: "States"),
    ActNaturalWord(word: "Waiting Room", category: "States")
]

