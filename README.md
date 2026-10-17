# TriviaNight TV: The Living Room Pub Quiz 🍻

> A native Apple TV 4K multiplayer trivia party game built with **SwiftUI**, **tvOS FocusEngine**, **MultipeerConnectivity**, and paired **iOS Companion Buzzers**.

---

## 🌟 Executive Summary

**TriviaNight TV** brings traditional pub-style trivia directly into the home living room. Instead of crowding around small smartphone screens, friends and family look at the big television display while locking in fast-paced answers using their **Apple TV Siri Remotes** or **paired iPhones** as handheld game buzzers.

Inspired by *The Jackbox Party Pack*, TriviaNight TV is streamlined as a native, lightweight Apple ecosystem experience with zero browser latency and seamless FocusEngine navigation.

---

## 🏆 Project Rubric Mapping

| Rubric Criteria | Weight | TriviaNight TV Implementation |
| :--- | :---: | :--- |
| **Concept Innovation** | **25%** | **Multi-User Living Room Experience**: Concurrent multi-controller input supporting up to 8 players via Siri Remote and paired iPhones. Real-time speed scoring (+500 pts bonus) and consecutive hot streak flame multipliers. |
| **Prototype Functionality** | **25%** | **Complete Game Lifecycle**: 1) Room Lobby (`PUB-4K`), 2) Category Pack Grid (6 rich themes), 3) 15-second animated Countdown & Question Board, 4) Answer Reveal with trivia facts, 5) 3D Podium Celebration with confetti and MVP awards. |
| **Technical Proficiency** | **15%** | **Native SwiftUI for tvOS**: `@FocusState` 1.06x scale expansion and specular sheen, Swift Concurrency (`Task.sleep`) drift-free 100ms countdown engine, MultipeerConnectivity P2P protocol, and sub-expression decomposition for instant type checking. |
| **Pitch Presentation** | **20%** | Comprehensive pitch deck and presentation outline targeting the $4.2B casual home party market with a freemium DLC expansion pack business model. |

---

## 📁 Repository Structure

```text
├── TriviaNight-tvOS/
│   ├── TriviaNight.xcodeproj/         # Xcode Project with tvOS and iOS targets
│   ├── Package.swift                  # Swift Package Manager manifest (tvOS 17+, iOS 17+)
│   └── Sources/
│       ├── TriviaNightTV/             # Apple TV 4K Application
│       │   ├── App/                   # App entry point (TriviaNightTVApp.swift)
│       │   ├── Models/                # TriviaQuestion, TriviaCategory, Player, GameState, TriviaSyncPayload
│       │   ├── ViewModels/            # TVTriviaGameViewModel (@MainActor conductor)
│       │   ├── Views/                 # LobbyView, CategorySelectView, QuestionTimerBoardView, AnswerRevealView, RoundScoreboardView, WinnerCelebrationView
│       │   ├── Services/              # TriviaAudioEngine (AudioToolbox), TriviaSyncManager (Multipeer)
│       │   └── Info.plist             # Bonjour & local networking configuration
│       │
│       └── TriviaNightCompanion/      # iPhone / iPad Companion Buzzer App
│           ├── App/                   # App entry point (CompanionApp.swift)
│           ├── ViewModels/            # CompanionBuzzerViewModel
│           ├── Views/                 # CompanionBuzzerView (4 tactile touch buzzers)
│           └── Info.plist             # Companion Bonjour configuration
│
├── web-simulator/                     # Full Interactive 10-Foot Web Simulator
│   ├── index.html                     # 10-Foot TV interface + Virtual Siri Remote + iPhone Buzzer
│   ├── server.js                      # Local preview server
│   ├── js/                            # app.js, focus-engine.js, sfx.js, trivia-data.js, sync-bus.js, presentation.js
│   └── styles/                        # tvos-core.css, remote.css, companion.css, presentation.css
│
├── ARCHITECTURE.md                    # In-depth technical architecture specification
├── PITCH_DECK.md                      # Complete Viva Pitch Deck & presentation outline
└── README.md                          # Project documentation
```

