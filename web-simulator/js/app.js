// TriviaNight TV - Master Simulator Controller
class TriviaNightApp {
  constructor() {
    this.state = 'lobby'; // lobby | categorySelect | countdown | questionActive | answerReveal | scoreboard | winnerPodium
    this.categories = window.TriviaData.categories;
    this.selectedCategory = this.categories[0];
    this.currentQuestionIndex = 0;
    this.players = JSON.parse(JSON.stringify(window.TriviaData.initialPlayers));
    
    this.timeRemaining = 15.0;
    this.totalTime = 15.0;
    this.timerInterval = null;
    this.countdownSeconds = 3;
    
    this.init();
  }

  init() {
    this.initViewMode();
    this.bindEvents();
    this.bindSyncBus();
    this.fetchSyncInfo();
    this.renderCurrentState();
  }

  initViewMode() {
    const urlParams = new URLSearchParams(window.location.search);
    const mode = urlParams.get('mode');
    if (mode === 'tv' || mode === 'mobile' || mode === 'split') {
      this.setViewMode(mode);
    }
  }

  fetchSyncInfo() {
    fetch('/api/sync/info')
      .then(res => res.json())
      .then(info => {
        const badge = document.getElementById('local-ip-badge');
        if (badge && info.mobileUrl) {
          badge.textContent = info.mobileUrl;
        }
      })
      .catch(() => {});
  }

  setViewMode(mode) {
    document.body.className = `mode-${mode}`;
    document.querySelectorAll('.sim-tab').forEach(t => t.classList.remove('active'));
    const btn = document.getElementById(`mode-${mode}-btn`);
    if (btn) btn.classList.add('active');
  }

