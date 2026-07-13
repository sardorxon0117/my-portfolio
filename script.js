const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const isTouchDevice = 'ontouchstart' in window || navigator.maxTouchPoints > 0;

// ===== Preloader =====
document.body.classList.add('loading');
const preloader = document.getElementById('preloader');
const preloaderFill = document.getElementById('preloader-fill');
const preloaderNum = document.getElementById('preloader-num');

function runPreloader() {
  const duration = reduceMotion ? 200 : 1500;
  const start = performance.now();
  function tick(now) {
    const t = Math.min(1, (now - start) / duration);
    const eased = 1 - Math.pow(1 - t, 2);
    const pct = Math.round(eased * 100);
    preloaderFill.style.width = `${pct}%`;
    preloaderNum.textContent = pct;
    if (t < 1) {
      requestAnimationFrame(tick);
    } else {
      setTimeout(() => {
        preloader.classList.add('done');
        document.body.classList.remove('loading');
        setTimeout(() => preloader.classList.add('hidden'), reduceMotion ? 0 : 900);
      }, 200);
    }
  }
  requestAnimationFrame(tick);
}
runPreloader();

// ===== Theme toggle (light / dark) with localStorage persistence =====
const root = document.documentElement;
const themeToggle = document.getElementById('theme-toggle');

function getPreferredTheme() {
  const saved = localStorage.getItem('theme');
  if (saved) return saved;
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}
function applyTheme(theme) {
  root.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);
}
applyTheme(getPreferredTheme());
themeToggle.addEventListener('click', () => {
  applyTheme(root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark');
});

// ===== Mobile nav toggle =====
const navbar = document.querySelector('.navbar');
const navToggle = document.getElementById('nav-toggle');
navToggle.addEventListener('click', () => navbar.classList.toggle('open'));
document.querySelectorAll('.nav-links a').forEach((link) => {
  link.addEventListener('click', () => navbar.classList.remove('open'));
});

// ===== Custom cursor (brown pointer + "Ko'rish" label morph) =====
// Some tablets (iPadOS in particular) report hover:hover/pointer:fine via CSS media
// features even on pure touch input, so the CSS-only hide can't be trusted there —
// remove the elements outright based on the more reliable JS touch check.
if (isTouchDevice) {
  document.getElementById('cursor-pointer')?.remove();
  document.getElementById('cursor-ring')?.remove();
} else {
  const pointer = document.getElementById('cursor-pointer');
  const ring = document.getElementById('cursor-ring');
  const cursorLabel = document.getElementById('cursor-label');
  let mx = window.innerWidth / 2, my = window.innerHeight / 2;
  let rx = mx, ry = my;

  window.addEventListener('mousemove', (e) => {
    mx = e.clientX; my = e.clientY;
    pointer.style.transform = `translate(${mx}px, ${my}px) translate(-50%, -50%)`;
  });

  function animateCursor() {
    rx += (mx - rx) * 0.2;
    ry += (my - ry) * 0.2;
    ring.style.transform = `translate(${rx}px, ${ry}px) translate(-50%, -50%)`;
    requestAnimationFrame(animateCursor);
  }
  animateCursor();

  document.querySelectorAll('a, button, input, textarea').forEach((el) => {
    el.addEventListener('mouseenter', () => pointer.classList.add('hovering'));
    el.addEventListener('mouseleave', () => pointer.classList.remove('hovering'));
  });

  document.querySelectorAll('[data-cursor-label]').forEach((el) => {
    el.addEventListener('mouseenter', () => {
      cursorLabel.textContent = el.dataset.cursorLabel;
      ring.classList.add('labeled');
      pointer.classList.add('hidden-cursor');
    });
    el.addEventListener('mouseleave', () => {
      ring.classList.remove('labeled');
      pointer.classList.remove('hidden-cursor');
    });
  });
}

// ===== Scroll progress bar =====
const progressBar = document.getElementById('progress-bar');

// ===== Navbar shrink + active-link pill =====
const navLinksWrap = document.getElementById('nav-links');
const navPill = document.getElementById('nav-pill');
const navLinkEls = Array.from(document.querySelectorAll('.nav-links a'));
const sections = ['home', 'about', 'skills', 'projects', 'contact']
  .map((id) => document.getElementById(id))
  .filter(Boolean);

function movePillTo(link) {
  if (!link || !navPill) return;
  const wrapRect = navLinksWrap.getBoundingClientRect();
  const rect = link.getBoundingClientRect();
  navPill.style.width = `${rect.width}px`;
  navPill.style.transform = `translateX(${rect.left - wrapRect.left}px)`;
}

function setActiveNav(id) {
  navLinkEls.forEach((link) => {
    const active = link.dataset.nav === id;
    link.classList.toggle('active', active);
    if (active) movePillTo(link);
  });
}

const initialActive = navLinkEls.find((l) => l.classList.contains('active'));
if (initialActive) requestAnimationFrame(() => movePillTo(initialActive));

// ===== Scroll-driven updates (progress bar, navbar, active section) =====
let ticking = false;

function onScrollUpdate() {
  const scrollY = window.scrollY;
  const docHeight = document.documentElement.scrollHeight - window.innerHeight;
  const pct = docHeight > 0 ? (scrollY / docHeight) * 100 : 0;
  progressBar.style.width = `${pct}%`;

  navbar.style.top = scrollY > 20 ? '8px' : '16px';

  if (sections.length) {
    let currentId = sections[0].id;
    const probe = scrollY + window.innerHeight * 0.35;
    sections.forEach((sec) => {
      if (sec.offsetTop <= probe) currentId = sec.id;
    });
    setActiveNav(currentId);
  }

  ticking = false;
}

window.addEventListener('scroll', () => {
  if (!ticking) {
    requestAnimationFrame(onScrollUpdate);
    ticking = true;
  }
}, { passive: true });
window.addEventListener('resize', () => movePillTo(navLinkEls.find((l) => l.classList.contains('active'))));
onScrollUpdate();

// ===== Smooth anchor navigation (offset for fixed navbar) =====
document.querySelectorAll('a[href^="#"]').forEach((link) => {
  link.addEventListener('click', (e) => {
    const id = link.getAttribute('href').slice(1);
    const target = document.getElementById(id);
    if (!target) return;
    e.preventDefault();
    const y = target.getBoundingClientRect().top + window.scrollY - 84;
    window.scrollTo({ top: y, behavior: reduceMotion ? 'auto' : 'smooth' });
  });
});

// ===== Reveal-on-scroll (staggered) =====
const revealEls = document.querySelectorAll('.reveal, .reveal-line');
revealEls.forEach((el) => {
  if (!el.style.getPropertyValue('--d')) {
    const idx = Array.from(el.parentElement.children).indexOf(el);
    el.style.setProperty('--d', idx);
  }
});

const revealObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add('in-view');
      revealObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.15, rootMargin: '0px 0px -60px 0px' });

