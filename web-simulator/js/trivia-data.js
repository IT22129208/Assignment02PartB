// TriviaNight TV - Category & Question Packs
window.TriviaData = {
  categories: [
    {
      id: "movies",
      title: "Cinema & Hollywood",
      tagline: "Oscars, cult classics, and box office blockbusters",
      icon: "🎬",
      colorStart: "#f43f5e",
      colorEnd: "#be123c",
      questions: [
        {
          prompt: "Which film won the first-ever Academy Award for Best Picture in 1929?",
          options: ["Wings", "Metropolis", "Sunrise", "The Jazz Singer"],
          correctIndex: 0,
          explanation: "'Wings' was a silent World War I drama and the first film to win Best Picture at the inaugural Oscars.",
          basePoints: 1000
        },
        {
          prompt: "What is the highest-grossing film of all time (unadjusted for inflation)?",
          options: ["Titanic", "Avengers: Endgame", "Avatar", "Star Wars: The Force Awakens"],
          correctIndex: 2,
          explanation: "James Cameron's 'Avatar' (2009) reclaimed the #1 all-time box office title with over $2.92 billion.",
          basePoints: 1000
        },
        {
          prompt: "In 'The Matrix' (1999), what color pill does Neo take to see the real world?",
          options: ["Blue Pill", "Red Pill", "Green Pill", "Yellow Pill"],
          correctIndex: 1,
          explanation: "Morpheus offers Neo the choice: take the blue pill to stay in illusion, or the red pill to see how deep the rabbit hole goes.",
          basePoints: 1000
        },
        {
          prompt: "Who directed the 2023 biographical epic 'Oppenheimer'?",
          options: ["Denis Villeneuve", "Christopher Nolan", "Martin Scorsese", "Quentin Tarantino"],
          correctIndex: 1,
          explanation: "Christopher Nolan directed 'Oppenheimer', winning 7 Oscars including Best Picture and Best Director.",
          basePoints: 1000
        }
      ]
    },
    {
      id: "tech",
      title: "Tech & Innovation",
      tagline: "Silicon Valley, Apple history, and futuristic breakthroughs",
      icon: "💻",
      colorStart: "#0ea5e9",
      colorEnd: "#1e40af",
      questions: [
        {
          prompt: "In what year was the first original iPhone unveiled by Steve Jobs?",
          options: ["2005", "2006", "2007", "2008"],
          correctIndex: 2,
          explanation: "Steve Jobs introduced the revolutionary iPhone on January 9, 2007, at Macworld in San Francisco.",
          basePoints: 1000
        },
        {
          prompt: "What programming language was created by Apple in 2014 as an alternative to Objective-C?",
          options: ["Swift", "Kotlin", "Rust", "Dart"],
          correctIndex: 0,
          explanation: "Swift was introduced at WWDC 2014 and has become Apple's premier modern programming language.",
          basePoints: 1000
        },
        {
          prompt: "What does the abbreviation 'GPU' stand for in computer hardware?",
          options: ["General Processing Unit", "Graphics Processing Unit", "Gigabyte Performance Utility", "Global Protocol Unit"],
          correctIndex: 1,
          explanation: "GPU stands for Graphics Processing Unit, essential for rendering 3D graphics and modern AI models.",
          basePoints: 1000
        },
        {
          prompt: "Which company originally developed the Android operating system before Google acquired it in 2005?",
          options: ["Symbian Inc.", "Android Inc.", "Sun Microsystems", "PalmSource"],
          correctIndex: 1,
          explanation: "Android Inc. was founded in Palo Alto in 2003 by Andy Rubin, Rich Miner, Nick Sears, and Chris White.",
          basePoints: 1000
        }
      ]
    },
    {
      id: "math",
      title: "Mathematics & Logic",
      tagline: "Mental math, geometry puzzles, famous equations, and probability riddles",
      icon: "➗",
      colorStart: "#06b6d4",
      colorEnd: "#0e7490",
      questions: [
        {
          prompt: "What is the only number that is both an even integer and a prime number?",
          options: ["2", "4", "0", "1"],
          correctIndex: 0,
          explanation: "2 is the only even prime number because every other even number is divisible by 2.",
          basePoints: 1000
        },
        {
          prompt: "What mathematical constant represents the ratio of a circle's circumference to its diameter?",
          options: ["Pi (π)", "Euler's number (e)", "Golden Ratio (φ)", "Square root of 2"],
          correctIndex: 0,
          explanation: "Pi (approximately 3.14159) is the ratio of any circle's circumference to its diameter.",
          basePoints: 1000
        },
        {
          prompt: "If you roll a standard 6-sided die, what is the probability of rolling a number greater than 4?",
          options: ["1/3 (33.3%)", "1/2 (50%)", "1/6 (16.7%)", "2/3 (66.7%)"],
          correctIndex: 0,
          explanation: "The outcomes greater than 4 are 5 and 6 (2 outcomes out of 6 possible, which simplifies to 2/6 = 1/3).",
          basePoints: 1000
        },
        {
          prompt: "Which ancient Greek theorem establishes that for any right triangle: a² + b² = c²?",
          options: ["Pythagorean Theorem", "Fermat's Last Theorem", "Euclid's Algorithm", "Thales' Theorem"],
          correctIndex: 0,
          explanation: "The Pythagorean theorem relates the lengths of the two legs (a, b) to the hypotenuse (c) of a right-angled triangle.",
          basePoints: 1000
        }
      ]
    },
    {
      id: "music",
      title: "Music & Pop Hits",
      tagline: "Chart toppers, iconic riffs, and vinyl legends",
      icon: "🎵",
      colorStart: "#a855f7",
      colorEnd: "#6b21a8",
      questions: [
        {
          prompt: "Which British band recorded the legendary 1969 album 'Abbey Road'?",
          options: ["The Rolling Stones", "The Who", "The Beatles", "Pink Floyd"],
          correctIndex: 2,
          explanation: "The Beatles recorded 'Abbey Road', famously featuring the zebra crosswalk cover photograph.",
          basePoints: 1000
        },
        {
          prompt: "Who holds the record for the most Grammy Award wins in music history?",
          options: ["Beyoncé", "Michael Jackson", "Quincy Jones", "Stevie Wonder"],
          correctIndex: 0,
          explanation: "Beyoncé made Grammy history in 2023 by surpassing Georg Solti, reaching 32 total Grammy wins.",
          basePoints: 1000
        },
        {
          prompt: "What is the tempo marking that indicates playing music fast and lively?",
          options: ["Adagio", "Andante", "Allegro", "Largo"],
          correctIndex: 2,
          explanation: "'Allegro' is the standard Italian musical term for brisk, rapid, and cheerful tempo (typically 120-156 BPM).",
          basePoints: 1000
        },
        {
          prompt: "Which female artist released the blockbuster 'Eras Tour' and re-recorded '1989'?",
          options: ["Adele", "Taylor Swift", "Billie Eilish", "Dua Lipa"],
          correctIndex: 1,
          explanation: "Taylor Swift's 'The Eras Tour' became the highest-grossing concert tour of all time.",
          basePoints: 1000
        }
      ]
    },
    {
      id: "general",
      title: "Living Room Pub Trivia",
      tagline: "Quirky facts, science curiosities, and bar bets",
      icon: "🍺",
      colorStart: "#eab308",
      colorEnd: "#ca8a04",
      questions: [
        {
          prompt: "What is the only mammal capable of true sustained flight?",
          options: ["Flying Squirrel", "Sugar Glider", "Bat", "Colugo"],
          correctIndex: 2,
          explanation: "Bats are the only mammals capable of powered flapping flight; flying squirrels only glide.",
          basePoints: 1000
        },
        {
          prompt: "What is the chemical symbol for table salt (Sodium Chloride)?",
          options: ["SoCl", "NaCl", "NaC", "SCl2"],
          correctIndex: 1,
          explanation: "NaCl stands for Natrium (Sodium) and Chloride, the ionic compound known as culinary salt.",
          basePoints: 1000
        },
        {
          prompt: "Which European city is home to the famous Louvre Museum?",
          options: ["Madrid", "Rome", "Paris", "Vienna"],
          correctIndex: 2,
          explanation: "The Musée du Louvre, home of the Mona Lisa, is situated on the Right Bank of the Seine in Paris.",
          basePoints: 1000
        },
        {
          prompt: "How many seconds are in exactly one hour?",
          options: ["3,600", "3,200", "2,400", "4,000"],
          correctIndex: 0,
          explanation: "60 seconds in a minute multiplied by 60 minutes in an hour equals 3,600 seconds.",
          basePoints: 1000
        }
      ]
    }
  ],

  initialPlayers: [
    {
      id: "player-remote",
      name: "Host (Siri Remote)",
      avatar: "🎮",
      color: "#38bdf8",
      controller: "Siri Remote",
      score: 0,
      streak: 0,
      highestStreak: 0,
      correctCount: 0,
      totalCount: 0,
      selectedAnswer: null,
      isLockedIn: false,
      answerTime: null,
      lastPoints: 0,
      isReady: true
    },
    {
      id: "player-mobile",
      name: "Alex",
      avatar: "✨",
      color: "#f43f5e",
      controller: "iPhone Companion",
      score: 0,
      streak: 0,
      highestStreak: 0,
      correctCount: 0,
      totalCount: 0,
      selectedAnswer: null,
      isLockedIn: false,
      answerTime: null,
      lastPoints: 0,
      isReady: false
    }
  ]
};
