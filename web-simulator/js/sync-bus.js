// Enhanced Real-Time Sync Bus connecting TV and Mobile Devices
// Supports 3 complementary channels:
// 1. Direct in-memory event dispatching (same window)
// 2. BroadcastChannel (cross-tab / multi-window on same browser)
// 3. Server-Sent Events (SSE) & HTTP API (cross-device over local Wi-Fi, e.g. real iPhone to TV)

class RealtimeSyncBus {
  constructor() {
    this.listeners = {};
    this.channel = null;
    this.eventSource = null;
    this.isConnected = false;
    this.localPlayerId = 'player-mobile';
    
    this.initBroadcastChannel();
    this.initServerEvents();
  }

  initBroadcastChannel() {
    if (typeof BroadcastChannel !== 'undefined') {
      try {
        this.channel = new BroadcastChannel('trivianight_sync_bus');
        this.channel.onmessage = (event) => {
          const { type, payload } = event.data || {};
          if (type) {
            this.dispatchLocal(type, payload, true);
          }
        };
      } catch (e) {
        console.warn('BroadcastChannel not supported:', e);
      }
    }
  }

  initServerEvents() {
    if (typeof EventSource !== 'undefined') {
      try {
        this.eventSource = new EventSource('/api/sync/events');
        this.eventSource.onopen = () => {
          this.isConnected = true;
          this.dispatchLocal('connectionStatus', { connected: true }, true);
        };
        this.eventSource.onmessage = (e) => {
          try {
            const parsed = JSON.parse(e.data);
            if (parsed.type === 'playerUpdate') {
              this.dispatchLocal('playerUpdate', parsed.data, true);
            } else if (parsed.type === 'playerAnswer') {
              this.dispatchLocal('playerAnswer', parsed.data, true);
            } else if (parsed.type === 'gameState') {
              this.dispatchLocal('gameState', parsed.data, true);
            }
          } catch (err) {}
        };
        this.eventSource.onerror = () => {
          this.isConnected = false;
        };
      } catch (e) {}
    }
  }

  on(event, callback) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(callback);
  }

  dispatchLocal(event, payload, fromRemote = false) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(cb => cb(payload, fromRemote));
    }
  }

  emit(event, payload) {
    // 1. Local window dispatch
    this.dispatchLocal(event, payload, false);

    // 2. BroadcastChannel dispatch (cross-tab)
    if (this.channel) {
      try {
        this.channel.postMessage({ type: event, payload });
      } catch (e) {}
    }

    // 3. Server HTTP dispatch (cross-device)
    if (event === 'playerUpdate') {
      fetch('/api/sync/update-player', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).catch(() => {});
    } else if (event === 'playerAnswer') {
      fetch('/api/sync/answer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).catch(() => {});
    } else if (event === 'gameState') {
      fetch('/api/sync/game-state', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).catch(() => {});
    }
  }

  // Update player profile (name, avatar, color)
  updatePlayerProfile(name, avatar, color, isReady = true) {
    this.emit('playerUpdate', {
      id: this.localPlayerId,
      name: name,
      avatar: avatar,
      color: color,
      controller: 'iPhone',
      isReady: isReady
    });
  }

  // Send buzzer lock-in from iPhone
  sendCompanionBuzzer(playerId, answerIndex, answerTime = 2.0) {
    this.emit('playerAnswer', {
      playerId: playerId || this.localPlayerId,
      answerIndex,
      answerTime,
      timestamp: Date.now()
    });
  }
}

window.SyncBus = new RealtimeSyncBus();
