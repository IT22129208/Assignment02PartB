// Multipeer Sync Bus Simulator connecting Siri Remote and Companion iPhone Buzzers
class SyncBus {
  constructor() {
    this.listeners = {};
  }

  on(event, callback) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(callback);
  }

  emit(event, payload) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(cb => cb(payload));
    }
  }

  // Helper to send buzzer lock-in from iPhone Companion
  sendCompanionBuzzer(playerId, answerIndex) {
    this.emit('playerAnswer', { playerId, answerIndex, timestamp: Date.now() });
  }
}

window.SyncBus = new SyncBus();
