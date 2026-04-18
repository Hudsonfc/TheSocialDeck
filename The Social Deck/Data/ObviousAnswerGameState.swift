//
//  ObviousAnswerGameState.swift
//  The Social Deck
//
//  Data model for The Obvious Answer online game.
//  Phases: answering → results → (next round or finished)
//  Scoring: exact match (case-insensitive, trimmed) against the stored correct answer.
//

import Foundation

// MARK: - Phase

enum ObviousAnswerPhase: String, Codable, Equatable {
    case answering
    case results
    case finished
}

// MARK: - Prompt + answer

struct ObviousAnswerPrompt: Codable, Equatable, Hashable {
    /// Fill-in-the-blank sentence; contains exactly "___" as the blank.
    let prompt: String
    /// The single correct completion (compared with `normalizeForMatch`).
    let correctAnswer: String
}

// MARK: - Game State

struct ObviousAnswerGameState: Codable, Equatable {
    /// 0-based round index.
    var currentRound: Int
    var totalRounds: Int
    /// The fill-in-the-blank prompt for the current round (contains "___").
    var currentPrompt: String
    /// The official correct answer for this round (stored in Firestore for sync).
    var correctAnswer: String
    /// userId → submitted answer. Absent key means the player hasn't answered yet.
    var answers: [String: String]
    var phase: ObviousAnswerPhase
    /// Cumulative scores across all rounds.
    var scores: [String: Int]

    private enum CodingKeys: String, CodingKey {
        case currentRound, totalRounds, currentPrompt, correctAnswer, answers, phase, scores
    }

    init(
        currentRound: Int = 0,
        totalRounds: Int = 5,
        currentPrompt: String = "",
        correctAnswer: String = "",
        answers: [String: String] = [:],
        phase: ObviousAnswerPhase = .answering,
        scores: [String: Int] = [:]
    ) {
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.currentPrompt = currentPrompt
        self.correctAnswer = correctAnswer
        self.answers = answers
        self.phase = phase
        self.scores = scores
    }

