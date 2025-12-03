//
//  MovieTriviaCards.swift
//  The Social Deck
//
//  Created by Hudson Ferreira on 11/23/25.
//

import Foundation

// All Movie Trivia cards organized by difficulty category
let allMovieTriviaCards: [Card] = [
    // Easy cards (7 cards)
    Card(text: "Which movie features the line 'May the Force be with you'?", category: "Easy", optionA: "Star Trek", optionB: "Star Wars", optionC: "Blade Runner", optionD: "The Matrix", correctAnswer: "B"),
    Card(text: "Who played Jack in 'Titanic'?", category: "Easy", optionA: "Brad Pitt", optionB: "Leonardo DiCaprio", optionC: "Johnny Depp", optionD: "Tom Cruise", correctAnswer: "B"),
    Card(text: "What year did 'The Lion King' premiere?", category: "Easy", optionA: "1992", optionB: "1994", optionC: "1996", optionD: "1998", correctAnswer: "B"),
    Card(text: "Which film won Best Picture at the 2020 Oscars?", category: "Easy", optionA: "1917", optionB: "Joker", optionC: "Parasite", optionD: "Once Upon a Time in Hollywood", correctAnswer: "C"),
    Card(text: "Who directed 'The Godfather'?", category: "Easy", optionA: "Martin Scorsese", optionB: "Steven Spielberg", optionC: "Francis Ford Coppola", optionD: "Quentin Tarantino", correctAnswer: "C"),
    Card(text: "What is the highest-grossing film of all time?", category: "Easy", optionA: "Avatar", optionB: "Titanic", optionC: "Avengers: Endgame", optionD: "Avatar: The Way of Water", correctAnswer: "A"),
    Card(text: "Which actor played Tony Stark in the Marvel Cinematic Universe?", category: "Easy", optionA: "Chris Evans", optionB: "Chris Hemsworth", optionC: "Robert Downey Jr.", optionD: "Mark Ruffalo", correctAnswer: "C"),
    
    // Medium cards (7 cards)
    Card(text: "What is the name of the fictional company in 'The Office'?", category: "Medium", optionA: "Dunder Mifflin", optionB: "Paper Company Inc.", optionC: "Scranton Paper", optionD: "Michael Scott Paper", correctAnswer: "A"),
    Card(text: "Which director made 'Inception' and 'Interstellar'?", category: "Medium", optionA: "Christopher Nolan", optionB: "Denis Villeneuve", optionC: "Ridley Scott", optionD: "Darren Aronofsky", correctAnswer: "A"),
    Card(text: "What year did 'Pulp Fiction' premiere?", category: "Medium", optionA: "1992", optionB: "1994", optionC: "1996", optionD: "1998", correctAnswer: "B"),
    Card(text: "Which actress has won the most Oscars?", category: "Medium", optionA: "Meryl Streep", optionB: "Katharine Hepburn", optionC: "Ingrid Bergman", optionD: "Frances McDormand", correctAnswer: "B"),
    Card(text: "What is the name of the ship in 'Alien'?", category: "Medium", optionA: "Nostromo", optionB: "Sulaco", optionC: "Prometheus", optionD: "Covenant", correctAnswer: "A"),
    Card(text: "Which movie features 'Hakuna Matata'?", category: "Medium", optionA: "Aladdin", optionB: "The Lion King", optionC: "Pocahontas", optionD: "Mulan", correctAnswer: "B"),
    Card(text: "Who composed the score for 'Jaws'?", category: "Medium", optionA: "John Williams", optionB: "Hans Zimmer", optionC: "Ennio Morricone", optionD: "Bernard Herrmann", correctAnswer: "A"),
    
    // Hard cards (6 cards)
    Card(text: "What was the first film to win the Academy Award for Best Picture?", category: "Hard", optionA: "Wings", optionB: "Sunrise", optionC: "The Broadway Melody", optionD: "All Quiet on the Western Front", correctAnswer: "A"),
    Card(text: "Which film was the first to feature synchronized sound?", category: "Hard", optionA: "The Jazz Singer", optionB: "Steamboat Willie", optionC: "Don Juan", optionD: "Lights of New York", correctAnswer: "A"),
    Card(text: "Who directed 'Citizen Kane'?", category: "Hard", optionA: "Alfred Hitchcock", optionB: "Orson Welles", optionC: "John Ford", optionD: "Howard Hawks", correctAnswer: "B"),
    Card(text: "What is the name of the hotel in 'The Shining'?", category: "Hard", optionA: "The Overlook", optionB: "The Stanley", optionC: "The Timberline", optionD: "The Amityville", correctAnswer: "A"),
    Card(text: "Which film marked Tom Hanks' directorial debut?", category: "Hard", optionA: "That Thing You Do!", optionB: "Larry Crowne", optionC: "Ithaca", optionD: "Greyhound", correctAnswer: "A"),
    Card(text: "What is the highest-grossing R-rated film of all time?", category: "Hard", optionA: "Deadpool", optionB: "Deadpool 2", optionC: "It", optionD: "Joker", correctAnswer: "D")
]

