// Master KitchenCrew Application Controller
class KitchenCrewApp {
  constructor() {
    this.recipe = window.KITCHEN_DATA.recipe;
    this.currentStepIndex = 0;
    this.timers = [
      { id: 't1', label: 'Cauliflower Steam', totalSeconds: 420, remainingSeconds: 380, isRunning: true, station: 'prep', color: '#38bdf8' },
      { id: 't2', label: 'Scallop Sear', totalSeconds: 90, remainingSeconds: 90, isRunning: false, station: 'saute', color: '#f97316' }
    ];
    this.timerInterval = null;
  }

  init() {
    this.renderHeader();
    this.renderCurrentStep();
    this.renderSubstationStrip();
    this.renderTimers();
    this.startTimerLoop();

    // Initialize sub-modules
    if (window.MultiAngle) window.MultiAngle.init();
    if (window.SyncBus) window.SyncBus.init();
    if (window.FocusEngine) window.FocusEngine.init();
    if (window.Presentation) window.Presentation.init();

    this.bindRemoteControls();
  }

  renderHeader() {
    const titleEl = document.getElementById('recipe-main-title');
    const chefEl = document.getElementById('chef-credit-label');
    if (titleEl) titleEl.textContent = this.recipe.title;
    if (chefEl) chefEl.textContent = this.recipe.masterChef;
  }

  renderCurrentStep() {
    const step = this.recipe.steps[this.currentStepIndex];
    if (!step) return;

    // Update Progress
    const stepBadge = document.getElementById('step-counter-badge');
    if (stepBadge) stepBadge.textContent = `STEP ${step.id} OF ${this.recipe.steps.length}`;

    const progressFill = document.getElementById('master-progress-fill');
    if (progressFill) {
      const pct = (step.id / this.recipe.steps.length) * 100;
      progressFill.style.width = `${pct}%`;
    }

    // Station Badge
    const stationBadge = document.getElementById('step-station-badge');
    if (stationBadge) {
      stationBadge.textContent = step.stationName.toUpperCase();
      stationBadge.style.color = step.stationColor;
      stationBadge.style.backgroundColor = `${step.stationColor}22`;
      stationBadge.style.borderColor = `${step.stationColor}44`;
    }

    // Step Title & Instructions
    const titleEl = document.getElementById('step-title-text');
    if (titleEl) titleEl.textContent = step.title;

    const instructionEl = document.getElementById('step-instruction-text');
    if (instructionEl) instructionEl.textContent = step.instruction;

    // Callout (Warning or Chef Tip)
    const calloutEl = document.getElementById('step-callout-box');
    if (calloutEl) {
      if (step.warning) {
        calloutEl.className = 'step-callout warning';
        calloutEl.innerHTML = `
          <div class="callout-icon">⚠️</div>
          <div class="callout-body">
            <div class="callout-title">CRITICAL CHEF ALERT</div>
            <div class="callout-text">${step.warning}</div>
          </div>
        `;
        calloutEl.style.display = 'flex';
      } else if (step.chefTip) {
        calloutEl.className = 'step-callout tip';
        calloutEl.innerHTML = `
          <div class="callout-icon">💡</div>
          <div class="callout-body">
            <div class="callout-title">MICHELIN CHEF TIP</div>
            <div class="callout-text">${step.chefTip}</div>
          </div>
        `;
        calloutEl.style.display = 'flex';
      } else {
        calloutEl.style.display = 'none';
      }
    }

    // Step Next Button Label
    const nextBtn = document.getElementById('btn-next-step');
    if (nextBtn) {
      if (this.currentStepIndex === this.recipe.steps.length - 1) {
        nextBtn.innerHTML = `<span>Complete Recipe 🎉</span>`;
      } else {
        nextBtn.innerHTML = `<span>Step Complete (Next)</span> ➔`;
      }
    }

    // Auto-switch camera angle to match step recommendation if not manual
    if (window.MultiAngle && step.recommendedAngle) {
      window.MultiAngle.setAngle(step.recommendedAngle, false);
    }
  }

