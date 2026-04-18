//
//  OverconfidenceGameState.swift
//  The Social Deck
//
//  Data model for Overconfidence online game.
//  Phases: answering → results → (next round or finished)
//  Scoring: correct = +confidence, wrong = −confidence. Scores can go negative.
//

import Foundation

// MARK: - Phase

enum OverconfidencePhase: String, Codable, Equatable {
    case answering
    case results
    case finished
}

// MARK: - Trivia question

struct OverconfidenceQuestion: Codable, Equatable, Hashable {
    let question: String
    /// Exactly 4 options. The order is randomized server-side on round start.
    let options: [String]
    /// Must match one of the strings in `options` exactly.
    let correctAnswer: String
}

// MARK: - Per-player submission

struct OverconfidenceSubmission: Codable, Equatable {
    var answer: String
    /// 0–100
    var confidence: Int
}

// MARK: - Game State

struct OverconfidenceGameState: Codable, Equatable {
    /// 0-based round index.
    var currentRound: Int
    var totalRounds: Int
    /// The trivia question text for this round.
    var currentQuestion: String
    /// The four answer options presented to players (shuffled when the round begins).
    var currentOptions: [String]
    /// The correct answer string (must match one of `currentOptions`).
    var correctAnswer: String
    /// userId → submission (answer + confidence). Absent = not yet submitted.
    var submissions: [String: OverconfidenceSubmission]
    var phase: OverconfidencePhase
    /// Cumulative scores across all rounds (can be negative).
    var scores: [String: Int]

    private enum CodingKeys: String, CodingKey {
        case currentRound, totalRounds, currentQuestion, currentOptions, correctAnswer, submissions, phase, scores
    }

    init(
        currentRound: Int = 0,
        totalRounds: Int = 5,
        currentQuestion: String = "",
        currentOptions: [String] = [],
        correctAnswer: String = "",
        submissions: [String: OverconfidenceSubmission] = [:],
        phase: OverconfidencePhase = .answering,
        scores: [String: Int] = [:]
    ) {
        self.currentRound = currentRound
        self.totalRounds = totalRounds
        self.currentQuestion = currentQuestion
        self.currentOptions = currentOptions
        self.correctAnswer = correctAnswer
        self.submissions = submissions
        self.phase = phase
        self.scores = scores
    }
}

// MARK: - Questions bank (50+)

