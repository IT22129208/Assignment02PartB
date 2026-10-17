// tvOS FocusEngine Simulator
class TVFocusEngine {
  constructor() {
    this.currentFocused = null;
    this.initKeyboardListeners();
  }

  getFocusableElements() {
    return Array.from(document.querySelectorAll('.focusable'))
      .filter(el => {
        const style = window.getComputedStyle(el);
        return style.display !== 'none' && style.visibility !== 'hidden' && el.offsetParent !== null && !el.disabled;
      });
  }

  setFocus(element, playSound = true) {
    if (!element) return;
    if (this.currentFocused) {
      this.currentFocused.classList.remove('is-focused');
    }
    this.currentFocused = element;
    this.currentFocused.classList.add('is-focused');
    this.currentFocused.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    if (playSound && window.SFX) {
      window.SFX.playFocusClick();
    }
  }

  moveFocus(direction) {
    const focusables = this.getFocusableElements();
    if (!focusables.length) return;

    if (!this.currentFocused || !focusables.includes(this.currentFocused)) {
      this.setFocus(focusables[0]);
      return;
    }

    const currentRect = this.currentFocused.getBoundingClientRect();
    const currentCenter = {
      x: currentRect.left + currentRect.width / 2,
      y: currentRect.top + currentRect.height / 2
    };

    let bestCandidate = null;
    let minDistance = Infinity;

    for (const candidate of focusables) {
      if (candidate === this.currentFocused) continue;
      const r = candidate.getBoundingClientRect();
      const candCenter = {
        x: r.left + r.width / 2,
        y: r.top + r.height / 2
      };

      const dx = candCenter.x - currentCenter.x;
      const dy = candCenter.y - currentCenter.y;

      let isEligible = false;
      if (direction === 'up' && dy < -10) isEligible = true;
      if (direction === 'down' && dy > 10) isEligible = true;
      if (direction === 'left' && dx < -10) isEligible = true;
      if (direction === 'right' && dx > 10) isEligible = true;

      if (isEligible) {
        // Spatial angle weighting for natural 2D grid snapping
        const distance = Math.hypot(dx, dy) + (
          (direction === 'up' || direction === 'down') ? Math.abs(dx) * 1.5 : Math.abs(dy) * 1.5
        );
        if (distance < minDistance) {
          minDistance = distance;
          bestCandidate = candidate;
        }
      }
    }

    if (bestCandidate) {
      this.setFocus(bestCandidate);
    }
  }

  triggerSelect() {
    if (this.currentFocused) {
      this.currentFocused.click();
      this.currentFocused.classList.add('is-pressed');
      setTimeout(() => {
        if (this.currentFocused) {
          this.currentFocused.classList.remove('is-pressed');
        }
      }, 150);
    }
  }

  initKeyboardListeners() {
    window.addEventListener('keydown', (e) => {
      // Don't intercept if user is typing in an input
      if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) return;

      switch (e.key) {
        case 'ArrowUp':
          e.preventDefault();
          this.moveFocus('up');
          break;
        case 'ArrowDown':
          e.preventDefault();
          this.moveFocus('down');
          break;
        case 'ArrowLeft':
          e.preventDefault();
          this.moveFocus('left');
          break;
        case 'ArrowRight':
          e.preventDefault();
          this.moveFocus('right');
          break;
        case 'Enter':
        case ' ':
          e.preventDefault();
          this.triggerSelect();
          break;
        case 'Escape':
        case 'Backspace':
          e.preventDefault();
          if (window.App && typeof window.App.handleBack === 'function') {
            window.App.handleBack();
          }
          break;
      }
    });
  }
}

window.FocusEngine = new TVFocusEngine();
