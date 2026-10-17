// Viva Pitch & Presentation Slide Deck Overlay
class VivaPresentation {
  constructor() {
    this.currentSlide = 0;
    this.slides = [
      {
        tag: "PROJECT OVERVIEW & VALUE PROPOSITION",
        title: "TriviaNight TV — The Living Room Pub Quiz",
        subtitle: "A Multiplayer Apple TV Experience Powered by SwiftUI & Siri Remote FocusEngine",
        bullets: [
          "<strong>The Problem:</strong> Mobile trivia forces everyone to stare down at isolated smartphone screens. Traditional board games are clunky with scorepads and paper cards.",
          "<strong>The Solution:</strong> TriviaNight TV turns the living room 4K display into a communal pub quiz arena where family & friends look up, laugh, and buzz in simultaneously.",
          "<strong>Apple Ecosystem Synergies:</strong> Host plays directly with the Apple TV Siri Remote clickpad; guests buzz in with paired iPhones over zero-config Multipeer Connectivity."
        ],
        badge: "tvOS Native • SwiftUI 5 • Multipeer"
      },
      {
        tag: "RUBRIC: 25% CONCEPT INNOVATION",
        title: "Multi-User Architecture & Living Room Mechanics",
        subtitle: "Engineered specifically for communal 10-foot living room interaction",
        bullets: [
          "<strong>Simultaneous Multi-Controller Input:</strong> Up to 8 players buzz in concurrently without turn delays.",
          "<strong>Dynamic Speed Scoring:</strong> Fastest answer earns up to +500 speed bonus points, creating breathless buzzer races.",
          "<strong>Consecutive Streak Multipliers:</strong> Answering multiple questions in a row ignites flame badges and stacks point multipliers up to 2.0x.",
          "<strong>Zero App Store Barrier:</strong> Local Bonjour peer discovery lets visitors connect instantly without room passwords or accounts."
        ],
        badge: "25% Concept Innovation"
      },
      {
        tag: "RUBRIC: 25% PROTOTYPE FUNCTIONALITY",
        title: "Complete End-to-End Game Lifecycle",
        subtitle: "Five cohesive screens built with Apple TV HIG 10-Foot Guidelines",
        bullets: [
          "<strong>1. Room Lobby & Mobile Join:</strong> Real-time mobile name & avatar customization instantly synced to TV screen, room code ('PUB-4K'), live roster, and host start button.",
          "<strong>2. Category Pack Grid:</strong> 7 rich themes (Cinema, Tech, Mathematics & Logic, Music, Pub Trivia, World History, Gaming) with FocusEngine depth.",
          "<strong>3. Question & Timer Board:</strong> 36pt high-contrast typography, animated 15s color-shifting countdown bar, and 4 colored cards.",
          "<strong>4. Dramatic Answer Reveal:</strong> Emerald green reveal, trivia curio explanations, and player speed breakdowns.",
          "<strong>5. Winner Celebration Podium:</strong> 3D-style podium, confetti fanfare, and MVP awards (Speed Demon, Accuracy Ace)."
        ],
        badge: "25% Prototype Functionality"
      },
      {
        tag: "RUBRIC: 15% TECHNICAL PROFICIENCY",
        title: "SwiftUI, Concurrency & tvOS FocusEngine",
        subtitle: "Robust implementation following modern Swift 5.9 best practices",
        bullets: [
          "<strong>@FocusState Navigation:</strong> Custom card styles with 1.06x scale expansion, specular sheen, and directional d-pad snap.",
          "<strong>Swift Concurrency (Task & Task.sleep):</strong> Drift-free 100ms countdown loop driving smooth UI progress bars.",
          "<strong>Sub-expression Optimization:</strong> Decomposed complex view bodies into strongly-typed computed properties to eliminate compiler type-check timeouts.",
          "<strong>Multipeer Connectivity:</strong> Low-latency packet broadcast with Codable payloads (TriviaSyncPayload)."
        ],
        badge: "15% Technical Proficiency"
      },
      {
        tag: "RUBRIC: 20% PITCH & BUSINESS MODEL",
        title: "Commercialization & Market Strategy",
        subtitle: "Tapping into the $4.2B casual home party & digital board game market",
        bullets: [
          "<strong>Target Demographic:</strong> Families with kids, college student flats, pub quiz enthusiasts, holiday gatherings.",
          "<strong>Freemium Core + DLC Packs:</strong> Free download with 6 core packs; $2.99 themed seasonal expansion packs (e.g., '90s Pop Culture', 'World Cup Lore', 'Sci-Fi Universe').",
          "<strong>TriviaNight Pro Subscription:</strong> $1.99/mo for weekly curated current-event quizzes and custom family question builder.",
          "<strong>Competitive Advantage vs. Jackbox:</strong> Native lightweight SwiftUI app, instant Siri Remote focus, zero browser typing required."
        ],
        badge: "20% Pitch Presentation"
      }
    ];
  }

  open() {
    this.currentSlide = 0;
    this.render();
    const modal = document.getElementById('presentation-modal');
    if (modal) modal.style.display = 'flex';
    if (window.SFX) window.SFX.playFocusClick();
  }

  close() {
    const modal = document.getElementById('presentation-modal');
    if (modal) modal.style.display = 'none';
    if (window.SFX) window.SFX.playFocusClick();
  }

  next() {
    if (this.currentSlide < this.slides.length - 1) {
      this.currentSlide++;
      this.render();
      if (window.SFX) window.SFX.playFocusClick();
    }
  }

  prev() {
    if (this.currentSlide > 0) {
      this.currentSlide--;
      this.render();
      if (window.SFX) window.SFX.playFocusClick();
    }
  }

  render() {
    const slide = this.slides[this.currentSlide];
    const tagEl = document.getElementById('pres-tag');
    const titleEl = document.getElementById('pres-title');
    const subEl = document.getElementById('pres-subtitle');
    const bulletsEl = document.getElementById('pres-bullets');
    const badgeEl = document.getElementById('pres-badge');
    const counterEl = document.getElementById('pres-counter');

    if (tagEl) tagEl.textContent = slide.tag;
    if (titleEl) titleEl.textContent = slide.title;
    if (subEl) subEl.textContent = slide.subtitle;
    if (badgeEl) badgeEl.textContent = slide.badge;
    if (counterEl) counterEl.textContent = `Slide ${this.currentSlide + 1} of ${this.slides.length}`;

    if (bulletsEl) {
      bulletsEl.innerHTML = slide.bullets.map(b => `<li>${b}</li>`).join('');
    }
  }
}

window.Presentation = new VivaPresentation();