  nextStep() {
    if (this.currentStepIndex < this.recipe.steps.length - 1) {
      this.currentStepIndex++;
      this.renderCurrentStep();
      if (window.SFX) window.SFX.playStepComplete();
      this.showToast(`Advanced to Step ${this.currentStepIndex + 1}: ${this.recipe.steps[this.currentStepIndex].title}`, '#38bdf8');
    } else {
      this.showToast("🎉 Recipe Completed! Bon Appétit, KitchenCrew!", "#10b981");
      if (window.SFX) window.SFX.playTimerBell();
    }
  }

  prevStep() {
    if (this.currentStepIndex > 0) {
      this.currentStepIndex--;
      this.renderCurrentStep();
      if (window.SFX) window.SFX.playFocusTick();
    }
  }

  renderSubstationStrip() {
    const strip = document.getElementById('substation-status-strip');
    if (!strip || !window.SyncBus) return;

    let html = '';
    window.SyncBus.stations.forEach(station => {
      const completed = station.tasks.filter(t => t.completed).length;
      const total = station.tasks.length;
      const pct = Math.round((completed / total) * 100);
      const activeTask = station.tasks.find(t => !t.completed) || station.tasks[station.tasks.length - 1];

      html += `
        <div class="station-chip focusable" onclick="window.App.showToast('${station.name} active task: ${activeTask ? activeTask.text : 'All done!'}', '${station.color}')">
          <div class="station-avatar" style="background: ${station.color}22; color: ${station.color}">
            ${station.name.split(' ')[1][0]}
          </div>
          <div class="station-meta">
            <div class="station-name-row">
              <span class="station-user">${station.name}</span>
              <span class="station-device-badge">${station.device}</span>
            </div>
            <div class="station-task-preview">${activeTask ? activeTask.text : 'Station tasks complete!'}</div>
            <div class="station-mini-progress">
              <div class="mini-fill" style="width: ${pct}%; background: ${station.color}"></div>
            </div>
          </div>
        </div>
      `;
    });

    strip.innerHTML = html;
  }

