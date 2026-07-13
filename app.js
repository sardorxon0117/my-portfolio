// Public-site content loader: fetches everything from the API and renders
// the dynamic sections (hero, about, stats, skills, projects, marquee,
// contact, social links), and wires the 4-language switcher.

function esc(str) {
  return String(str ?? '').replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
}

const bindings = []; // { el, i18nMap } — updated in place on language switch
function bindText(el, i18nMap) {
  if (!el) return;
  bindings.push({ el, i18nMap: i18nMap || {} });
  el.textContent = (i18nMap && i18nMap[getLocale()]) || '';
}
function refreshBindings() {
  const loc = getLocale();
  bindings.forEach(({ el, i18nMap }) => { el.textContent = i18nMap[loc] || ''; });
}

let DATA = { content: {}, stats: [], skills: [], projects: [], social: [] };

// ===== Hero role typewriter (typing + deleting through several roles) =====
let heroRoleMap = {};
let heroTypewriterTimer = null;
function startHeroTypewriter(el) {
  if (!el) return;
  clearTimeout(heroTypewriterTimer);
  const raw = heroRoleMap[getLocale()] || heroRoleMap.uz || '';
  const phrases = raw.split(',').map((s) => s.trim()).filter(Boolean);
  if (!phrases.length) { el.textContent = ''; return; }
  if (phrases.length === 1) { el.textContent = phrases[0]; return; }

  const TYPE_MS = 75, DELETE_MS = 40, PAUSE_FULL_MS = 1700, PAUSE_EMPTY_MS = 350;
  let phraseIndex = 0, charIndex = 0, deleting = false;

  function tick() {
    const current = phrases[phraseIndex];
    if (!deleting) {
      charIndex++;
      el.textContent = current.slice(0, charIndex);
      if (charIndex === current.length) {
        heroTypewriterTimer = setTimeout(() => { deleting = true; tick(); }, PAUSE_FULL_MS);
        return;
      }
      heroTypewriterTimer = setTimeout(tick, TYPE_MS);
    } else {
      charIndex--;
      el.textContent = current.slice(0, charIndex);
      if (charIndex === 0) {
        deleting = false;
        phraseIndex = (phraseIndex + 1) % phrases.length;
        heroTypewriterTimer = setTimeout(tick, PAUSE_EMPTY_MS);
        return;
      }
      heroTypewriterTimer = setTimeout(tick, DELETE_MS);
    }
  }
  heroTypewriterTimer = setTimeout(tick, TYPE_MS);
}