    /// Normalizes for comparison: trim, lowercase, strip punctuation except spaces
    /// so minor typing differences (apostrophes, etc.) still match the official answer.
    static func normalizeForMatch(_ s: String) -> String {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let filtered = trimmed.filter { $0.isLetter || $0.isNumber || $0 == " " }
        return filtered
            .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}

// MARK: - Prompts

/// Curated fill-in-the-blank prompts with one unambiguous correct answer each (world-trivia style).
/// The blank ("___") appears in different positions throughout the sentences.
let allObviousAnswerPrompts: [ObviousAnswerPrompt] = [
    ObviousAnswerPrompt(prompt: "___ is the most famous painting in the world.", correctAnswer: "Mona Lisa"),
    ObviousAnswerPrompt(prompt: "Humans need ___ to survive.", correctAnswer: "oxygen"),
    ObviousAnswerPrompt(prompt: "There are ___ hours in a day.", correctAnswer: "24"),
    ObviousAnswerPrompt(prompt: "A week has ___ days.", correctAnswer: "seven"),
    ObviousAnswerPrompt(prompt: "The ___ is the star at the center of our solar system.", correctAnswer: "Sun"),
    ObviousAnswerPrompt(prompt: "The ___ is Earth's natural satellite.", correctAnswer: "Moon"),
    ObviousAnswerPrompt(prompt: "Water freezes at ___ degrees Celsius.", correctAnswer: "0"),
    ObviousAnswerPrompt(prompt: "Water boils at ___ degrees Celsius at sea level.", correctAnswer: "100"),
    ObviousAnswerPrompt(prompt: "There are ___ continents on Earth.", correctAnswer: "seven"),
    ObviousAnswerPrompt(prompt: "The ___ Ocean is the largest ocean on Earth.", correctAnswer: "Pacific"),
    ObviousAnswerPrompt(prompt: "A circle has ___ degrees.", correctAnswer: "360"),
    ObviousAnswerPrompt(prompt: "A triangle has ___ sides.", correctAnswer: "three"),
    ObviousAnswerPrompt(prompt: "A square has ___ equal sides.", correctAnswer: "four"),
    ObviousAnswerPrompt(prompt: "There are ___ minutes in an hour.", correctAnswer: "60"),
    ObviousAnswerPrompt(prompt: "There are ___ seconds in a minute.", correctAnswer: "60"),
    ObviousAnswerPrompt(prompt: "A year has ___ months.", correctAnswer: "12"),
    ObviousAnswerPrompt(prompt: "There are ___ days in a leap year.", correctAnswer: "366"),
    ObviousAnswerPrompt(prompt: "Ice is frozen ___.", correctAnswer: "water"),
    ObviousAnswerPrompt(prompt: "The largest land animal is the ___.", correctAnswer: "elephant"),
    ObviousAnswerPrompt(prompt: "The smallest planet in our solar system is ___.", correctAnswer: "Mercury"),
    ObviousAnswerPrompt(prompt: "The largest planet in our solar system is ___.", correctAnswer: "Jupiter"),
    ObviousAnswerPrompt(prompt: "Earth is the ___ planet from the Sun.", correctAnswer: "third"),
    ObviousAnswerPrompt(prompt: "The speed of light is faster than the speed of ___.", correctAnswer: "sound"),
    ObviousAnswerPrompt(prompt: "A century is ___ years.", correctAnswer: "100"),
    ObviousAnswerPrompt(prompt: "A dozen equals ___.", correctAnswer: "twelve"),
    ObviousAnswerPrompt(prompt: "There are ___ players on a soccer team on the field at once per side.", correctAnswer: "11"),
    ObviousAnswerPrompt(prompt: "There are ___ colors in a rainbow.", correctAnswer: "seven"),
    ObviousAnswerPrompt(prompt: "The three primary colors of light are red, green, and ___.", correctAnswer: "blue"),
    ObviousAnswerPrompt(prompt: "Diamond is made of ___.", correctAnswer: "carbon"),
    ObviousAnswerPrompt(prompt: "Table salt is mostly sodium ___.", correctAnswer: "chloride"),
    ObviousAnswerPrompt(prompt: "The chemical symbol for water is ___.", correctAnswer: "H2O"),
    ObviousAnswerPrompt(prompt: "Chlorophyll makes plants look ___.", correctAnswer: "green"),
    ObviousAnswerPrompt(prompt: "The center of an atom is called the ___.", correctAnswer: "nucleus"),
    ObviousAnswerPrompt(prompt: "There are ___ legs on a spider.", correctAnswer: "eight"),
    ObviousAnswerPrompt(prompt: "The human body is mostly ___.", correctAnswer: "water"),
    ObviousAnswerPrompt(prompt: "The Eiffel Tower is in ___.", correctAnswer: "Paris"),
    ObviousAnswerPrompt(prompt: "The capital of Japan is ___.", correctAnswer: "Tokyo"),
    ObviousAnswerPrompt(prompt: "The Great Wall is in ___.", correctAnswer: "China"),
    ObviousAnswerPrompt(prompt: "The longest river in the world is the ___ River.", correctAnswer: "Nile"),
    ObviousAnswerPrompt(prompt: "Mount ___ is the tallest mountain on Earth above sea level.", correctAnswer: "Everest"),
    ObviousAnswerPrompt(prompt: "The largest country by area is ___.", correctAnswer: "Russia"),
    ObviousAnswerPrompt(prompt: "The smallest country in the world is ___.", correctAnswer: "Vatican"),
    ObviousAnswerPrompt(prompt: "The coldest continent is ___.", correctAnswer: "Antarctica"),
    ObviousAnswerPrompt(prompt: "The largest desert in the world is the ___ Desert.", correctAnswer: "Sahara"),
    ObviousAnswerPrompt(prompt: "There are ___ zeros in one million.", correctAnswer: "six"),
    ObviousAnswerPrompt(prompt: "The first month of the year is ___.", correctAnswer: "January"),
    ObviousAnswerPrompt(prompt: "Christmas Day is December ___.", correctAnswer: "25"),
    ObviousAnswerPrompt(prompt: "There are ___ days in February in a common year.", correctAnswer: "28"),
    ObviousAnswerPrompt(prompt: "A hexagon has ___ sides.", correctAnswer: "six"),
    ObviousAnswerPrompt(prompt: "The chemical symbol for gold is ___.", correctAnswer: "Au"),
    ObviousAnswerPrompt(prompt: "The capital of France is ___.", correctAnswer: "Paris"),
    ObviousAnswerPrompt(prompt: "The capital of Italy is ___.", correctAnswer: "Rome"),
    ObviousAnswerPrompt(prompt: "The capital of England is ___.", correctAnswer: "London"),
    ObviousAnswerPrompt(prompt: "The capital of Egypt is ___.", correctAnswer: "Cairo"),
    ObviousAnswerPrompt(prompt: "The capital of the United States is ___.", correctAnswer: "Washington DC"),
    ObviousAnswerPrompt(prompt: "The Statue of Liberty is in the city of ___.", correctAnswer: "New York"),
    ObviousAnswerPrompt(prompt: "The official language of Brazil is ___.", correctAnswer: "Portuguese"),
    ObviousAnswerPrompt(prompt: "The official language of Argentina is ___.", correctAnswer: "Spanish"),
    ObviousAnswerPrompt(prompt: "The currency of the United Kingdom is the ___.", correctAnswer: "pound"),
    ObviousAnswerPrompt(prompt: "The currency of the European Union is the ___.", correctAnswer: "euro"),
    ObviousAnswerPrompt(prompt: "The currency of Japan is the ___.", correctAnswer: "yen"),
    ObviousAnswerPrompt(prompt: "There are ___ chambers in the human heart.", correctAnswer: "four"),
    ObviousAnswerPrompt(prompt: "Adult humans normally have ___ teeth.", correctAnswer: "32"),
    ObviousAnswerPrompt(prompt: "The largest organ in the human body is the ___.", correctAnswer: "skin"),
    ObviousAnswerPrompt(prompt: "Sound travels faster through ___ than through air.", correctAnswer: "water"),
    ObviousAnswerPrompt(prompt: "The boiling point of water at sea level in Fahrenheit is ___.", correctAnswer: "212"),
    ObviousAnswerPrompt(prompt: "The freezing point of water in Fahrenheit is ___.", correctAnswer: "32"),
    ObviousAnswerPrompt(prompt: "There are ___ planets in our solar system.", correctAnswer: "eight"),
    ObviousAnswerPrompt(prompt: "The red planet in our solar system is ___.", correctAnswer: "Mars"),
    ObviousAnswerPrompt(prompt: "The hottest planet in our solar system is ___.", correctAnswer: "Venus"),
    ObviousAnswerPrompt(prompt: "Saturn is famous for its ___.", correctAnswer: "rings"),
    ObviousAnswerPrompt(prompt: "Astronauts experience ___ in space.", correctAnswer: "weightlessness"),
    ObviousAnswerPrompt(prompt: "The chemical symbol for silver is ___.", correctAnswer: "Ag"),
    ObviousAnswerPrompt(prompt: "The chemical symbol for sodium is ___.", correctAnswer: "Na"),
    ObviousAnswerPrompt(prompt: "The chemical symbol for potassium is ___.", correctAnswer: "K"),
    ObviousAnswerPrompt(prompt: "The pH of a neutral substance is ___.", correctAnswer: "7"),
    ObviousAnswerPrompt(prompt: "An octagon has ___ sides.", correctAnswer: "eight"),
    ObviousAnswerPrompt(prompt: "A pentagon has ___ sides.", correctAnswer: "five"),
    ObviousAnswerPrompt(prompt: "Pi rounded to two decimal places is ___.", correctAnswer: "3.14"),
    ObviousAnswerPrompt(prompt: "The square root of 81 is ___.", correctAnswer: "9"),
    ObviousAnswerPrompt(prompt: "The square root of 100 is ___.", correctAnswer: "10"),
    ObviousAnswerPrompt(prompt: "12 multiplied by 12 equals ___.", correctAnswer: "144"),
    ObviousAnswerPrompt(prompt: "The Roman numeral X represents the number ___.", correctAnswer: "10"),
    ObviousAnswerPrompt(prompt: "The Roman numeral L represents the number ___.", correctAnswer: "50"),
    ObviousAnswerPrompt(prompt: "The Roman numeral C represents the number ___.", correctAnswer: "100"),
    ObviousAnswerPrompt(prompt: "The official language of Germany is ___.", correctAnswer: "German"),
    ObviousAnswerPrompt(prompt: "The pyramids of Giza are in ___.", correctAnswer: "Egypt"),
    ObviousAnswerPrompt(prompt: "The Colosseum is in ___.", correctAnswer: "Rome"),
    ObviousAnswerPrompt(prompt: "The Leaning Tower of ___ is a famous landmark in Italy.", correctAnswer: "Pisa"),
    ObviousAnswerPrompt(prompt: "The Taj Mahal is in ___.", correctAnswer: "India"),
    ObviousAnswerPrompt(prompt: "The Sydney Opera House is in ___.", correctAnswer: "Australia"),
    ObviousAnswerPrompt(prompt: "Vatican City is located inside the city of ___.", correctAnswer: "Rome"),
    ObviousAnswerPrompt(prompt: "The Amazon rainforest is mostly located in ___.", correctAnswer: "Brazil"),
    ObviousAnswerPrompt(prompt: "The driest continent on Earth is ___.", correctAnswer: "Antarctica"),
    ObviousAnswerPrompt(prompt: "The smallest continent is ___.", correctAnswer: "Australia"),
    ObviousAnswerPrompt(prompt: "Jupiter's most famous storm is called the Great Red ___.", correctAnswer: "Spot"),
    ObviousAnswerPrompt(prompt: "The Sun is mostly made of ___.", correctAnswer: "hydrogen"),
    ObviousAnswerPrompt(prompt: "There are ___ players on a basketball team on the court at one time per side.", correctAnswer: "five"),
    ObviousAnswerPrompt(prompt: "There are ___ innings in a standard baseball game.", correctAnswer: "nine"),
    ObviousAnswerPrompt(prompt: "There are ___ rings on the Olympic flag.", correctAnswer: "five"),
    ObviousAnswerPrompt(prompt: "The Tour de France is held in ___.", correctAnswer: "France"),
    ObviousAnswerPrompt(prompt: "The Wimbledon tennis tournament is held in ___.", correctAnswer: "England"),
    ObviousAnswerPrompt(prompt: "The first Harry Potter book is 'Harry Potter and the ___ Stone' (US title).", correctAnswer: "Sorcerer's"),
    ObviousAnswerPrompt(prompt: "Sherlock Holmes lived at 221B ___ Street.", correctAnswer: "Baker"),
    ObviousAnswerPrompt(prompt: "The author of 'Romeo and Juliet' is ___.", correctAnswer: "Shakespeare"),
    ObviousAnswerPrompt(prompt: "Mickey Mouse was created by Walt ___.", correctAnswer: "Disney"),
    ObviousAnswerPrompt(prompt: "The lead singer of Queen was Freddie ___.", correctAnswer: "Mercury"),
    ObviousAnswerPrompt(prompt: "The Beatles came from the city of ___.", correctAnswer: "Liverpool"),
    ObviousAnswerPrompt(prompt: "The Mona Lisa was painted by Leonardo da ___.", correctAnswer: "Vinci"),
    ObviousAnswerPrompt(prompt: "Albert ___ developed the theory of relativity.", correctAnswer: "Einstein"),
    ObviousAnswerPrompt(prompt: "The light bulb is most associated with the inventor Thomas ___.", correctAnswer: "Edison"),
    ObviousAnswerPrompt(prompt: "The first president of the United States was George ___.", correctAnswer: "Washington"),
    ObviousAnswerPrompt(prompt: "The 16th president of the United States was Abraham ___.", correctAnswer: "Lincoln"),
    ObviousAnswerPrompt(prompt: "The Apollo ___ mission landed the first humans on the Moon.", correctAnswer: "11"),
    ObviousAnswerPrompt(prompt: "The first person to walk on the Moon was Neil ___.", correctAnswer: "Armstrong"),
    ObviousAnswerPrompt(prompt: "The Titanic sank in the year ___.", correctAnswer: "1912"),
    ObviousAnswerPrompt(prompt: "World War I started in the year ___.", correctAnswer: "1914"),
    ObviousAnswerPrompt(prompt: "World War II ended in the year ___.", correctAnswer: "1945"),
    ObviousAnswerPrompt(prompt: "The Great Wall of China was built mainly to defend against invaders from the ___.", correctAnswer: "north"),
    ObviousAnswerPrompt(prompt: "The currency of India is the ___.", correctAnswer: "rupee"),
    ObviousAnswerPrompt(prompt: "The capital of South Korea is ___.", correctAnswer: "Seoul"),
    ObviousAnswerPrompt(prompt: "The capital of Spain is ___.", correctAnswer: "Madrid"),
    ObviousAnswerPrompt(prompt: "The capital of Russia is ___.", correctAnswer: "Moscow"),
    ObviousAnswerPrompt(prompt: "The capital of Mexico is ___ City.", correctAnswer: "Mexico"),
    ObviousAnswerPrompt(prompt: "The official language of China is ___.", correctAnswer: "Mandarin"),
    ObviousAnswerPrompt(prompt: "The largest ocean on Earth is the ___ Ocean.", correctAnswer: "Pacific"),
    ObviousAnswerPrompt(prompt: "The smallest ocean on Earth is the ___ Ocean.", correctAnswer: "Arctic")
]