revealEls.forEach((el) => revealObserver.observe(el));

// ===== Animated stat counters =====
function animateCount(el) {
  const target = parseInt(el.dataset.count, 10) || 0;
  const duration = 1400;
  const start = performance.now();
  function tick(now) {
    const t = Math.min(1, (now - start) / duration);
    const eased = 1 - Math.pow(1 - t, 3);
    el.textContent = Math.round(eased * target);
    if (t < 1) requestAnimationFrame(tick);
  }
  requestAnimationFrame(tick);
}

const countObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      animateCount(entry.target);
      countObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.5 });

document.querySelectorAll('[data-count]').forEach((el) => countObserver.observe(el));

// ===== Skill bar fill animation =====
const barObserver = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      const fill = entry.target.dataset.fill;
      requestAnimationFrame(() => { entry.target.style.width = `${fill}%`; });
      barObserver.unobserve(entry.target);
    }
  });
}, { threshold: 0.4 });

document.querySelectorAll('.bar span[data-fill]').forEach((el) => barObserver.observe(el));

// ===== Contact form (submits to the backend) =====
const contactForm = document.querySelector('.contact-form');
if (contactForm) {
  contactForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = contactForm.querySelector('button');
    const label = btn.querySelector('span');
    const originalText = label.textContent;

    const payload = {
      name: document.getElementById('f-name').value.trim(),
      email: document.getElementById('f-email').value.trim(),
      subject: document.getElementById('f-subject').value.trim(),
      message: document.getElementById('f-message').value.trim(),
    };

    btn.disabled = true;
    label.textContent = '...';

    try {
      const res = await fetch('/api/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      if (!res.ok) throw new Error((await res.json()).error || 'Xatolik yuz berdi.');

      label.textContent = 'Yuborildi ✓';
      contactForm.reset();
    } catch (err) {
      label.textContent = "Xatolik, qayta urinib ko'ring";
      console.error(err);
    } finally {
      btn.disabled = false;
      setTimeout(() => { label.textContent = originalText; }, 2600);
    }
  });
}