async function fetchJSON(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Failed to load ${url}`);
  return res.json();
}

async function loadData() {
  const [content, stats, skills, projects, social] = await Promise.all([
    fetchJSON('/api/content'),
    fetchJSON('/api/stats'),
    fetchJSON('/api/skills'),
    fetchJSON('/api/projects/featured'),
    fetchJSON('/api/social-links'),
  ]);
  DATA = { content, stats, skills, projects, social };
}

function observeReveal(el) {
  new IntersectionObserver((entries, obs) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('in-view');
        obs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.15, rootMargin: '0px 0px -60px 0px' }).observe(el);
}

function observeCounter(el) {
  new IntersectionObserver((entries, obs) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const target = parseInt(el.dataset.count, 10) || 0;
        const start = performance.now();
        const duration = 1400;
        function tick(now) {
          const p = Math.min(1, (now - start) / duration);
          el.textContent = Math.round((1 - Math.pow(1 - p, 3)) * target);
          if (p < 1) requestAnimationFrame(tick);
        }
        requestAnimationFrame(tick);
        obs.unobserve(el);
      }
    });
  }, { threshold: 0.5 }).observe(el);
}

function observeSkillBar(el) {
  new IntersectionObserver((entries, obs) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        requestAnimationFrame(() => { entry.target.style.width = `${entry.target.dataset.fill}%`; });
        obs.unobserve(entry.target);
      }
    });
  }, { threshold: 0.4 }).observe(el);
}

// ===== Hero =====
function renderHero() {
  const hero = DATA.content.hero || {};
  const loc0 = hero[getLocale()] || hero.uz || {};
  const fullName = loc0.name || 'Sardorxon Valiyev';
  const parts = fullName.trim().split(' ');
  const last = parts.pop() || '';
  const first = parts.join(' ');

  const firstEl = document.getElementById('hero-firstname');
  const lastEl = document.getElementById('hero-lastname');
  const bgEl = document.getElementById('hero-bg-text');

  const firstMap = {}, lastMap = {};
  ['uz', 'uz_cyr', 'en', 'ru'].forEach((l) => {
    const n = (hero[l]?.name || fullName).trim().split(' ');
    const lst = n.pop() || '';
    lastMap[l] = lst;
    firstMap[l] = n.join(' ');
  });

  bindText(firstEl, firstMap);
  bindText(lastEl, lastMap);
  bindText(document.getElementById('hero-eyebrow'), Object.fromEntries(['uz', 'uz_cyr', 'en', 'ru'].map((l) => [l, hero[l]?.eyebrow])));
  bindText(document.getElementById('hero-text'), Object.fromEntries(['uz', 'uz_cyr', 'en', 'ru'].map((l) => [l, hero[l]?.text])));

  heroRoleMap = Object.fromEntries(['uz', 'uz_cyr', 'en', 'ru'].map((l) => [l, hero[l]?.role || '']));
  startHeroTypewriter(document.getElementById('hero-role'));

  bindings.push({ el: bgEl, i18nMap: Object.fromEntries(Object.entries(lastMap).map(([k, v]) => [k, (v || '').toUpperCase()])) });
  bgEl.textContent = (lastMap[getLocale()] || '').toUpperCase();
}

// ===== About =====
function renderAbout() {
  const about = DATA.content.about || {};
  bindText(document.getElementById('about-p1'), Object.fromEntries(['uz', 'uz_cyr', 'en', 'ru'].map((l) => [l, about[l]?.paragraph1])));
  bindText(document.getElementById('about-p2'), Object.fromEntries(['uz', 'uz_cyr', 'en', 'ru'].map((l) => [l, about[l]?.paragraph2])));

  const photoEl = document.getElementById('about-photo');
  if (about.photo_url) {
    photoEl.innerHTML = `<img src="${esc(about.photo_url)}" alt="" style="width:100%;height:100%;object-fit:cover;border-radius:26px;">`;
  }
}

// ===== Stats =====
function renderStats() {
  const container = document.getElementById('stats-container');
  container.innerHTML = '';
  DATA.stats.forEach((stat) => {
    const el = document.createElement('div');
    el.className = 'stat';
    const labelSpan = document.createElement('span');
    labelSpan.className = 'stat-label';
    el.innerHTML = `<span class="stat-top"><span class="stat-num" data-count="${stat.count}">0</span><span class="stat-plus">+</span></span>`;
    el.appendChild(labelSpan);
    container.appendChild(el);
    bindText(labelSpan, stat.label || {});
    observeCounter(el.querySelector('.stat-num'));
  });
}

// ===== Skills =====
function renderSkills() {
  const container = document.getElementById('skills-container');
  container.innerHTML = '';
  DATA.skills.forEach((skill) => {
    const row = document.createElement('div');
    row.className = 'skill-row reveal';
    row.innerHTML = `
      <span class="skill-icon">${skill.image_url ? `<img src="${esc(skill.image_url)}" style="width:100%;height:100%;object-fit:cover;border-radius:50%;">` : '💠'}</span>
      <div class="skill-info">
        <div class="skill-top"><h3></h3><span class="skill-percent">${skill.percent}%</span></div>
        <div class="bar"><span data-fill="${skill.percent}"></span></div>
      </div>
    `;
    container.appendChild(row);
    bindText(row.querySelector('h3'), skill.name || {});
    observeReveal(row);
    observeSkillBar(row.querySelector('.bar span'));
  });
}

// ===== Projects (featured, home page) =====
function renderProjects() {
  const container = document.getElementById('projects-container');
  container.innerHTML = '';
  DATA.projects.forEach((project, i) => {
    const row = document.createElement('a');
    row.href = `project.html?slug=${encodeURIComponent(project.slug)}`;
    row.className = 'project-row reveal';
    row.dataset.cursorLabel = "Ko'rish";
    row.innerHTML = `
      <div class="project-visual">${project.image_url ? `<img src="${esc(project.image_url)}" style="width:100%;height:100%;object-fit:cover;">` : `<span>${['🛍️', '📊', '📱', '🌐', '💡', '🚀'][i % 6]}</span>`}</div>
      <div class="project-info">
        <span class="project-num">${String(i + 1).padStart(2, '0')}</span>
        <h3></h3>
        <p></p>
        <div class="tags">${(project.tags || []).map((tag) => `<span>${esc(tag)}</span>`).join('')}</div>
      </div>
    `;
    container.appendChild(row);
    bindText(row.querySelector('h3'), project.title || {});
    bindText(row.querySelector('p'), project.tagline || {});
    observeReveal(row);
    wireCursorLabel(row);
  });
}

// ===== Marquee =====
function renderMarquee() {
  const marquee = DATA.content.marquee || {};
  const items = marquee[getLocale()] || marquee.uz || [];
  const doubled = [...items, ...items];
  const html = doubled.map((s) => `<span>${esc(s)}</span><span class="dot-sep">✦</span>`).join('');
  document.getElementById('marquee-track-1').innerHTML = html;
  document.getElementById('marquee-track-2').innerHTML = html;
}

// ===== Contact + social =====
function renderContact() {
  const contact = DATA.content.contact || {};
  const emailEl = document.getElementById('contact-email');
  const phoneEl = document.getElementById('contact-phone');
  emailEl.textContent = contact.email || '—';
  emailEl.href = contact.email ? `mailto:${contact.email}` : '#';
  phoneEl.textContent = contact.phone || '—';
  phoneEl.href = contact.phone ? `tel:${contact.phone.replace(/[^+\d]/g, '')}` : '#';

  const byPlatform = Object.fromEntries(DATA.social.map((s) => [s.platform, s.url]));
  document.querySelectorAll('[data-platform]').forEach((el) => {
    const url = byPlatform[el.dataset.platform];
    if (url) el.href = url;
  });
}

// ===== Cursor label wiring for dynamically-created elements =====
function wireCursorLabel(el) {
  if ('ontouchstart' in window) return;
  const pointer = document.getElementById('cursor-pointer');
  const ring = document.getElementById('cursor-ring');
  const label = document.getElementById('cursor-label');
  if (!pointer || !ring) return;
  el.addEventListener('mouseenter', () => {
    label.textContent = el.dataset.cursorLabel || '';
    ring.classList.add('labeled');
    pointer.classList.add('hidden-cursor');
  });
  el.addEventListener('mouseleave', () => {
    ring.classList.remove('labeled');
    pointer.classList.remove('hidden-cursor');
  });
}

async function initApp() {
  try {
    await loadData();
  } catch (err) {
    console.error('Failed to load site content:', err);
    return;
  }
  applyStaticStrings();
  updateLangSwitchUI();
  renderHero();
  renderAbout();
  renderStats();
  renderSkills();
  renderProjects();
  renderMarquee();
  renderContact();
  wireLangSwitch(() => { refreshBindings(); renderMarquee(); startHeroTypewriter(document.getElementById('hero-role')); });
}

initApp();