let allOverconfidenceQuestions: [OverconfidenceQuestion] = [
    OverconfidenceQuestion(
        question: "What is the capital of Australia?",
        options: ["Sydney", "Melbourne", "Canberra", "Brisbane"],
        correctAnswer: "Canberra"
    ),
    OverconfidenceQuestion(
        question: "How many bones are in the adult human body?",
        options: ["196", "206", "216", "226"],
        correctAnswer: "206"
    ),
    OverconfidenceQuestion(
        question: "Which planet has the most moons in our solar system?",
        options: ["Jupiter", "Saturn", "Uranus", "Neptune"],
        correctAnswer: "Saturn"
    ),
    OverconfidenceQuestion(
        question: "What is the chemical symbol for iron?",
        options: ["Ir", "In", "Fe", "Fo"],
        correctAnswer: "Fe"
    ),
    OverconfidenceQuestion(
        question: "In which year did the Berlin Wall fall?",
        options: ["1987", "1988", "1989", "1991"],
        correctAnswer: "1989"
    ),
    OverconfidenceQuestion(
        question: "Which ocean is the largest?",
        options: ["Atlantic", "Indian", "Pacific", "Arctic"],
        correctAnswer: "Pacific"
    ),
    OverconfidenceQuestion(
        question: "What is the square root of 144?",
        options: ["10", "11", "12", "14"],
        correctAnswer: "12"
    ),
    OverconfidenceQuestion(
        question: "Who painted the Sistine Chapel ceiling?",
        options: ["Leonardo da Vinci", "Raphael", "Michelangelo", "Caravaggio"],
        correctAnswer: "Michelangelo"
    ),
    OverconfidenceQuestion(
        question: "What is the longest river in the world?",
        options: ["Amazon", "Yangtze", "Mississippi", "Nile"],
        correctAnswer: "Nile"
    ),
    OverconfidenceQuestion(
        question: "How many chromosomes do humans normally have?",
        options: ["23", "44", "46", "48"],
        correctAnswer: "46"
    ),
    OverconfidenceQuestion(
        question: "What is the hardest natural substance on Earth?",
        options: ["Quartz", "Titanium", "Diamond", "Graphite"],
        correctAnswer: "Diamond"
    ),
    OverconfidenceQuestion(
        question: "What gas do plants absorb during photosynthesis?",
        options: ["Oxygen", "Nitrogen", "Carbon dioxide", "Hydrogen"],
        correctAnswer: "Carbon dioxide"
    ),
    OverconfidenceQuestion(
        question: "Which country has the largest population?",
        options: ["USA", "India", "China", "Indonesia"],
        correctAnswer: "India"
    ),
    OverconfidenceQuestion(
        question: "What is the speed of light in km/s (approximately)?",
        options: ["200,000", "300,000", "400,000", "500,000"],
        correctAnswer: "300,000"
    ),
    OverconfidenceQuestion(
        question: "How many sides does a dodecagon have?",
        options: ["10", "11", "12", "14"],
        correctAnswer: "12"
    ),
    OverconfidenceQuestion(
        question: "Which element has the atomic number 1?",
        options: ["Helium", "Oxygen", "Hydrogen", "Carbon"],
        correctAnswer: "Hydrogen"
    ),
    OverconfidenceQuestion(
        question: "In what year did World War II end?",
        options: ["1943", "1944", "1945", "1946"],
        correctAnswer: "1945"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Canada?",
        options: ["Toronto", "Vancouver", "Ottawa", "Montreal"],
        correctAnswer: "Ottawa"
    ),
    OverconfidenceQuestion(
        question: "Which Shakespeare play features the character Ophelia?",
        options: ["Macbeth", "Hamlet", "Othello", "King Lear"],
        correctAnswer: "Hamlet"
    ),
    OverconfidenceQuestion(
        question: "What is 15% of 200?",
        options: ["25", "30", "35", "40"],
        correctAnswer: "30"
    ),
    OverconfidenceQuestion(
        question: "How many strings does a standard guitar have?",
        options: ["4", "5", "6", "7"],
        correctAnswer: "6"
    ),
    OverconfidenceQuestion(
        question: "Which planet is closest to the Sun?",
        options: ["Venus", "Mercury", "Earth", "Mars"],
        correctAnswer: "Mercury"
    ),
    OverconfidenceQuestion(
        question: "Who wrote '1984'?",
        options: ["Aldous Huxley", "Ray Bradbury", "George Orwell", "H.G. Wells"],
        correctAnswer: "George Orwell"
    ),
    OverconfidenceQuestion(
        question: "How many players are on a basketball team on the court at once?",
        options: ["4", "5", "6", "7"],
        correctAnswer: "5"
    ),
    OverconfidenceQuestion(
        question: "What is the currency of Japan?",
        options: ["Yuan", "Won", "Yen", "Ringgit"],
        correctAnswer: "Yen"
    ),
    OverconfidenceQuestion(
        question: "Which organ produces insulin?",
        options: ["Liver", "Kidney", "Pancreas", "Spleen"],
        correctAnswer: "Pancreas"
    ),
    OverconfidenceQuestion(
        question: "What is the tallest mountain in the world?",
        options: ["K2", "Kangchenjunga", "Mount Everest", "Lhotse"],
        correctAnswer: "Mount Everest"
    ),
    OverconfidenceQuestion(
        question: "How many degrees are in a right angle?",
        options: ["45", "60", "90", "180"],
        correctAnswer: "90"
    ),
    OverconfidenceQuestion(
        question: "Who was the first person to walk on the Moon?",
        options: ["Buzz Aldrin", "Yuri Gagarin", "Neil Armstrong", "John Glenn"],
        correctAnswer: "Neil Armstrong"
    ),
    OverconfidenceQuestion(
        question: "Which continent is the Sahara Desert on?",
        options: ["Asia", "Australia", "Africa", "South America"],
        correctAnswer: "Africa"
    ),
    OverconfidenceQuestion(
        question: "What is the chemical formula for table salt?",
        options: ["NaCl", "KCl", "MgCl", "CaCl"],
        correctAnswer: "NaCl"
    ),
    OverconfidenceQuestion(
        question: "In computing, what does 'CPU' stand for?",
        options: ["Computer Processing Unit", "Central Processor Unit", "Central Processing Unit", "Core Processing Unit"],
        correctAnswer: "Central Processing Unit"
    ),
    OverconfidenceQuestion(
        question: "How many time zones does Russia have?",
        options: ["9", "10", "11", "12"],
        correctAnswer: "11"
    ),
    OverconfidenceQuestion(
        question: "What is the largest mammal in the world?",
        options: ["African Elephant", "Giraffe", "Blue Whale", "Polar Bear"],
        correctAnswer: "Blue Whale"
    ),
    OverconfidenceQuestion(
        question: "Which blood type is the universal donor?",
        options: ["A+", "O+", "AB−", "O−"],
        correctAnswer: "O−"
    ),
    OverconfidenceQuestion(
        question: "What year was the iPhone first released?",
        options: ["2005", "2006", "2007", "2008"],
        correctAnswer: "2007"
    ),
    OverconfidenceQuestion(
        question: "What is the powerhouse of the cell?",
        options: ["Nucleus", "Ribosome", "Mitochondria", "Golgi apparatus"],
        correctAnswer: "Mitochondria"
    ),
    OverconfidenceQuestion(
        question: "How many teeth does an adult human normally have?",
        options: ["28", "30", "32", "34"],
        correctAnswer: "32"
    ),
    OverconfidenceQuestion(
        question: "Which country invented pizza?",
        options: ["Spain", "Greece", "France", "Italy"],
        correctAnswer: "Italy"
    ),
    OverconfidenceQuestion(
        question: "What is the smallest country in the world by area?",
        options: ["Monaco", "San Marino", "Liechtenstein", "Vatican City"],
        correctAnswer: "Vatican City"
    ),
    OverconfidenceQuestion(
        question: "How long does it take light from the Sun to reach Earth (approx.)?",
        options: ["4 minutes", "8 minutes", "12 minutes", "20 minutes"],
        correctAnswer: "8 minutes"
    ),
    OverconfidenceQuestion(
        question: "What language has the most native speakers in the world?",
        options: ["English", "Spanish", "Hindi", "Mandarin Chinese"],
        correctAnswer: "Mandarin Chinese"
    ),
    OverconfidenceQuestion(
        question: "How many keys does a standard piano have?",
        options: ["76", "80", "88", "92"],
        correctAnswer: "88"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Brazil?",
        options: ["Rio de Janeiro", "São Paulo", "Brasília", "Salvador"],
        correctAnswer: "Brasília"
    ),
    OverconfidenceQuestion(
        question: "In the periodic table, what is the symbol for gold?",
        options: ["Go", "Gd", "Gl", "Au"],
        correctAnswer: "Au"
    ),
    OverconfidenceQuestion(
        question: "How many continents are there on Earth?",
        options: ["5", "6", "7", "8"],
        correctAnswer: "7"
    ),
    OverconfidenceQuestion(
        question: "Which gas is most abundant in Earth's atmosphere?",
        options: ["Oxygen", "Carbon dioxide", "Argon", "Nitrogen"],
        correctAnswer: "Nitrogen"
    ),
    OverconfidenceQuestion(
        question: "Who discovered penicillin?",
        options: ["Louis Pasteur", "Marie Curie", "Alexander Fleming", "Edward Jenner"],
        correctAnswer: "Alexander Fleming"
    ),
    OverconfidenceQuestion(
        question: "What is the largest organ in the human body?",
        options: ["Liver", "Lungs", "Skin", "Brain"],
        correctAnswer: "Skin"
    ),
    OverconfidenceQuestion(
        question: "How many players are on a standard soccer team?",
        options: ["9", "10", "11", "12"],
        correctAnswer: "11"
    ),
    OverconfidenceQuestion(
        question: "What year did the Titanic sink?",
        options: ["1910", "1911", "1912", "1913"],
        correctAnswer: "1912"
    ),
    OverconfidenceQuestion(
        question: "Which planet is known as the Red Planet?",
        options: ["Venus", "Jupiter", "Mars", "Mercury"],
        correctAnswer: "Mars"
    ),
    OverconfidenceQuestion(
        question: "What is the most abundant metal in Earth's crust?",
        options: ["Iron", "Calcium", "Aluminium", "Magnesium"],
        correctAnswer: "Aluminium"
    ),
    OverconfidenceQuestion(
        question: "How many chambers does the human heart have?",
        options: ["2", "3", "4", "5"],
        correctAnswer: "4"
    ),
    OverconfidenceQuestion(
        question: "Which country has the most natural lakes?",
        options: ["Russia", "USA", "Brazil", "Canada"],
        correctAnswer: "Canada"
    ),
    OverconfidenceQuestion(
        question: "What is the rarest blood type?",
        options: ["O−", "AB−", "B−", "A−"],
        correctAnswer: "AB−"
    ),
    OverconfidenceQuestion(
        question: "Which artist painted 'Starry Night'?",
        options: ["Claude Monet", "Vincent van Gogh", "Pablo Picasso", "Salvador Dalí"],
        correctAnswer: "Vincent van Gogh"
    ),
    OverconfidenceQuestion(
        question: "What is the most spoken second language in the world?",
        options: ["French", "Spanish", "English", "Mandarin"],
        correctAnswer: "English"
    ),
    OverconfidenceQuestion(
        question: "Which country gifted the Statue of Liberty to the USA?",
        options: ["England", "France", "Spain", "Italy"],
        correctAnswer: "France"
    ),
    OverconfidenceQuestion(
        question: "What does DNA stand for?",
        options: ["Deoxyribonucleic Acid", "Dual Nucleic Acid", "Deoxyribose Nuclear Acid", "Diribonucleic Acid"],
        correctAnswer: "Deoxyribonucleic Acid"
    ),
    OverconfidenceQuestion(
        question: "Who is widely considered the father of modern physics?",
        options: ["Isaac Newton", "Albert Einstein", "Galileo Galilei", "Niels Bohr"],
        correctAnswer: "Albert Einstein"
    ),
    OverconfidenceQuestion(
        question: "Which Greek god is the king of the gods?",
        options: ["Apollo", "Zeus", "Poseidon", "Hades"],
        correctAnswer: "Zeus"
    ),
    OverconfidenceQuestion(
        question: "What is the chemical symbol for potassium?",
        options: ["P", "Po", "Pt", "K"],
        correctAnswer: "K"
    ),
    OverconfidenceQuestion(
        question: "What is the largest desert in the world?",
        options: ["Sahara", "Gobi", "Antarctic", "Arabian"],
        correctAnswer: "Antarctic"
    ),
    OverconfidenceQuestion(
        question: "Who wrote 'Romeo and Juliet'?",
        options: ["Charles Dickens", "William Shakespeare", "Jane Austen", "Mark Twain"],
        correctAnswer: "William Shakespeare"
    ),
    OverconfidenceQuestion(
        question: "Which country is the Great Wall in?",
        options: ["Japan", "Korea", "China", "Mongolia"],
        correctAnswer: "China"
    ),
    OverconfidenceQuestion(
        question: "How many minutes are in a full day?",
        options: ["1,200", "1,440", "1,600", "2,400"],
        correctAnswer: "1,440"
    ),
    OverconfidenceQuestion(
        question: "What is the freezing point of water in Fahrenheit?",
        options: ["0°F", "32°F", "100°F", "212°F"],
        correctAnswer: "32°F"
    ),
    OverconfidenceQuestion(
        question: "Which planet has the strongest gravity?",
        options: ["Earth", "Saturn", "Jupiter", "Neptune"],
        correctAnswer: "Jupiter"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Egypt?",
        options: ["Alexandria", "Cairo", "Luxor", "Giza"],
        correctAnswer: "Cairo"
    ),
    OverconfidenceQuestion(
        question: "Who painted the Mona Lisa?",
        options: ["Michelangelo", "Raphael", "Leonardo da Vinci", "Donatello"],
        correctAnswer: "Leonardo da Vinci"
    ),
    OverconfidenceQuestion(
        question: "What sport is associated with Wimbledon?",
        options: ["Cricket", "Golf", "Tennis", "Polo"],
        correctAnswer: "Tennis"
    ),
    OverconfidenceQuestion(
        question: "Which language has the most native speakers worldwide?",
        options: ["English", "Hindi", "Spanish", "Mandarin Chinese"],
        correctAnswer: "Mandarin Chinese"
    ),
    OverconfidenceQuestion(
        question: "Which is the only mammal capable of true flight?",
        options: ["Flying squirrel", "Bat", "Sugar glider", "Colugo"],
        correctAnswer: "Bat"
    ),
    OverconfidenceQuestion(
        question: "How many bones are in the human foot?",
        options: ["20", "26", "30", "33"],
        correctAnswer: "26"
    ),
    OverconfidenceQuestion(
        question: "What is the smallest unit of life?",
        options: ["Atom", "Cell", "Molecule", "Tissue"],
        correctAnswer: "Cell"
    ),
    OverconfidenceQuestion(
        question: "Which ocean lies between Africa and Australia?",
        options: ["Atlantic", "Indian", "Pacific", "Southern"],
        correctAnswer: "Indian"
    ),
    OverconfidenceQuestion(
        question: "What does GPS stand for?",
        options: ["Global Positioning System", "General Position Service", "Global Path System", "Geographic Plotting System"],
        correctAnswer: "Global Positioning System"
    ),
    OverconfidenceQuestion(
        question: "Who invented the telephone?",
        options: ["Thomas Edison", "Nikola Tesla", "Alexander Graham Bell", "Guglielmo Marconi"],
        correctAnswer: "Alexander Graham Bell"
    ),
    OverconfidenceQuestion(
        question: "How many sides does a heptagon have?",
        options: ["6", "7", "8", "9"],
        correctAnswer: "7"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of South Africa? (the executive capital)",
        options: ["Cape Town", "Johannesburg", "Pretoria", "Durban"],
        correctAnswer: "Pretoria"
    ),
    OverconfidenceQuestion(
        question: "Which country is the brand IKEA from?",
        options: ["Norway", "Denmark", "Sweden", "Finland"],
        correctAnswer: "Sweden"
    ),
    OverconfidenceQuestion(
        question: "Which is the longest bone in the human body?",
        options: ["Tibia", "Humerus", "Femur", "Fibula"],
        correctAnswer: "Femur"
    ),
    OverconfidenceQuestion(
        question: "Who developed the theory of evolution by natural selection?",
        options: ["Gregor Mendel", "Louis Pasteur", "Charles Darwin", "Carl Linnaeus"],
        correctAnswer: "Charles Darwin"
    ),
    OverconfidenceQuestion(
        question: "In what year did humans first land on the Moon?",
        options: ["1965", "1969", "1971", "1972"],
        correctAnswer: "1969"
    ),
    OverconfidenceQuestion(
        question: "What is the most abundant gas in the Sun?",
        options: ["Oxygen", "Nitrogen", "Helium", "Hydrogen"],
        correctAnswer: "Hydrogen"
    ),
    OverconfidenceQuestion(
        question: "What is the national sport of Japan?",
        options: ["Karate", "Judo", "Sumo wrestling", "Kendo"],
        correctAnswer: "Sumo wrestling"
    ),
    OverconfidenceQuestion(
        question: "Which country invented paper?",
        options: ["Egypt", "China", "India", "Greece"],
        correctAnswer: "China"
    ),
    OverconfidenceQuestion(
        question: "What is the chemical symbol for silver?",
        options: ["Si", "Sv", "Ag", "Au"],
        correctAnswer: "Ag"
    ),
    OverconfidenceQuestion(
        question: "Which sea is the saltiest?",
        options: ["Mediterranean Sea", "Dead Sea", "Red Sea", "Caspian Sea"],
        correctAnswer: "Dead Sea"
    ),
    OverconfidenceQuestion(
        question: "Which was the first country to give women the right to vote?",
        options: ["USA", "United Kingdom", "New Zealand", "Australia"],
        correctAnswer: "New Zealand"
    ),
    OverconfidenceQuestion(
        question: "What is the largest island in the world?",
        options: ["Australia", "New Guinea", "Borneo", "Greenland"],
        correctAnswer: "Greenland"
    ),
    OverconfidenceQuestion(
        question: "Who wrote 'The Odyssey'?",
        options: ["Virgil", "Homer", "Sophocles", "Ovid"],
        correctAnswer: "Homer"
    ),
    OverconfidenceQuestion(
        question: "In which sport would you perform a 'slam dunk'?",
        options: ["Tennis", "Volleyball", "Basketball", "American Football"],
        correctAnswer: "Basketball"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Norway?",
        options: ["Stockholm", "Oslo", "Helsinki", "Copenhagen"],
        correctAnswer: "Oslo"
    ),
    OverconfidenceQuestion(
        question: "Which planet has a day longer than its year?",
        options: ["Mercury", "Venus", "Mars", "Neptune"],
        correctAnswer: "Venus"
    ),
    OverconfidenceQuestion(
        question: "What does HTTP stand for?",
        options: ["HyperText Transfer Protocol", "High Transfer Text Protocol", "Hyperlink Text Transmission Protocol", "Host Transfer Text Protocol"],
        correctAnswer: "HyperText Transfer Protocol"
    ),
    OverconfidenceQuestion(
        question: "Which ancient wonder of the world still stands today?",
        options: ["Hanging Gardens of Babylon", "Colossus of Rhodes", "Great Pyramid of Giza", "Lighthouse of Alexandria"],
        correctAnswer: "Great Pyramid of Giza"
    ),
    OverconfidenceQuestion(
        question: "How many colors are in a standard rainbow?",
        options: ["5", "6", "7", "8"],
        correctAnswer: "7"
    ),
    OverconfidenceQuestion(
        question: "What is the largest planet in our solar system?",
        options: ["Saturn", "Neptune", "Jupiter", "Uranus"],
        correctAnswer: "Jupiter"
    ),
    OverconfidenceQuestion(
        question: "Which Roman emperor was famously assassinated on the Ides of March?",
        options: ["Augustus", "Nero", "Julius Caesar", "Caligula"],
        correctAnswer: "Julius Caesar"
    ),
    OverconfidenceQuestion(
        question: "Which musician is known as 'The King of Pop'?",
        options: ["Elvis Presley", "Prince", "Michael Jackson", "Freddie Mercury"],
        correctAnswer: "Michael Jackson"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Argentina?",
        options: ["Santiago", "Lima", "Buenos Aires", "Montevideo"],
        correctAnswer: "Buenos Aires"
    ),
    OverconfidenceQuestion(
        question: "Which Greek philosopher tutored Alexander the Great?",
        options: ["Plato", "Socrates", "Aristotle", "Pythagoras"],
        correctAnswer: "Aristotle"
    ),
    OverconfidenceQuestion(
        question: "Which gas is responsible for the smell of rotten eggs?",
        options: ["Methane", "Ammonia", "Hydrogen sulfide", "Carbon monoxide"],
        correctAnswer: "Hydrogen sulfide"
    ),
    OverconfidenceQuestion(
        question: "How many time zones are there in the world?",
        options: ["12", "24", "36", "48"],
        correctAnswer: "24"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Turkey?",
        options: ["Istanbul", "Ankara", "Izmir", "Bursa"],
        correctAnswer: "Ankara"
    ),
    OverconfidenceQuestion(
        question: "Which animal has the longest gestation period?",
        options: ["Blue whale", "Giraffe", "African elephant", "Rhinoceros"],
        correctAnswer: "African elephant"
    ),
    OverconfidenceQuestion(
        question: "What does 'www' stand for in a website browser?",
        options: ["World Wide Web", "Web World Wide", "World Web Wide", "Wide World Web"],
        correctAnswer: "World Wide Web"
    ),
    OverconfidenceQuestion(
        question: "Who composed 'The Four Seasons'?",
        options: ["Mozart", "Beethoven", "Vivaldi", "Bach"],
        correctAnswer: "Vivaldi"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of New Zealand?",
        options: ["Auckland", "Wellington", "Christchurch", "Hamilton"],
        correctAnswer: "Wellington"
    ),
    OverconfidenceQuestion(
        question: "In which sport is the Stanley Cup awarded?",
        options: ["Basketball", "Baseball", "Ice hockey", "American football"],
        correctAnswer: "Ice hockey"
    ),
    OverconfidenceQuestion(
        question: "What is the chemical formula for ozone?",
        options: ["O", "O2", "O3", "O4"],
        correctAnswer: "O3"
    ),
    OverconfidenceQuestion(
        question: "Which country is home to the kangaroo?",
        options: ["South Africa", "New Zealand", "Australia", "Argentina"],
        correctAnswer: "Australia"
    ),
    OverconfidenceQuestion(
        question: "Who painted 'The Last Supper'?",
        options: ["Michelangelo", "Raphael", "Leonardo da Vinci", "Botticelli"],
        correctAnswer: "Leonardo da Vinci"
    ),
    OverconfidenceQuestion(
        question: "Which vitamin is produced when human skin is exposed to sunlight?",
        options: ["Vitamin A", "Vitamin B12", "Vitamin C", "Vitamin D"],
        correctAnswer: "Vitamin D"
    ),
    OverconfidenceQuestion(
        question: "What is the capital of Greece?",
        options: ["Thessaloniki", "Athens", "Sparta", "Crete"],
        correctAnswer: "Athens"
    ),
    OverconfidenceQuestion(
        question: "Who is the author of the 'Harry Potter' series?",
        options: ["Suzanne Collins", "Stephenie Meyer", "J.K. Rowling", "Roald Dahl"],
        correctAnswer: "J.K. Rowling"
    ),
    OverconfidenceQuestion(
        question: "Which sea creature has three hearts?",
        options: ["Shark", "Octopus", "Jellyfish", "Squid"],
        correctAnswer: "Octopus"
    ),
    OverconfidenceQuestion(
        question: "What is the most widely practiced religion in the world?",
        options: ["Hinduism", "Islam", "Christianity", "Buddhism"],
        correctAnswer: "Christianity"
    ),
    OverconfidenceQuestion(
        question: "Which country is the origin of sushi?",
        options: ["China", "Korea", "Thailand", "Japan"],
        correctAnswer: "Japan"
    ),
    OverconfidenceQuestion(
        question: "Which mountain range separates Europe from Asia?",
        options: ["Alps", "Pyrenees", "Ural Mountains", "Caucasus Mountains"],
        correctAnswer: "Ural Mountains"
    )
]
