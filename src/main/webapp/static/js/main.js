/**
 * BOOKTRAIL — Mountain Literary Café Client Interaction Controller
 * Theme persistence, responsive navigation, password toggling, and interactive UI
 */

(function () {
    'use strict';

    // ------------------------------------------------------------------------
    // 1. Theme Management (Light / Dark Mode with Persistence)
    // ------------------------------------------------------------------------
    const THEME_STORAGE_KEY = 'booktrail_theme';

    function getPreferredTheme() {
        const storedTheme = localStorage.getItem(THEME_STORAGE_KEY);
        if (storedTheme) {
            return storedTheme;
        }
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    }

    function applyTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem(THEME_STORAGE_KEY, theme);
        updateThemeToggleIcons(theme);
    }

    function toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
        const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
        applyTheme(newTheme);
    }

    function updateThemeToggleIcons(theme) {
        const toggleButtons = document.querySelectorAll('.theme-toggle-btn');
        toggleButtons.forEach(btn => {
            if (theme === 'dark') {
                btn.innerHTML = `
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <circle cx="12" cy="12" r="5"></circle>
                        <line x1="12" y1="1" x2="12" y2="3"></line>
                        <line x1="12" y1="21" x2="12" y2="23"></line>
                        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
                        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
                        <line x1="1" y1="12" x2="3" y2="12"></line>
                        <line x1="21" y1="12" x2="23" y2="12"></line>
                        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
                        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
                    </svg>`;
                btn.setAttribute('title', 'Switch to Morning Mist (Light theme)');
                btn.setAttribute('aria-label', 'Switch to light theme');
            } else {
                btn.innerHTML = `
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
                    </svg>`;
                btn.setAttribute('title', 'Switch to Night Lodge (Dark theme)');
                btn.setAttribute('aria-label', 'Switch to dark theme');
            }
        });
    }

    // ------------------------------------------------------------------------
    // 2. Mobile Menu Navigation
    // ------------------------------------------------------------------------
    function initMobileNav() {
        const menuBtn = document.querySelector('.mobile-menu-btn');
        const drawer = document.querySelector('.mobile-drawer');

        if (!menuBtn || !drawer) return;

        menuBtn.addEventListener('click', function (e) {
            e.stopPropagation();
            const isOpen = drawer.classList.contains('active');
            if (isOpen) {
                drawer.classList.remove('active');
                menuBtn.setAttribute('aria-expanded', 'false');
            } else {
                drawer.classList.add('active');
                menuBtn.setAttribute('aria-expanded', 'true');
            }
        });

        document.addEventListener('click', function (e) {
            if (!drawer.contains(e.target) && !menuBtn.contains(e.target)) {
                drawer.classList.remove('active');
                menuBtn.setAttribute('aria-expanded', 'false');
            }
        });
    }

    // ------------------------------------------------------------------------
    // 3. Password Visibility Controls
    // ------------------------------------------------------------------------
    function initPasswordToggles() {
        const toggles = document.querySelectorAll('.password-toggle-btn');
        toggles.forEach(btn => {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                const targetId = this.getAttribute('data-target');
                const input = document.getElementById(targetId) || this.previousElementSibling;
                if (!input) return;

                if (input.type === 'password') {
                    input.type = 'text';
                    this.innerHTML = `
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                            <line x1="1" y1="1" x2="23" y2="23"></line>
                        </svg>`;
                    this.setAttribute('aria-label', 'Hide password');
                } else {
                    input.type = 'password';
                    this.innerHTML = `
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>`;
                    this.setAttribute('aria-label', 'Show password');
                }
            });
        });
    }

    // ------------------------------------------------------------------------
    // 4. Interactive Star Rating Selector
    // ------------------------------------------------------------------------
    function initStarRating() {
        const ratingContainers = document.querySelectorAll('.star-rating-select');
        ratingContainers.forEach(container => {
            const stars = container.querySelectorAll('span');
            const hiddenInput = container.querySelector('input[type="hidden"]') || document.getElementById('selectedRating');

            stars.forEach(star => {
                star.addEventListener('click', function () {
                    const val = parseInt(this.getAttribute('data-val'), 10);
                    if (hiddenInput) {
                        hiddenInput.value = val;
                    }
                    stars.forEach(s => {
                        const sVal = parseInt(s.getAttribute('data-val'), 10);
                        if (sVal <= val) {
                            s.classList.add('active');
                            s.style.color = '#D48806';
                        } else {
                            s.classList.remove('active');
                            s.style.color = 'var(--border-color)';
                        }
                    });
                });
            });
        });
    }

    // ------------------------------------------------------------------------
    // 5. Interactive Reading Progress Quick Updater
    // ------------------------------------------------------------------------
    function initProgressFeedback() {
        const chapterInputs = document.querySelectorAll('.input-chapter-sync');
        chapterInputs.forEach(input => {
            input.addEventListener('input', function () {
                const total = parseInt(this.getAttribute('data-total') || '100', 10);
                const current = parseInt(this.value || '0', 10);
                const percent = Math.min(100, Math.max(0, Math.round((current / total) * 100)));
                const fillEl = document.getElementById(this.getAttribute('data-fill-id'));
                if (fillEl) {
                    fillEl.style.width = percent + '%';
                }
                const labelEl = document.getElementById(this.getAttribute('data-label-id'));
                if (labelEl) {
                    labelEl.textContent = percent + '%';
                }
            });
        });
    }

    // ------------------------------------------------------------------------
    // DOM Ready Initialization
    // ------------------------------------------------------------------------
    document.addEventListener('DOMContentLoaded', function () {
        // Apply persisted theme immediately
        const theme = getPreferredTheme();
        applyTheme(theme);

        // Bind theme buttons
        document.querySelectorAll('.theme-toggle-btn').forEach(btn => {
            btn.addEventListener('click', toggleTheme);
        });

        // Initialize features
        initMobileNav();
        initPasswordToggles();
        initStarRating();
        initProgressFeedback();

        // Smooth scroll to hash
        if (window.location.hash) {
            const target = document.querySelector(window.location.hash);
            if (target) {
                setTimeout(() => target.scrollIntoView({ behavior: 'smooth' }), 100);
            }
        }
    });

    // Expose helpers globally for inline onclick handlers if needed
    window.BookTrail = {
        toggleTheme: toggleTheme,
        openModal: function (modalId) {
            const m = document.getElementById(modalId);
            if (m) {
                m.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        },
        closeModal: function (modalId) {
            const m = document.getElementById(modalId);
            if (m) {
                m.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
    };
})();
