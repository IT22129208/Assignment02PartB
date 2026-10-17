# KitchenCrew: Interactive Multi-Chef Cook-Alongs (tvOS)

[![tvOS 17+](https://img.shields.io/badge/tvOS-17%2B-black?style=flat&logo=apple)](https://developer.apple.com/tvos/)
[![Swift 5.9](https://img.shields.io/badge/Swift-5.9-orange?style=flat&logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-AppleTV-blue?style=flat&logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![Multipeer Connectivity](https://img.shields.io/badge/Mesh-Multipeer%20Connectivity-green?style=flat)](https://developer.apple.com/documentation/multipeerconnectivity)

> **KitchenCrew** is a synchronized, multi-user cooking masterclass application designed specifically for the living room Apple TV. It transforms the television into the "Head Chef" hub of the home, synchronizing multiple cooks across personal Apple devices (iPhones/iPads) with hands-free voice automation, bird's-eye and macro pan angles, and 10-foot kitchen timers.

---

## 🌟 Key Highlights & Innovative Features

1. **10-Foot Living Room TV Conductor**:
   - Eliminates greasy, fragile phones propped against olive oil bottles on messy counters.
   - High-contrast, 44pt+ monospace countdown clocks and bold progress bars readable from 15+ feet away across an open-plan kitchen.
2. **Multi-User & Multi-Device Synchronization**:
   - Family members join the session from their iPhones/iPads.
   - Station delegation: User A acts as the **Prep & Mise-en-place Station** (on iPad), while User B acts as the **Sauté & Stovetop Station** (on iPhone).
   - Checking off a task on a mobile device immediately rings an audio chime on the Apple TV and triggers a celebratory toast notification.
3. **Split-Screen Multi-Angle 4K Playback**:
   - Seamlessly toggle between **Wide Chef Angle** (knife skills and posture) and **Macro Pan Sizzle Angle** (bubble density and Maillard crust).
   - Synchronized side-by-side **Dual-Cam Split Screen** powered by frame-accurate HLS timestamp offsets.
4. **Hands-Free Kitchen Voice Navigation (SiriKit / Speech)**:
   - Optimized for loud kitchen environments (sizzling butter, exhaust hoods, running water).
   - Voice intents: *"Hey Siri, next step"*, *"Set pasta timer for 9 minutes"*, *"Switch to pan angle"*, *"Show substitutions"*.
5. **tvOS Focus Engine & Siri Remote Ergonomics**:
   - 3D parallax card tilt, floating specular sheen, and tactile audio feedback on remote movement.
   - Clickpad quick actions for ingredient substitutions (dairy-free, allergen swaps, metric/imperial unit conversions).
6. **Embedded Viva & Pitch Presentation Deck**:
   - Built-in 8-slide presentation mode for academic Viva defense and venture pitches.

---

## 📂 Repository Directory Structure

```text
pB/
├── KitchenCrew-tvOS/                     # Native Apple tvOS & iOS Swift Package
│   ├── Package.swift                     # Swift 5.9 Package Specification (tvOS 17+, iOS 17+)
│   └── Sources/
│       ├── KitchenCrewTV/                # tvOS Main Recipe Conductor App
│       │   ├── App/KitchenCrewTVApp.swift
│       │   ├── Models/
│       │   │   ├── Recipe.swift          # Recipe, ingredients, steps, and camera angles
│       │   │   ├── KitchenSession.swift  # Master session state & Multipeer payload schema
│       │   │   ├── ChefStation.swift     # Station roles, user presence, and timers
│       │   │   └── VoiceIntent.swift     # Speech recognition intent classifier
│       │   ├── ViewModels/
│       │   │   └── TVConductorViewModel.swift # Observable master conductor
│       │   ├── Views/
│       │   │   ├── TVRootConductorView.swift  # 10-foot tvOS master layout
│       │   │   ├── MultiAngleVideoPlayerView.swift # Wide/Macro/Split camera switcher
│       │   │   ├── BigScreenTimerView.swift   # Oversized countdown dials
│       │   │   ├── CrewStationStatusStripView.swift # Substation status HUD
│       │   │   ├── QuickActionModalView.swift # Siri Remote substitutions menu
│       │   │   └── VoiceWaveformOverlayView.swift # Siri audio waveform
│       │   └── Services/
│       │       ├── MultipeerSyncManager.swift # P2P Wi-Fi/Bluetooth local mesh
│       │       ├── KitchenVoiceService.swift  # Speech framework + AVAudioEngine
│       │       └── AudioFeedbackEngine.swift  # System sound effects & chimes
│       └── KitchenCrewCompanion/         # iOS Mobile Companion Sub-Station App
│           ├── App/CompanionApp.swift
│           ├── ViewModels/CompanionStationViewModel.swift
│           └── Views/StationChecklistView.swift
│
├── web-simulator/                       # High-Fidelity Interactive tvOS Web Prototype
│   ├── index.html                       # 10-Foot UI, Siri Remote & Mobile Dock Simulator
│   ├── server.js                        # Zero-dependency local Node server
│   ├── styles/
│   │   ├── tvos-core.css                # 10-foot typography, glassmorphism & focus rings
│   │   ├── remote.css                   # Virtual Apple Siri Remote 2nd Gen
│   │   ├── companion.css                # Household iPhone/iPad sub-station drawer
│   │   └── presentation.css             # Keynote Viva pitch deck overlay
│   ├── js/
│   │   ├── app.js                       # Master simulator controller
│   │   ├── recipe-data.js               # Michelin 3-Star Scallop recipe & station data
│   │   ├── focus-engine.js              # 2D spatial navigation & 3D parallax tilt
│   │   ├── multi-angle.js               # Dual-stream synchronizer & angle switcher
│   │   ├── voice-conductor.js           # Web Speech API & voice command simulator
│   │   ├── sync-bus.js                  # Simulated Multipeer Connectivity event bus
│   │   ├── presentation.js              # Viva slides controller
│   │   └── sfx.js                       # Synthesized Web Audio API sound effects
│   └── assets/                          # Generated 4K culinary photography
│       ├── chef_wide.jpg                # Master chef wide angle
│       ├── pan_macro.jpg                # Sizzling scallops in brown butter macro
│       └── plated_dish.jpg              # Michelin-star plated masterpiece
│
├── PITCH_DECK.md                         # Complete Viva / Pitch Slides and Q&A Defense
├── ARCHITECTURE.md                       # Comprehensive Technical Architecture & Protocols
└── README.md                             # Project Documentation (This File)
```

---

## 🚀 How to Run the Project

### Option A: Interactive 10-Foot tvOS Web Simulator (Run Immediately)

The repository contains an interactive prototype simulating the Apple TV 4K living room experience with the Siri Remote, live speech recognition, multi-angle camera feeds, and multi-device companion stations.

1. **Start the local server**:
   ```powershell
   cd web-simulator
   node server.js
   ```
2. **Open in your browser**:
   Navigate to [http://localhost:3000](http://localhost:3000).

3. **Interacting with the tvOS Experience**:
   * **Focus Navigation**: Use the **Arrow Keys** (Up/Down/Left/Right) on your keyboard or click the buttons on the virtual **Siri Remote** widget. Notice the genuine 3D parallax tilt and tactile sound effects!
   * **Step Progression**: Press **Enter** on `"Step Complete (Next) ➔"`.
   * **Multi-Angle Camera Feeds**: Click `"Pan & Sizzle (Macro)"` or `"Split-Screen Dual"` to see synchronized video streams.
   * **Voice Conductor**: Click the microphone icon or click one of the quick voice test chips (e.g., `""Next step""`, `""Set timer for 90 seconds""`, `""Split screen""`).
   * **Multi-Device Sync**: Click `"📱 Household Companion Stations (iPhone/iPad)"` on the bottom-left to open the mobile drawer. Check off an ingredient on Chef Alex's iPad or Chef Sarah's iPhone to watch the Apple TV trigger live toast announcements and update station progress!
   * **Viva Presentation Mode**: Click `"🎓 Viva Pitch & Slides"` in the top header to enter the full-screen keynote presentation.

---

### Option B: Native tvOS & iOS Swift Package (Xcode on macOS)

To open and run the native SwiftUI implementation:

1. Open Xcode on macOS Sonoma or later.
2. Select **File > Open** and choose the `KitchenCrew-tvOS/` directory.
3. Select the `KitchenCrewTV` target and choose an **Apple TV 4K (3rd generation)** simulator.
4. Press **Cmd + R** to build and run.
5. In a second simulator window, select the `KitchenCrewCompanion` target and choose an **iPhone 15 Pro** or **iPad Pro 12.9"** simulator to test the local Multipeer Connectivity synchronization.

---

## 🎤 Hands-Free Voice Commands Reference

KitchenCrew supports natural speech intents tuned for noisy kitchen environments:

| Voice Command | Action Triggered |
| :--- | :--- |
| `"Next step"` / `"Step complete"` | Advances recipe step and updates station checklists |
| `"Previous step"` / `"Go back"` | Returns to previous instruction |
| `"Switch to pan angle"` / `"Macro view"` | Switches stream to the close-up pan sizzle angle |
| `"Wide angle"` / `"Chef angle"` | Switches stream to the wide chef island view |
| `"Split screen"` / `"Dual cam"` | Displays both wide and macro angles simultaneously |
| `"Set timer for [X] minutes/seconds"` | Instantly creates and starts an oversized 10-foot kitchen timer |
| `"Show substitutions"` | Opens the Siri Remote quick culinary tweaks modal |
| `"Viva pitch"` / `"Show slides"` | Opens the interactive academic presentation deck |

---

## 🎓 Viva Presentation & Defense Materials

The project includes ready-to-present pitch and defense documents:
* **[PITCH_DECK.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/pB/PITCH_DECK.md)**: 10 structured slides with talking points, competitor matrix, revenue model, and examiner Q&A defenses.
* **[ARCHITECTURE.md](file:///c:/Users/EBC-IT-SASHIK/Desktop/pB/ARCHITECTURE.md)**: Complete system diagrams, Multipeer protocol packet schema, acoustic noise suppression pipeline, and tvOS 10-foot guidelines compliance.
