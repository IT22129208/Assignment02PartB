// Interactive Viva Pitch Deck & Presentation Controller
class PresentationDeck {
  constructor() {
    this.currentSlide = 0;
    this.totalSlides = 8;
    this.isOpen = false;
  }

  init() {
    this.bindKeys();
  }

  open() {
    this.isOpen = true;
    const modal = document.getElementById('presentation-modal');
    if (modal) {
      modal.classList.add('active');
      this.showSlide(this.currentSlide);
    }
  }

  close() {
    this.isOpen = false;
    const modal = document.getElementById('presentation-modal');
    if (modal) {
      modal.classList.remove('active');
    }
  }

  next() {
    if (this.currentSlide < this.totalSlides - 1) {
      this.currentSlide++;
      this.showSlide(this.currentSlide);
    }
  }

  prev() {
    if (this.currentSlide > 0) {
      this.currentSlide--;
      this.showSlide(this.currentSlide);
    }
  }

  showSlide(index) {
    this.currentSlide = index;
    document.querySelectorAll('.deck-slide').forEach((slide, idx) => {
      if (idx === index) {
        slide.classList.add('active');
      } else {
        slide.classList.remove('active');
      }
    });

    const indicator = document.getElementById('deck-counter');
    if (indicator) {
      indicator.textContent = `SLIDE ${index + 1} OF ${this.totalSlides}`;
    }

    const progress = document.getElementById('deck-progress-bar');
    if (progress) {
      progress.style.width = `${((index + 1) / this.totalSlides) * 100}%`;
    }
  }

  bindKeys() {
    window.addEventListener('keydown', (e) => {
      if (!this.isOpen) return;

      if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {
        e.preventDefault();
        this.next();
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        e.preventDefault();
        this.prev();
      } else if (e.key === 'Escape') {
        e.preventDefault();
        this.close();
      }
    });
  }
}

window.Presentation = new PresentationDeck();
