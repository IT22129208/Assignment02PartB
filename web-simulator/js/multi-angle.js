// Multi-angle Video Stream Synchronizer
class MultiAngleManager {
  constructor() {
    this.currentAngle = 'wide';
    this.isSplitScreen = false;
  }

  init() {
    this.renderButtons();
    this.setAngle(this.currentAngle, false);
  }

  setAngle(angleKey, playSfx = true) {
    const recipe = window.KITCHEN_DATA.recipe;
    const angleData = recipe.angles[angleKey];
    if (!angleData) return;

    this.currentAngle = angleKey;

    const mainFeed = document.getElementById('main-video-feed');
    const angleLabel = document.getElementById('active-angle-label');
    const angleDesc = document.getElementById('angle-description-toast');

    if (mainFeed) {
      mainFeed.style.opacity = '0.7';
      setTimeout(() => {
        mainFeed.src = angleData.image;
        mainFeed.style.opacity = '1';
      }, 100);
    }

    if (angleLabel) {
      angleLabel.textContent = angleData.label.toUpperCase();
    }

    // Highlight active camera button
    document.querySelectorAll('.cam-angle-btn').forEach(btn => {
      if (btn.dataset.angle === angleKey && !this.isSplitScreen) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });

    if (playSfx && window.SFX) {
      window.SFX.playFocusTick();
    }
  }

  toggleSplitScreen() {
    this.isSplitScreen = !this.isSplitScreen;
    const container = document.getElementById('video-viewport-container');
    const splitBtn = document.getElementById('btn-toggle-split');

    if (container) {
      if (this.isSplitScreen) {
        container.classList.add('split-view-active');
        if (splitBtn) splitBtn.classList.add('active');
        if (window.App) window.App.showToast("Split-Screen Dual Camera Activated", "#38bdf8");
      } else {
        container.classList.remove('split-view-active');
        if (splitBtn) splitBtn.classList.remove('active');
        this.setAngle(this.currentAngle, false);
      }
    }
  }

  renderButtons() {
    const container = document.getElementById('cam-angle-switcher');
    if (!container) return;

    const angles = window.KITCHEN_DATA.recipe.angles;
    let html = '';

    for (const [key, data] of Object.entries(angles)) {
      html += `
        <button class="cam-angle-btn focusable ${key === this.currentAngle ? 'active' : ''}" data-angle="${key}" onclick="window.MultiAngle.setAngle('${key}')">
          <span class="cam-dot"></span>
          <span>${data.label}</span>
        </button>
      `;
    }

    html += `
      <button id="btn-toggle-split" class="cam-angle-btn split-toggle focusable" onclick="window.MultiAngle.toggleSplitScreen()">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
          <path d="M3 5v14h8V5H3zm10 0v14h8V5h-8z"/>
        </svg>
        <span>Split-Screen Dual</span>
      </button>
    `;

    container.innerHTML = html;
  }
}

window.MultiAngle = new MultiAngleManager();
