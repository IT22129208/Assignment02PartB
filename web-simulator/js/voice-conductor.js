// Hands-free Kitchen Voice Conductor using Web Speech API + Siri Waveform
class VoiceConductor {
  constructor() {
    this.recognition = null;
    this.isListening = false;
    this.supported = false;
    this.setupSpeech();
  }

  setupSpeech() {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (SpeechRecognition) {
      this.supported = true;
      this.recognition = new SpeechRecognition();
      this.recognition.continuous = true;
      this.recognition.interimResults = true;
      this.recognition.lang = 'en-US';

      this.recognition.onstart = () => {
        this.isListening = true;
        this.updateWaveformUI(true, "Kitchen mic active: Speak command...");
      };

      this.recognition.onresult = (event) => {
        let interimTranscript = '';
        let finalTranscript = '';

        for (let i = event.resultIndex; i < event.results.length; ++i) {
          if (event.results[i].isFinal) {
            finalTranscript += event.results[i][0].transcript;
          } else {
            interimTranscript += event.results[i][0].transcript;
          }
        }

        const currentText = (finalTranscript || interimTranscript).trim();
        if (currentText) {
          this.updateWaveformUI(true, `"${currentText}"`);
        }

        if (finalTranscript) {
          this.parseCommand(finalTranscript);
        }
      };

      this.recognition.onerror = (e) => {
        console.warn("Speech recognition notice:", e.error);
        if (e.error === 'not-allowed') {
          this.updateWaveformUI(false, "Mic permission needed (or use sample chips below)");
        }
      };

      this.recognition.onend = () => {
        if (this.isListening) {
          // Restart recognition for continuous kitchen hands-free use
          try {
            this.recognition.start();
          } catch (e) {
            this.isListening = false;
            this.updateWaveformUI(false, "Voice Conductor Ready");
          }
        } else {
          this.updateWaveformUI(false, "Voice Conductor Idle");
        }
      };
    }
  }

  toggle() {
    if (!this.supported) {
      if (window.App) window.App.showToast("Speech API not supported in this browser; click voice test chips instead!", "#ef4444");
      return;
    }

    if (this.isListening) {
      this.isListening = false;
      this.recognition.stop();
      this.updateWaveformUI(false, "Voice Conductor Stopped");
    } else {
      try {
        this.recognition.start();
        this.isListening = true;
        if (window.SFX) window.SFX.playSelectSound();
      } catch (e) {
        console.warn("Could not start recognition:", e);
      }
    }
  }

  updateWaveformUI(active, text) {
    const pill = document.getElementById('voice-indicator-pill');
    const label = document.getElementById('voice-transcript-label');
    const wave = document.getElementById('voice-waveform');

    if (pill) {
      if (active) pill.classList.add('listening');
      else pill.classList.remove('listening');
    }
    if (label) {
      label.textContent = text;
    }
    if (wave) {
      if (active) wave.classList.add('animating');
      else wave.classList.remove('animating');
    }
  }

  parseCommand(text) {
    const lower = text.toLowerCase();
    console.log("[KitchenCrew Voice] Heard:", lower);

    if (lower.includes("next") || lower.includes("done") || lower.includes("continue") || lower.includes("step complete")) {
      if (window.App) {
        window.App.showToast(`Voice: "Next Step" recognized`, "#38bdf8");
        window.App.nextStep();
      }
      return;
    }

    if (lower.includes("previous") || lower.includes("back") || lower.includes("last step")) {
      if (window.App) {
        window.App.showToast(`Voice: "Previous Step" recognized`, "#38bdf8");
        window.App.prevStep();
      }
      return;
    }

    if (lower.includes("pan") || lower.includes("macro") || lower.includes("sizzle") || lower.includes("close up")) {
      if (window.MultiAngle) {
        window.MultiAngle.setAngle('macro');
        if (window.App) window.App.showToast(`Voice: Switched to Pan Sizzle Angle`, "#f97316");
      }
      return;
    }

    if (lower.includes("wide") || lower.includes("chef") || lower.includes("island")) {
      if (window.MultiAngle) {
        window.MultiAngle.setAngle('wide');
        if (window.App) window.App.showToast(`Voice: Switched to Chef Island Wide`, "#38bdf8");
      }
      return;
    }

    if (lower.includes("plating") || lower.includes("overhead")) {
      if (window.MultiAngle) {
        window.MultiAngle.setAngle('plating');
        if (window.App) window.App.showToast(`Voice: Switched to Plating Angle`, "#a855f7");
      }
      return;
    }

    if (lower.includes("split screen") || lower.includes("dual") || lower.includes("both")) {
      if (window.MultiAngle) {
        window.MultiAngle.toggleSplitScreen();
      }
      return;
    }

    if (lower.includes("timer")) {
      let seconds = 90;
      const match = lower.match(/\d+/);
      if (match) {
        const val = parseInt(match[0], 10);
        if (lower.includes("min")) seconds = val * 60;
        else seconds = val;
      }
      if (window.App) {
        window.App.addTimer(`Timer (${seconds}s)`, seconds);
      }
      return;
    }

    if (lower.includes("substitute") || lower.includes("replace") || lower.includes("alternative")) {
      if (window.App) {
        window.App.openSubstitutionsModal();
        window.App.showToast(`Voice: Opening Ingredient Substitutions`, "#10b981");
      }
      return;
    }

    if (lower.includes("viva") || lower.includes("pitch") || lower.includes("presentation") || lower.includes("slides")) {
      if (window.Presentation) {
        window.Presentation.open();
      }
      return;
    }

    if (window.App) {
      window.App.showToast(`Heard: "${text}"`, "#94a3b8");
    }
  }

  // Quick helper to simulate voice command without microphone
  simulateCommand(text) {
    this.updateWaveformUI(true, `Simulated: "${text}"`);
    setTimeout(() => {
      this.parseCommand(text);
      setTimeout(() => {
        this.updateWaveformUI(this.isListening, this.isListening ? "Kitchen mic active: Speak command..." : "Voice Conductor Ready");
      }, 1500);
    }, 400);
  }
}

window.Voice = new VoiceConductor();
