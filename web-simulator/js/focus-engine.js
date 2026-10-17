// Apple TV 4K Focus Engine implementation with 3D Tilt Parallax & Spatial Navigation
class TVFocusEngine {
  constructor() {
    this.currentFocused = null;
    this.isListening = false;
  }

  init() {
    this.bindEvents();
    // Default focus on the primary action button
    setTimeout(() => {
      const initial = document.querySelector('.focusable.default-focus') || document.querySelector('.focusable');
      if (initial) {
        this.setFocus(initial);
      }
    }, 200);
  }

  getFocusableElements() {
    return Array.from(document.querySelectorAll('.focusable:not([disabled]):not(.hidden)'))
      .filter(el => {
        const rect = el.getBoundingClientRect();
        return rect.width > 0 && rect.height > 0 && window.getComputedStyle(el).display !== 'none';
      });
  }

  setFocus(el) {
    if (!el || el === this.currentFocused) return;
    
    if (this.currentFocused) {
      this.currentFocused.classList.remove('focused');
      this.currentFocused.style.transform = '';
      const sheen = this.currentFocused.querySelector('.specular-sheen');
      if (sheen) sheen.style.opacity = '0';
    }

    this.currentFocused = el;
    el.classList.add('focused');
    el.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'nearest' });

    if (window.SFX) {
      window.SFX.playFocusTick();
    }

    // Attach parallax hover listener
    this.attachTiltEffect(el);
  }

  attachTiltEffect(el) {
    el.onmousemove = (e) => {
      if (!el.classList.contains('focused')) return;
      const rect = el.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;

      const deltaX = (x - centerX) / centerX;
      const deltaY = (y - centerY) / centerY;

      const rotateX = -deltaY * 8; // degrees
      const rotateY = deltaX * 8;

      el.style.transform = `scale(1.06) perspective(800px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateZ(12px)`;
    };

    el.onmouseleave = () => {
      if (el.classList.contains('focused')) {
        el.style.transform = 'scale(1.05)';
      }
    };
  }

  navigate(direction) {
    const focusables = this.getFocusableElements();
    if (!focusables.length) return;
    if (!this.currentFocused) {
      this.setFocus(focusables[0]);
      return;
    }

    const currentRect = this.currentFocused.getBoundingClientRect();
    const currentCenter = {
      x: currentRect.left + currentRect.width / 2,
      y: currentRect.top + currentRect.height / 2
    };

    let bestElement = null;
    let minDistance = Infinity;

    focusables.forEach(target => {
      if (target === this.currentFocused) return;
      const targetRect = target.getBoundingClientRect();
      const targetCenter = {
        x: targetRect.left + targetRect.width / 2,
        y: targetRect.top + targetRect.height / 2
      };

      const dx = targetCenter.x - currentCenter.x;
      const dy = targetCenter.y - currentCenter.y;

      let isValidDirection = false;
      let primaryDistance = 0;
      let secondaryDistance = 0;

      switch (direction) {
        case 'up':
          isValidDirection = dy < -10;
          primaryDistance = Math.abs(dy);
          secondaryDistance = Math.abs(dx);
          break;
        case 'down':
          isValidDirection = dy > 10;
          primaryDistance = Math.abs(dy);
          secondaryDistance = Math.abs(dx);
          break;
        case 'left':
          isValidDirection = dx < -10;
          primaryDistance = Math.abs(dx);
          secondaryDistance = Math.abs(dy);
          break;
        case 'right':
          isValidDirection = dx > 10;
          primaryDistance = Math.abs(dx);
          secondaryDistance = Math.abs(dy);
          break;
      }

      if (isValidDirection) {
        // Weighted metric giving higher priority to collinear elements
        const distance = primaryDistance + secondaryDistance * 2.2;
        if (distance < minDistance) {
          minDistance = distance;
          bestElement = target;
        }
      }
    });

    if (bestElement) {
      this.setFocus(bestElement);
    }
  }

  selectCurrent() {
    if (this.currentFocused) {
      if (window.SFX) window.SFX.playSelectSound();
      this.currentFocused.click();
      
      // Haptic bounce
      this.currentFocused.style.transform = 'scale(0.96)';
      setTimeout(() => {
        if (this.currentFocused) {
          this.currentFocused.style.transform = 'scale(1.05)';
        }
      }, 120);
    }
  }

  bindEvents() {
    if (this.isListening) return;
    this.isListening = true;

    window.addEventListener('keydown', (e) => {
      // Ignore if typing in text input
      if (['input', 'textarea'].includes(document.activeElement.tagName.toLowerCase())) return;

      switch (e.key) {
        case 'ArrowUp':
          e.preventDefault();
          this.navigate('up');
          break;
        case 'ArrowDown':
          e.preventDefault();
          this.navigate('down');
          break;
        case 'ArrowLeft':
          e.preventDefault();
          this.navigate('left');
          break;
        case 'ArrowRight':
          e.preventDefault();
          this.navigate('right');
          break;
        case 'Enter':
        case ' ':
          e.preventDefault();
          this.selectCurrent();
          break;
        case 'Escape':
        case 'Backspace':
          e.preventDefault();
          // Trigger back/menu
          const modal = document.querySelector('.modal-overlay.active');
          if (modal) {
            modal.classList.remove('active');
          } else {
            const backBtn = document.getElementById('btn-prev-step');
            if (backBtn) backBtn.click();
          }
          break;
      }
    });
  }
}

window.FocusEngine = new TVFocusEngine();
