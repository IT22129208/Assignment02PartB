import Foundation

public enum TriviaCategoryType: String, CaseIterable, Identifiable, Codable {
    case movies = "Cinema & Hollywood"
    case tech = "Tech & Innovation"
    case math = "Mathematics & Logic"
    case music = "Music & Pop Hits"
    case general = "Living Room Pub Trivia"
    case history = "World History & Wonders"
    case gaming = "Gaming & Pop Culture"
    
    public var id: String { rawValue }
    
    public var icon: String {
        switch self {
        case .movies: return "film.fill"
        case .tech: return "laptopcomputer"
        case .math: return "plus.forwardslash.minus"
        case .music: return "music.note"
        case .general: return "mug.fill"
        case .history: return "globe.americas.fill"
        case .gaming: return "gamecontroller.fill"
        }
    }
    
    public var colorStartHex: String {
        switch self {
        case .movies: return "#f43f5e"   // Rose Red
        case .tech: return "#0ea5e9"     // Sky Blue
        case .math: return "#06b6d4"     // Cyan Electric
        case .music: return "#a855f7"    // Purple
        case .general: return "#eab308"  // Golden Amber
        case .history: return "#10b981"  // Emerald Green
        case .gaming: return "#ec4899"   // Hot Pink
        }
    }
    
    public var colorEndHex: String {
        switch self {
        case .movies: return "#be123c"
        case .tech: return "#1e40af"
        case .math: return "#0e7490"
        case .music: return "#6b21a8"
        case .general: return "#ca8a04"
        case .history: return "#047857"
        case .gaming: return "#9d174d"
        }
    }
    
    public var tagline: String {
        switch self {
        case .movies: return "Oscars, cult classics, and box office blockbusters"
        case .tech: return "Silicon Valley, Apple history, and futuristic breakthroughs"
        case .math: return "Mental math, geometry puzzles, famous equations, and probability riddles"
        case .music: return "Chart toppers, iconic riffs, and vinyl legends"
        case .general: return "Quirky facts, science curiosities, and bar bets"
        case .history: return "Ancient empires, revolutions, and world explorers"
        case .gaming: return "Retro 8-bit classics, esports, and modern lore"
        }
    }
}

public struct TriviaCategory: Identifiable, Hashable {
    public var id: String { type.rawValue }
    public let type: TriviaCategoryType
    public let questions: [TriviaQuestion]
    
    public init(type: TriviaCategoryType, questions: [TriviaQuestion]) {
        self.type = type
        self.questions = questions
    }
    