---

## 🎮 Game Flow & Core Features

### 1. Living Room Lobby (`LobbyView`) & Mobile Join
- Displays large 64pt room code (`PUB-4K`).
- **Pre-Game Mobile Setup**: Companion players enter their nickname, choose an avatar (✨, ⚡, 🔥, 🎮, 🎯, 🚀), and select a buzzer color on iPhone before joining.
- **Instant TV Display Sync**: Player names and avatars immediately appear on the Apple TV living room lobby roster with animated arrival toasts.
- Siri Remote focusable start button.

### 2. Category Select Grid (`CategorySelectView`)
- 7 curated trivia packs:
  - 🎬 **Cinema & Hollywood**: Oscars, cult classics, and box office hits.
  - 💻 **Tech & Innovation**: Silicon Valley, Apple history, and hardware lore.
  - ➗ **Mathematics & Logic**: Mental math, geometry, prime numbers, probability, and theorem puzzles.
  - 🎵 **Music & Pop Hits**: Vinyl legends, chart toppers, and Grammy record-holders.
  - 🍺 **Living Room Pub Trivia**: Science curiosities and classic bar bets.
  - 🌍 **World History & Wonders**: Ancient empires, revolutions, and world capitals.
  - 🎮 **Gaming & Pop Culture**: 8-bit retro favorites and modern gaming icons.

### 3. Question & Live Countdown Board (`QuestionTimerBoardView`)
- 36pt rounded typography readable from 15 feet away.
- 15-second animated countdown progress bar shifting from emerald green to amber to urgent pulsing red.
- 4 high-contrast answer cards (A: Rose, B: Sky, C: Amber, D: Violet).
- Player lock-in avatars pop up directly onto chosen cards as buzzers are pressed.

### 4. Answer Reveal (`AnswerRevealView`)
- Dramatic emerald green correct answer card with checkmark.
- "Trivia Curio" educational explanations.
- Score itemization showing reflex speed bonus (up to +500 pts) and active streak multipliers.

### 5. Winner Celebration Podium (`WinnerCelebrationView`)
- 3D-style podium ceremony with Gold (#1), Silver (#2), and Bronze (#3) pedestals.
- Golden crown fanfare and confetti animation.
- Pub quiz MVP awards:
  - 🔥 **Longest Hot Streak** (Most consecutive correct answers)
  - 🎯 **Accuracy Ace** (Highest percentage accuracy)

---

## 🛠️ How to Run & Build

### Option 1: Native Xcode Build (Apple TV 4K & Simulator)
1. Open `TriviaNight-tvOS/TriviaNight.xcodeproj` in Xcode 15+.
2. Select the **`TriviaNightTV`** target.
3. Choose the **Apple TV 4K (3rd generation)** simulator.
4. Press **Cmd + R** to run.
5. In Xcode's top menu bar, select `Hardware > Siri Remote` (or `Cmd + Shift + R`) to control the FocusEngine using the simulated Siri Remote trackpad.

### Option 2: Live Interactive Web Simulator
To test and demonstrate the complete 10-foot Apple TV experience with the virtual Siri Remote and companion iPhone buzzer:
```bash
# Start the local server
python3 -m http.server 3000 --directory web-simulator
```
Open **`http://localhost:3000`** in any web browser:
- **Keyboard Navigation**: Use **Arrow Keys (Up, Down, Left, Right)** to navigate the FocusEngine grid, and press **Enter / Space** to select/buzz in.
- **Virtual Siri Remote**: Click the on-screen clickpad or directional arrows on the floating remote.
- **iPhone Companion Buzzer**: Click the large A, B, C, D buttons on the companion phone mockup to simulate real-time multi-user buzzer lock-ins!
- **Viva Pitch Deck**: Click **🎓 Viva Pitch & Rubric Slides** in the top header to view the full presentation deck.