  bindEvents() {
    // Virtual Siri Remote button listeners
    document.getElementById('remote-up')?.addEventListener('click', () => window.FocusEngine.moveFocus('up'));
    document.getElementById('remote-down')?.addEventListener('click', () => window.FocusEngine.moveFocus('down'));
    document.getElementById('remote-left')?.addEventListener('click', () => window.FocusEngine.moveFocus('left'));
    document.getElementById('remote-right')?.addEventListener('click', () => window.FocusEngine.moveFocus('right'));
    document.getElementById('remote-center')?.addEventListener('click', () => window.FocusEngine.triggerSelect());
    document.getElementById('remote-menu')?.addEventListener('click', () => this.handleBack());
    document.getElementById('remote-playpause')?.addEventListener('click', () => this.simulateQuickBuzzer());

    // iPhone Companion Buzzer Buttons (A, B, C, D)
    document.querySelectorAll('.companion-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const choiceIdx = parseInt(e.currentTarget.getAttribute('data-index'));
        this.lockInPlayerAnswer('player-mobile', choiceIdx);
        window.SyncBus.sendCompanionBuzzer('player-mobile', choiceIdx);
      });
    });
  }

  // Live typing handler: instantly updates the TV screen as the player types!
  handleCompanionNameInput(value) {
    const name = value.trim() || 'Alex';
    const companionPlayer = this.players.find(p => p.id === 'player-mobile') || this.players[1];
    if (companionPlayer) {
      companionPlayer.name = name;
    }

    // Direct TV DOM update with pulse effect
    const tvPill = document.getElementById('tv-player-pill-mobile');
    const tvName = document.getElementById('tv-player-name-mobile');
    if (tvName) {
      tvName.textContent = name;
    }
    if (tvPill) {
      tvPill.classList.add('highlight-active');
      clearTimeout(this.typeTimer);
      this.typeTimer = setTimeout(() => {
        tvPill.classList.remove('highlight-active');
      }, 800);
    } else if (this.state === 'lobby') {
      this.renderCurrentState();
    }

    const avatar = companionPlayer ? companionPlayer.avatar : '✨';
    const color = companionPlayer ? companionPlayer.color : '#f43f5e';
    window.SyncBus.updatePlayerProfile(name, avatar, color, false);
  }

  handleCompanionAvatarSelect(avatar, btn) {
    document.querySelectorAll('.c-avatar-opt').forEach(b => b.classList.remove('is-selected'));
    if (btn) btn.classList.add('is-selected');

    const companionPlayer = this.players.find(p => p.id === 'player-mobile') || this.players[1];
    if (companionPlayer) {
      companionPlayer.avatar = avatar;
    }

    const tvAvatar = document.getElementById('tv-avatar-mobile');
    if (tvAvatar) tvAvatar.textContent = avatar;

    const compAvatar = document.getElementById('companion-player-avatar');
    if (compAvatar) compAvatar.textContent = avatar;

    const name = companionPlayer ? companionPlayer.name : 'Alex';
    const color = companionPlayer ? companionPlayer.color : '#f43f5e';
    window.SyncBus.updatePlayerProfile(name, avatar, color, companionPlayer ? companionPlayer.isReady : false);
    window.SFX.playFocusClick();
  }

  handleCompanionJoin() {
    const input = document.getElementById('companion-name-input');
    const selectedAvatarBtn = document.querySelector('.c-avatar-opt.is-selected');
    const avatar = selectedAvatarBtn ? selectedAvatarBtn.getAttribute('data-avatar') : '✨';
    const name = (input && input.value.trim()) ? input.value.trim() : 'Alex';

    // Update companion player state
    const companionPlayer = this.players.find(p => p.id === 'player-mobile') || this.players[1];
    if (companionPlayer) {
      companionPlayer.name = name;
      companionPlayer.avatar = avatar;
      companionPlayer.isReady = true;
    }

    // Update iPhone companion display
    const nameEl = document.getElementById('companion-player-name');
    const avatarEl = document.getElementById('companion-player-avatar');
    if (nameEl) nameEl.textContent = name;
    if (avatarEl) avatarEl.textContent = avatar;

    // Switch views on iPhone
    const joinView = document.getElementById('companion-join-view');
    const buzzerView = document.getElementById('companion-buzzer-view');
    if (joinView) joinView.style.display = 'none';
    if (buzzerView) buzzerView.style.display = 'block';

    window.SFX.playBuzzerLock();
    this.showToast(`👋 ${name} joined on iPhone!`, '#f43f5e');

    // Broadcast across all connected devices and tabs
    window.SyncBus.updatePlayerProfile(name, avatar, companionPlayer?.color || '#f43f5e', true);

    // Re-render lobby on TV if currently in lobby
    if (this.state === 'lobby') {
      this.renderCurrentState();
    }
  }

  handleCompanionEditProfile() {
    const joinView = document.getElementById('companion-join-view');
    const buzzerView = document.getElementById('companion-buzzer-view');
    if (joinView) joinView.style.display = 'flex';
    if (buzzerView) buzzerView.style.display = 'none';
    
    const input = document.getElementById('companion-name-input');
    if (input) {
      const companionPlayer = this.players.find(p => p.id === 'player-mobile') || this.players[1];
      if (companionPlayer && companionPlayer.name !== 'Alex') {
        input.value = companionPlayer.name;
      }
      input.focus();
    }
    window.SFX.playFocusClick();
  }

  bindSyncBus() {
    // Remote player join or live name updates (from real phone or another tab)
    window.SyncBus.on('playerUpdate', (payload, fromRemote) => {
      let p = this.players.find(pl => pl.id === payload.id);
      if (!p) {
        p = {
          id: payload.id,
          name: payload.name,
          avatar: payload.avatar,
          color: payload.color || '#f43f5e',
          controller: payload.controller || 'iPhone',
          score: 0,
          streak: 0,
          highestStreak: 0,
          correctCount: 0,
          totalCount: 0,
          selectedAnswer: null,
          isLockedIn: false,
          answerTime: null,
          lastPoints: 0,
          isReady: payload.isReady
        };
        this.players.push(p);
      } else {
        if (payload.name) p.name = payload.name;
        if (payload.avatar) p.avatar = payload.avatar;
        if (payload.color) p.color = payload.color;
        p.isReady = payload.isReady;
      }

      if (fromRemote) {
        // Also update local mobile companion input if in mobile mode
        const nameEl = document.getElementById('companion-player-name');
        if (nameEl) nameEl.textContent = p.name;
        if (payload.isReady) {
          this.showToast(`👋 ${p.name} synced on iPhone!`, p.color);
          window.SFX.playBuzzerLock();
        }
      }

      if (this.state === 'lobby') {
        this.renderCurrentState();
      }
    });

    // Remote player answers (from real phone)
    window.SyncBus.on('playerAnswer', (payload) => {
      this.lockInPlayerAnswer(payload.playerId, payload.answerIndex, payload.answerTime);
    });

    // Remote game state transitions
    window.SyncBus.on('gameState', (payload) => {
      if (payload.state && payload.state !== this.state) {
        this.setScreenState(payload.state);
      }
    });
  }

  getCurrentQuestion() {
    const qs = this.selectedCategory.questions;
    return qs[this.currentQuestionIndex] || qs[0];
  }

  // MARK: - State Transitions

  setScreenState(newState) {
    this.state = newState;
    window.SyncBus.emit('gameState', { state: newState });
    this.renderCurrentState();
    
    // Auto focus the primary action element
    setTimeout(() => {
      const focusables = window.FocusEngine.getFocusableElements();
      if (focusables.length) {
        window.FocusEngine.setFocus(focusables[0], false);
      }
    }, 50);
  }

  showToast(message, color = '#38bdf8') {
    const banner = document.getElementById('tv-toast-banner');
    if (!banner) return;
    const dot = banner.querySelector('.toast-dot');
    const text = banner.querySelector('.toast-text');
    if (dot) dot.style.background = color;
    if (text) text.textContent = message;
    
    banner.classList.add('visible');
    clearTimeout(this.toastTimer);
    this.toastTimer = setTimeout(() => {
      banner.classList.remove('visible');
    }, 2800);
  }

  handleBack() {
    if (this.state === 'categorySelect' || this.state === 'winnerPodium') {
      this.setScreenState('lobby');
    } else if (this.state === 'questionActive' || this.state === 'countdown') {
      this.stopTimer();
      this.setScreenState('categorySelect');
    } else if (this.state === 'answerReveal' || this.state === 'scoreboard') {
      this.setScreenState('lobby');
    }
  }

  // MARK: - Game Lifecycle

  goToCategorySelect() {
    window.SFX.playFocusClick();
    this.setScreenState('categorySelect');
  }

  selectCategory(categoryId) {
    const cat = this.categories.find(c => c.id === categoryId);
    if (cat) {
      this.selectedCategory = cat;
      this.currentQuestionIndex = 0;
      this.resetPlayersForGame();
      window.SFX.playBuzzerLock();
      this.startCountdown();
    }
  }

  resetPlayersForGame() {
    this.players.forEach(p => {
      p.score = 0;
      p.streak = 0;
      p.highestStreak = 0;
      p.correctCount = 0;
      p.totalCount = 0;
      p.selectedAnswer = null;
      p.isLockedIn = false;
      p.lastPoints = 0;
    });
  }

  resetPlayersForRound() {
    this.players.forEach(p => {
      p.selectedAnswer = null;
      p.isLockedIn = false;
      p.answerTime = null;
      p.lastPoints = 0;
    });
    this.updateCompanionUI();
  }

  startCountdown() {
    this.countdownSeconds = 3;
    this.setScreenState('countdown');
    window.SFX.playTimerTick();

    const interval = setInterval(() => {
      this.countdownSeconds--;
      const numEl = document.getElementById('countdown-number');
      if (numEl) numEl.textContent = this.countdownSeconds;
      
      if (this.countdownSeconds > 0) {
        window.SFX.playTimerTick();
      } else {
        clearInterval(interval);
        this.beginQuestion();
      }
    }, 1000);
  }

  beginQuestion() {
    this.resetPlayersForRound();
    const q = this.getCurrentQuestion();
    this.timeRemaining = 15.0;
    this.totalTime = 15.0;
    this.setScreenState('questionActive');
    this.startQuestionTimer();
  }

  startQuestionTimer() {
    this.stopTimer();
    this.timerInterval = setInterval(() => {
      this.timeRemaining = Math.max(0, this.timeRemaining - 0.1);
      this.updateTimerUI();

      // Audio tick on whole seconds when under 5s
      if (this.timeRemaining <= 5.0 && this.timeRemaining > 0) {
        const rounded = Math.round(this.timeRemaining * 10) / 10;
        if (rounded % 1 === 0) {
          window.SFX.playTimerTick();
        }
      }

      if (this.timeRemaining <= 0) {
        this.stopTimer();
        this.evaluateRound();
      }
    }, 100);
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }
  }

  updateTimerUI() {
    const fillEl = document.getElementById('question-timer-fill');
    const textEl = document.getElementById('question-timer-text');
    if (!fillEl || !textEl) return;

    const progress = Math.max(0, Math.min(1, this.timeRemaining / this.totalTime));
    fillEl.style.width = `${progress * 100}%`;
    textEl.textContent = `${this.timeRemaining.toFixed(1)}s`;

    if (this.timeRemaining <= 5.0) {
      fillEl.style.background = '#ef4444';
      textEl.style.color = '#ef4444';
    } else if (this.timeRemaining <= 8.0) {
      fillEl.style.background = '#f97316';
      textEl.style.color = '#f97316';
    } else {
      fillEl.style.background = '#10b981';
      textEl.style.color = '#ffffff';
    }
  }

  // MARK: - Buzzing In & Locking In

  lockInPlayerAnswer(playerId, answerIndex) {
    if (this.state !== 'questionActive') return;
    const player = this.players.find(p => p.id === playerId);
    if (!player || player.isLockedIn) return;

    const elapsed = parseFloat((this.totalTime - this.timeRemaining).toFixed(1));
    player.selectedAnswer = answerIndex;
    player.isLockedIn = true;
    player.answerTime = elapsed;

    window.SFX.playBuzzerLock();
    this.showToast(`${player.name} locked in! (${elapsed}s)`, player.color);
    
    this.updateLockedAvatarsUI();
    this.updateCompanionUI();

    // If all players locked in, advance immediately
    if (this.players.every(p => p.isLockedIn)) {
      this.stopTimer();
      setTimeout(() => this.evaluateRound(), 400);
    }
  }

  simulateQuickBuzzer() {
    if (this.state !== 'questionActive') return;
    // Simulate remaining AI players buzzing in with random realistic delays
    const unlocked = this.players.filter(p => !p.isLockedIn && p.id !== 'player-remote');
    if (unlocked.length) {
      const p = unlocked[0];
      const choices = [0, 1, 2, 3];
      this.lockInPlayerAnswer(p.id, choices[Math.floor(Math.random() * choices.length)]);
    }
  }

  updateLockedAvatarsUI() {
    // Show mini avatars on answer cards
    document.querySelectorAll('.answer-card').forEach((card, idx) => {
      const container = card.querySelector('.locked-avatars-cluster');
      if (container) {
        const lockedHere = this.players.filter(p => p.isLockedIn && p.selectedAnswer === idx);
        container.innerHTML = lockedHere.map(p => `
          <div class="locked-avatar-disc" style="background: ${p.color}" title="${p.name} locked in">
            ${p.avatar}
          </div>
        `).join('');
      }
    });

    // Update bottom locked count
    const countEl = document.getElementById('locked-count-label');
    if (countEl) {
      const count = this.players.filter(p => p.isLockedIn).count || this.players.filter(p => p.isLockedIn).length;
      countEl.textContent = `${count} OF ${this.players.length} PLAYERS LOCKED IN`;
    }
  }

  updateCompanionUI() {
    const mobilePlayer = this.players.find(p => p.id === 'player-mobile') || this.players[1];
    const statusText = document.getElementById('companion-status-text');
    const cards = document.querySelectorAll('.companion-btn');

    if (mobilePlayer && mobilePlayer.isLockedIn) {
      if (statusText) {
        statusText.textContent = "Answer Locked In!";
        statusText.style.color = "#10b981";
      }
      cards.forEach((c, idx) => {
        if (idx === mobilePlayer.selectedAnswer) {
          c.classList.add('is-locked');
        } else {
          c.classList.remove('is-locked');
          c.style.opacity = '0.35';
        }
      });
    } else {
      if (statusText) {
        statusText.textContent = "Look at TV and buzz in!";
        statusText.style.color = "rgba(255,255,255,0.7)";
      }
      cards.forEach(c => {
        c.classList.remove('is-locked');
        c.style.opacity = '1';
      });
    }
  }

  // MARK: - Round Evaluation & Scoring

  evaluateRound() {
    const q = this.getCurrentQuestion();
    const correctIdx = q.correctIndex;
    let anyCorrect = false;

    this.players.forEach(p => {
      p.totalCount++;
      if (p.selectedAnswer === correctIdx) {
        anyCorrect = true;
        p.correctCount++;
        p.streak++;
        if (p.streak > p.highestStreak) p.highestStreak = p.streak;

        const time = p.answerTime || this.totalTime;
        const speedBonus = Math.round(Math.max(0, (this.totalTime - time) / this.totalTime) * 500);
        const streakMultiplier = 1.0 + Math.min(1.0, (p.streak - 1) * 0.25);
        const earned = Math.round((q.basePoints + speedBonus) * streakMultiplier);

        p.lastPoints = earned;
        p.score += earned;
      } else {
        p.streak = 0;
        p.lastPoints = 0;
      }
    });

    if (anyCorrect) {
      window.SFX.playCorrectFanfare();
    } else {
      window.SFX.playWrongBuzzer();
    }

    this.setScreenState('answerReveal');
  }

  advanceToScoreboard() {
    window.SFX.playFocusClick();
    this.setScreenState('scoreboard');
  }

  nextRoundOrFinish() {
    window.SFX.playFocusClick();
    if (this.currentQuestionIndex < this.selectedCategory.questions.length - 1) {
      this.currentQuestionIndex++;
      this.startCountdown();
    } else {
      window.SFX.playVictoryPodium();
      this.setScreenState('winnerPodium');
    }
  }

  // MARK: - Screen Rendering

  renderCurrentState() {
    const container = document.getElementById('tv-screen-content');
    if (!container) return;

    switch (this.state) {
      case 'lobby':
        container.innerHTML = this.renderLobbyHTML();
        break;
      case 'categorySelect':
        container.innerHTML = this.renderCategorySelectHTML();
        break;
      case 'countdown':
        container.innerHTML = this.renderCountdownHTML();
        break;
      case 'questionActive':
        container.innerHTML = this.renderQuestionActiveHTML();
        this.updateTimerUI();
        this.updateLockedAvatarsUI();
        break;
      case 'answerReveal':
        container.innerHTML = this.renderAnswerRevealHTML();
        break;
      case 'scoreboard':
        container.innerHTML = this.renderScoreboardHTML();
        break;
      case 'winnerPodium':
        container.innerHTML = this.renderWinnerPodiumHTML();
        break;
    }
  }

  renderLobbyHTML() {
    return `
      <div class="lobby-screen">
        <div class="lobby-header">
          <div class="lobby-brand-row">
            <span class="pub-icon">🍻</span>
            <h1 class="lobby-title">TRIVIANIGHT TV</h1>
          </div>
          <p class="lobby-tagline">THE LIVING ROOM PUB QUIZ • MULTI-USER TVOS EXPERIENCE</p>
        </div>

        <div class="lobby-columns">
          <!-- Room Code Card -->
          <div class="room-code-card">
            <span class="code-badge">LOCAL LIVING ROOM CODE</span>
            <div class="room-code-display">PUB-4K</div>
            <div class="connect-hints">
              <p>📱 Enter your name on iPhone to appear right here</p>
              <p class="sub-hint">Or click with this Siri Remote to play as host</p>
            </div>
          </div>

          <!-- Connected Players -->
          <div class="players-roster-card">
            <div class="roster-header">
              <span>PLAYERS IN ROOM (${this.players.length})</span>
              <span class="room-status-dot">● READY TO PLAY</span>
            </div>
            <div class="players-grid">
              ${this.players.map(p => `
                <div class="player-roster-pill ${p.id === 'player-mobile' ? 'is-mobile-player highlight-active' : ''}" id="${p.id === 'player-mobile' ? 'tv-player-pill-mobile' : 'player-pill-' + p.id}">
                  <div class="player-avatar-circle" id="${p.id === 'player-mobile' ? 'tv-avatar-mobile' : ''}" style="background: ${p.color}">
                    ${p.avatar}
                  </div>
                  <div class="player-meta">
                    <span class="p-name" id="${p.id === 'player-mobile' ? 'tv-player-name-mobile' : ''}">${p.name}</span>
                    <span class="p-controller">● ${p.controller}</span>
                    ${p.isReady ? '<span class="p-status ready">● READY TO PLAY</span>' : '<span class="p-status syncing">● SYNCED (TYPING NAME...)</span>'}
                  </div>
                </div>
              `).join('')}
            </div>
          </div>
        </div>

        <div class="lobby-actions">
          <button class="tv-btn secondary focusable" onclick="window.App.goToCategorySelect()">
            <span>🗂️ Category Packs</span>
          </button>
          <button class="tv-btn primary focusable" onclick="window.App.startCountdown()">
            <span>Start Trivia Night 🚀</span>
          </button>
        </div>
      </div>
    `;
  }

  renderCategorySelectHTML() {
    return `
      <div class="category-screen">
        <div class="cat-header-row">
          <button class="back-pill focusable" onclick="window.App.handleBack()">
            <span>← Lobby</span>
          </button>
          <div class="cat-title-block">
            <span class="cat-eyebrow">CHOOSE YOUR TRIVIA PACK</span>
            <h2 class="cat-main-title">Select Tonight's Theme</h2>
          </div>
          <span class="cat-count-pill">${this.categories.length} PACKS AVAILABLE</span>
        </div>

        <div class="categories-grid">
          ${this.categories.map(c => `
            <div class="category-card focusable" onclick="window.App.selectCategory('${c.id}')" style="background: linear-gradient(135deg, ${c.colorStart}33, ${c.colorEnd}22)">
              <div class="cat-icon-disc" style="background: linear-gradient(135deg, ${c.colorStart}, ${c.colorEnd})">
                ${c.icon}
              </div>
              <div class="cat-info">
                <div class="cat-card-top">
                  <h3>${c.title}</h3>
                  <span class="q-count-badge">${c.questions.length} Questions</span>
                </div>
                <p>${c.tagline}</p>
              </div>
              <span class="cat-arrow">→</span>
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }

  renderCountdownHTML() {
    return `
      <div class="countdown-splash">
        <span class="countdown-round-tag">ROUND ${this.currentQuestionIndex + 1} OF ${this.selectedCategory.questions.length}</span>
        <div id="countdown-number" class="countdown-big-num">${this.countdownSeconds}</div>
        <span class="countdown-prompt">GET READY TO BUZZ IN!</span>
      </div>
    `;
  }

  renderQuestionActiveHTML() {
    const q = this.getCurrentQuestion();
    const letters = ["A", "B", "C", "D"];
    const colors = ["#f43f5e", "#0ea5e9", "#eab308", "#a855f7"];

    return `
      <div class="question-board-screen">
        <!-- Top Status Bar -->
        <div class="q-top-bar">
          <div class="q-cat-pill">
            <span>${this.selectedCategory.icon} ${this.selectedCategory.title.toUpperCase()}</span>
          </div>
          <div class="q-counter-pill">
            QUESTION ${this.currentQuestionIndex + 1} OF ${this.selectedCategory.questions.length}
          </div>
          <div class="q-points-pill">
            ★ ${q.basePoints} PTS + SPEED BONUS
          </div>
        </div>

        <!-- Question Prompt -->
        <div class="question-prompt-box">
          <h2 class="question-text">${q.prompt}</h2>
        </div>

        <!-- Live Countdown Timer -->
        <div class="countdown-track-wrapper">
          <div class="countdown-bar-track">
            <div id="question-timer-fill" class="countdown-bar-fill"></div>
          </div>
          <div class="countdown-time-label-row">
            <span class="timer-desc">FASTEST ANSWER WINS UP TO +500 SPEED BONUS</span>
            <span id="question-timer-text" class="timer-digits">15.0s</span>
          </div>
        </div>

        <!-- 4 Multiple Choice Cards -->
        <div class="answer-cards-grid">
          ${q.options.map((opt, idx) => `
            <div class="answer-card focusable" onclick="window.App.lockInPlayerAnswer('player-remote', ${idx})">
              <div class="option-letter-badge" style="background: ${colors[idx]}">
                ${letters[idx]}
              </div>
              <span class="option-label">${opt}</span>
              <div class="locked-avatars-cluster"></div>
            </div>
          `).join('')}
        </div>

        <!-- Bottom Locked In Strip -->
        <div class="bottom-locked-bar">
          <div class="lock-indicator">
            <span class="lock-icon">🔒</span>
            <span id="locked-count-label">0 OF ${this.players.length} PLAYERS LOCKED IN</span>
          </div>
          <button class="simulate-ai-btn focusable" onclick="window.App.simulateQuickBuzzer()">
            <span>🤖 Simulate iPhone Buzzer</span>
          </button>
        </div>
      </div>
    `;
  }

  renderAnswerRevealHTML() {
    const q = this.getCurrentQuestion();
    const correctOpt = q.options[q.correctIndex];

    return `
      <div class="answer-reveal-screen">
        <span class="reveal-eyebrow">ROUND RESULTS</span>

        <div class="correct-answer-banner">
          <div class="correct-header">
            <span class="check-icon">✓</span>
            <span>CORRECT ANSWER:</span>
          </div>
          <h2 class="correct-text">${correctOpt}</h2>
        </div>

        <div class="curio-card">
          <span class="curio-bulb">💡</span>
          <div class="curio-content">
            <span class="curio-tag">TRIVIA CURIO</span>
            <p>${q.explanation}</p>
          </div>
        </div>

        <div class="round-scores-section">
          <h3>ROUND SCORING & SPEED</h3>
          <div class="round-players-grid">
            ${this.players.map(p => {
              const isCorrect = p.selectedAnswer === q.correctIndex;
              return `
                <div class="round-player-row ${isCorrect ? 'correct' : 'wrong'}">
                  <div class="p-avatar-sm" style="background: ${p.color}">
                    ${p.avatar}
                  </div>
                  <div class="p-score-meta">
                    <span class="name">${p.name}</span>
                    <span class="speed">${p.answerTime ? p.answerTime + 's' : 'No answer'} ${p.streak > 1 ? '• 🔥 ' + p.streak + 'x' : ''}</span>
                  </div>
                  <div class="points-badge ${isCorrect ? 'positive' : 'zero'}">
                    ${isCorrect ? '+' + p.lastPoints : '0'}
                  </div>
                </div>
              `;
            }).join('')}
          </div>
        </div>

        <div class="reveal-actions">
          <button class="tv-btn primary focusable" onclick="window.App.advanceToScoreboard()">
            <span>View Standings 🏆</span>
          </button>
        </div>
      </div>
    `;
  }

  renderScoreboardHTML() {
    const ranked = [...this.players].sort((a, b) => b.score - a.score);
    const isLast = this.currentQuestionIndex >= this.selectedCategory.questions.length - 1;

    return `
      <div class="scoreboard-screen">
        <div class="sb-header">
          <span class="sb-tag">ROUND ${this.currentQuestionIndex + 1} OF ${this.selectedCategory.questions.length} COMPLETE</span>
          <h2>Current Leaderboard</h2>
        </div>

        <div class="leaderboard-stack">
          ${ranked.map((p, idx) => `
            <div class="leaderboard-row ${idx === 0 ? 'leader' : ''}">
              <div class="rank-badge rank-${idx + 1}">#${idx + 1}</div>
              <div class="p-avatar-disc" style="background: ${p.color}">
                ${p.avatar}
              </div>
              <div class="p-details">
                <span class="name">${p.name}</span>
                <span class="sub">${p.correctCount}/${p.totalCount} Correct ${p.streak > 1 ? '• 🔥 ' + p.streak + ' Streak' : ''}</span>
              </div>
              <div class="score-display">${p.score} PTS</div>
            </div>
          `).join('')}
        </div>

        <div class="sb-actions">
          <button class="tv-btn primary focusable" onclick="window.App.nextRoundOrFinish()">
            <span>${isLast ? 'View Final Pub Champions 🎉' : 'Next Question →'}</span>
          </button>
        </div>
      </div>
    `;
  }

  renderWinnerPodiumHTML() {
    const ranked = [...this.players].sort((a, b) => b.score - a.score);
    const winner = ranked[0];
    const runnerUp = ranked[1];
    const third = ranked[2];

    const streakMVP = [...this.players].sort((a, b) => b.highestStreak - a.highestStreak)[0];
    const accuracyMVP = [...this.players].sort((a, b) => (b.correctCount / (b.totalCount || 1)) - (a.correctCount / (a.totalCount || 1)))[0];

    return `
      <div class="winner-screen">
        <div class="winner-crown-row">
          <span class="crown-icon">👑</span>
          <span class="champs-tag">PUB QUIZ CHAMPIONS</span>
          <h1 class="winner-name">${winner ? winner.name : 'Trivia Champion'}</h1>
        </div>

        <div class="podium-stage">
          <!-- 2nd Place -->
          ${runnerUp ? `
            <div class="podium-col col-2">
              <div class="podium-avatar" style="background: ${runnerUp.color}">
                ${runnerUp.avatar}
              </div>
              <span class="podium-name">${runnerUp.name}</span>
              <span class="podium-score">${runnerUp.score} PTS</span>
              <div class="podium-block block-2">
                <span>#2</span>
              </div>
            </div>
          ` : ''}

          <!-- 1st Place -->
          ${winner ? `
            <div class="podium-col col-1">
              <div class="podium-avatar winner-avatar" style="background: ${winner.color}">
                ${winner.avatar}
              </div>
              <span class="podium-name">${winner.name}</span>
              <span class="podium-score gold">${winner.score} PTS</span>
              <div class="podium-block block-1">
                <span>#1 🏆</span>
              </div>
            </div>
          ` : ''}

          <!-- 3rd Place -->
          ${third ? `
            <div class="podium-col col-3">
              <div class="podium-avatar" style="background: ${third.color}">
                ${third.avatar}
              </div>
              <span class="podium-name">${third.name}</span>
              <span class="podium-score">${third.score} PTS</span>
              <div class="podium-block block-3">
                <span>#3</span>
              </div>
            </div>
          ` : ''}
        </div>

        <!-- MVP Badges -->
        <div class="mvp-strip">
          <div class="mvp-pill">
            <span class="badge-icon">🔥</span>
            <div>
              <span class="m-title">LONGEST HOT STREAK</span>
              <span class="m-val">${streakMVP.name} • ${streakMVP.highestStreak} In A Row</span>
            </div>
          </div>

          <div class="mvp-pill">
            <span class="badge-icon">🎯</span>
            <div>
              <span class="m-title">ACCURACY ACE</span>
              <span class="m-val">${accuracyMVP.name} • ${Math.round((accuracyMVP.correctCount / (accuracyMVP.totalCount || 1)) * 100)}% Correct</span>
            </div>
          </div>
        </div>

        <!-- Action Buttons -->
        <div class="winner-actions">
          <button class="tv-btn secondary focusable" onclick="window.App.setScreenState('lobby')">
            <span>↺ Play Again</span>
          </button>
          <button class="tv-btn primary focusable" onclick="window.App.goToCategorySelect()">
            <span>New Category Pack 🗂️</span>
          </button>
        </div>
      </div>
    `;
  }
}

window.addEventListener('DOMContentLoaded', () => {
  window.App = new TriviaNightApp();
});