    public static let samplePacks: [TriviaCategory] = [
        TriviaCategory(
            type: .movies,
            questions: [
                TriviaQuestion(
                    category: .movies,
                    prompt: "Which film won the first-ever Academy Award for Best Picture in 1929?",
                    options: ["Wings", "Metropolis", "Sunrise", "The Jazz Singer"],
                    correctIndex: 0,
                    explanation: "'Wings' was a silent World War I drama and the first film to win Best Picture at the inaugural Oscars."
                ),
                TriviaQuestion(
                    category: .movies,
                    prompt: "What is the highest-grossing film of all time (unadjusted for inflation)?",
                    options: ["Titanic", "Avengers: Endgame", "Avatar", "Star Wars: The Force Awakens"],
                    correctIndex: 2,
                    explanation: "James Cameron's 'Avatar' (2009) reclaimed the #1 all-time box office title with over $2.92 billion."
                ),
                TriviaQuestion(
                    category: .movies,
                    prompt: "In 'The Matrix' (1999), what color pill does Neo take to see the real world?",
                    options: ["Blue Pill", "Red Pill", "Green Pill", "Yellow Pill"],
                    correctIndex: 1,
                    explanation: "Morpheus offers Neo the choice: take the blue pill to stay in illusion, or the red pill to see how deep the rabbit hole goes."
                ),
                TriviaQuestion(
                    category: .movies,
                    prompt: "Who directed the 2023 biographical epic 'Oppenheimer'?",
                    options: ["Denis Villeneuve", "Christopher Nolan", "Martin Scorsese", "Quentin Tarantino"],
                    correctIndex: 1,
                    explanation: "Christopher Nolan directed 'Oppenheimer', winning 7 Oscars including Best Picture and Best Director."
                )
            ]
        ),
        TriviaCategory(
            type: .tech,
            questions: [
                TriviaQuestion(
                    category: .tech,
                    prompt: "In what year was the first original iPhone unveiled by Steve Jobs?",
                    options: ["2005", "2006", "2007", "2008"],
                    correctIndex: 2,
                    explanation: "Steve Jobs introduced the revolutionary iPhone on January 9, 2007, at Macworld in San Francisco."
                ),
                TriviaQuestion(
                    category: .tech,
                    prompt: "What programming language was created by Apple in 2014 as an alternative to Objective-C?",
                    options: ["Swift", "Kotlin", "Rust", "Dart"],
                    correctIndex: 0,
                    explanation: "Swift was introduced at WWDC 2014 and has become Apple's premier modern programming language."
                ),
                TriviaQuestion(
                    category: .tech,
                    prompt: "What does the abbreviation 'GPU' stand for in computer hardware?",
                    options: ["General Processing Unit", "Graphics Processing Unit", "Gigabyte Performance Utility", "Global Protocol Unit"],
                    correctIndex: 1,
                    explanation: "GPU stands for Graphics Processing Unit, essential for rendering 3D graphics and accelerating modern AI models."
                ),
                TriviaQuestion(
                    category: .tech,
                    prompt: "Which company originally developed the Android operating system before being acquired by Google in 2005?",
                    options: ["Symbian Inc.", "Android Inc.", "Sun Microsystems", "PalmSource"],
                    correctIndex: 1,
                    explanation: "Android Inc. was founded in Palo Alto in 2003 by Andy Rubin, Rich Miner, Nick Sears, and Chris White."
                )
            ]
        ),
        TriviaCategory(
            type: .math,
            questions: [
                TriviaQuestion(
                    category: .math,
                    prompt: "What is the only number that is both an even integer and a prime number?",
                    options: ["2", "4", "0", "1"],
                    correctIndex: 0,
                    explanation: "2 is the only even prime number because every other even number is divisible by 2."
                ),
                TriviaQuestion(
                    category: .math,
                    prompt: "What mathematical constant represents the ratio of a circle's circumference to its diameter?",
                    options: ["Pi (π)", "Euler's number (e)", "Golden Ratio (φ)", "Square root of 2"],
                    correctIndex: 0,
                    explanation: "Pi (approximately 3.14159) is the ratio of any circle's circumference to its diameter."
                ),
                TriviaQuestion(
                    category: .math,
                    prompt: "If you roll a standard 6-sided die, what is the probability of rolling a number greater than 4?",
                    options: ["1/3 (33.3%)", "1/2 (50%)", "1/6 (16.7%)", "2/3 (66.7%)"],
                    correctIndex: 0,
                    explanation: "The outcomes greater than 4 are 5 and 6 (2 outcomes out of 6 possible, which simplifies to 2/6 = 1/3)."
                ),
                TriviaQuestion(
                    category: .math,
                    prompt: "Which ancient Greek theorem establishes that for any right triangle: a² + b² = c²?",
                    options: ["Pythagorean Theorem", "Fermat's Last Theorem", "Euclid's Algorithm", "Thales' Theorem"],
                    correctIndex: 0,
                    explanation: "The Pythagorean theorem relates the lengths of the two legs (a, b) to the hypotenuse (c) of a right-angled triangle."
                )
            ]
        ),
        TriviaCategory(
            type: .music,
            questions: [
                TriviaQuestion(
                    category: .music,
                    prompt: "Which British band recorded the legendary 1969 album 'Abbey Road'?",
                    options: ["The Rolling Stones", "The Who", "The Beatles", "Pink Floyd"],
                    correctIndex: 2,
                    explanation: "The Beatles recorded 'Abbey Road', famously featuring the crosswalk cover photograph."
                ),
                TriviaQuestion(
                    category: .music,
                    prompt: "Who holds the record for the most Grammy Award wins in music history?",
                    options: ["Beyoncé", "Michael Jackson", "Quincy Jones", "Stevie Wonder"],
                    correctIndex: 0,
                    explanation: "Beyoncé made Grammy history in 2023 by surpassing Georg Solti, reaching 32 total Grammy wins."
                ),
                TriviaQuestion(
                    category: .music,
                    prompt: "What is the tempo marking that indicates playing music fast and lively?",
                    options: ["Adagio", "Andante", "Allegro", "Largo"],
                    correctIndex: 2,
                    explanation: "'Allegro' is the standard Italian musical term for brisk, rapid, and cheerful tempo (typically 120-156 BPM)."
                ),
                TriviaQuestion(
                    category: .music,
                    prompt: "Which female artist released the blockbuster 2023 'Eras Tour' and re-recorded '1989'?",
                    options: ["Adele", "Taylor Swift", "Billie Eilish", "Dua Lipa"],
                    correctIndex: 1,
                    explanation: "Taylor Swift's 'The Eras Tour' became the highest-grossing concert tour of all time."
                )
            ]
        ),
        TriviaCategory(
            type: .general,
            questions: [
                TriviaQuestion(
                    category: .general,
                    prompt: "What is the only mammal that is capable of true sustained flight?",
                    options: ["Flying Squirrel", "Sugar Glider", "Bat", "Colugo"],
                    correctIndex: 2,
                    explanation: "Bats are the only mammals capable of powered flapping flight; flying squirrels only glide."
                ),
                TriviaQuestion(
                    category: .general,
                    prompt: "What is the chemical symbol for table salt (Sodium Chloride)?",
                    options: ["SoCl", "NaCl", "NaC", "SCl2"],
                    correctIndex: 1,
                    explanation: "NaCl stands for Natrium (Sodium) and Chloride, the ionic compound known as culinary salt."
                ),
                TriviaQuestion(
                    category: .general,
                    prompt: "Which European city is home to the famous Louvre Museum?",
                    options: ["Madrid", "Rome", "Paris", "Vienna"],
                    correctIndex: 2,
                    explanation: "The Musée du Louvre, home of the Mona Lisa, is situated on the Right Bank of the Seine in Paris."
                ),
                TriviaQuestion(
                    category: .general,
                    prompt: "How many seconds are in exactly one hour?",
                    options: ["3,600", "3,200", "2,400", "4,000"],
                    correctIndex: 0,
                    explanation: "60 seconds in a minute multiplied by 60 minutes in an hour equals 3,600 seconds."
                )
            ]
        )
    ]
}