  renderTimers() {
    const container = document.getElementById('oversized-timers-container');
    if (!container) return;

    let html = '';
    this.timers.forEach(t => {
      const mins = Math.floor(t.remainingSeconds / 60);
      const secs = t.remainingSeconds % 60;
      const timeStr = `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
      const isUrgent = t.remainingSeconds <= 30 && t.remainingSeconds > 0;
      const progress = 1 - (t.remainingSeconds / t.totalSeconds);
      const strokeOffset = 220 - (220 * progress);

      html += `
        <div class="timer-card focusable ${isUrgent ? 'urgent' : ''}" onclick="window.App.toggleTimer('${t.id}')">
          <div class="timer-radial">
            <svg class="timer-dial-svg" width="68" height="68">
              <circle class="timer-track-bg" cx="34" cy="34" r="28" />
              <circle class="timer-track-fg" cx="34" cy="34" r="28" style="stroke-dashoffset: ${strokeOffset}; stroke: ${isUrgent ? '#ef4444' : t.color};" />
            </svg>
            <div class="timer-icon-center">
              ${t.isRunning ? '⏱️' : '⏸️'}
            </div>
          </div>
          <div class="timer-info">
            <div class="timer-label-row">
              <span class="timer-title">${t.label.toUpperCase()}</span>
              <span class="timer-state-tag" style="background: ${t.color}22; color: ${t.color}">${t.station.toUpperCase()}</span>
            </div>
            <div class="timer-clock-digits ${isUrgent ? 'pulse-urgent' : ''}">${timeStr}</div>
          </div>
        </div>
      `;
    });

    container.innerHTML = html;
  }

  toggleTimer(id) {
    const timer = this.timers.find(t => t.id === id);
    if (timer) {
      timer.isRunning = !timer.isRunning;
      if (window.SFX) window.SFX.playFocusTick();
      this.renderTimers();
      this.showToast(`${timer.label} ${timer.isRunning ? 'Started' : 'Paused'}`, timer.color);
    }
  }

  addTimer(label, seconds) {
    const newTimer = {
      id: `timer-${Date.now()}`,
      label: label,
      totalSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: true,
      station: 'chef',
      color: '#f97316'
    };
    this.timers.unshift(newTimer);
    if (this.timers.length > 2) this.timers.pop(); // keep 2 on big screen
    this.renderTimers();
    if (window.SFX) window.SFX.playStepComplete();
    this.showToast(`Started new timer: ${label} (${seconds}s)`, "#f97316");
  }

  startTimerLoop() {
    this.timerInterval = setInterval(() => {
      let needsRerender = false;
      this.timers.forEach(t => {
        if (t.isRunning && t.remainingSeconds > 0) {
          t.remainingSeconds--;
          needsRerender = true;
          if (t.remainingSeconds === 0) {
            t.isRunning = false;
            if (window.SFX) window.SFX.playTimerBell();
            this.showToast(`🔔 TIMER COMPLETE: ${t.label}!`, "#ef4444");
          }
        }
      });
      if (needsRerender) {
        this.renderTimers();
      }
    }, 1000);
  }

  showToast(message, color = "#f97316") {
    const toast = document.getElementById('tv-toast-banner');
    if (!toast) return;

    toast.innerHTML = `
      <span class="toast-dot" style="background: ${color}"></span>
      <span class="toast-text">${message}</span>
    `;
    toast.style.borderColor = `${color}66`;
    toast.classList.add('visible');

    if (this.toastTimeout) clearTimeout(this.toastTimeout);
    this.toastTimeout = setTimeout(() => {
      toast.classList.remove('visible');
    }, 3800);
  }

  openSubstitutionsModal() {
    const modal = document.getElementById('substitutions-modal');
    if (modal) {
      modal.classList.add('active');
      if (window.SFX) window.SFX.playSelectSound();
    }
  }

  closeSubstitutionsModal() {
    const modal = document.getElementById('substitutions-modal');
    if (modal) {
      modal.classList.remove('active');
      if (window.SFX) window.SFX.playFocusTick();
    }
  }

  applySubstitution(name, replacement) {
    this.showToast(`Applied Substitution: ${replacement} for ${name}`, "#10b981");
    this.closeSubstitutionsModal();
    if (window.SFX) window.SFX.playStepComplete();
  }

  bindRemoteControls() {
    // Virtual Apple Siri Remote Buttons
    const dpadUp = document.getElementById('remote-up');
    const dpadDown = document.getElementById('remote-down');
    const dpadLeft = document.getElementById('remote-left');
    const dpadRight = document.getElementById('remote-right');
    const dpadCenter = document.getElementById('remote-center');
    const remoteBack = document.getElementById('remote-back');
    const remotePlay = document.getElementById('remote-play');
    const remoteMic = document.getElementById('remote-mic');

    if (dpadUp) dpadUp.onclick = () => window.FocusEngine.navigate('up');
    if (dpadDown) dpadDown.onclick = () => window.FocusEngine.navigate('down');
    if (dpadLeft) dpadLeft.onclick = () => window.FocusEngine.navigate('left');
    if (dpadRight) dpadRight.onclick = () => window.FocusEngine.navigate('right');
    if (dpadCenter) dpadCenter.onclick = () => window.FocusEngine.selectCurrent();
    if (remoteBack) remoteBack.onclick = () => {
      const modal = document.querySelector('.modal-overlay.active');
      if (modal) modal.classList.remove('active');
      else this.prevStep();
    };
    if (remotePlay) remotePlay.onclick = () => {
      if (this.timers[0]) this.toggleTimer(this.timers[0].id);
    };
    if (remoteMic) remoteMic.onclick = () => {
      if (window.Voice) window.Voice.toggle();
    };
  }
}

window.App = new KitchenCrewApp();
window.addEventListener('DOMContentLoaded', () => {
  window.App.init();
});
