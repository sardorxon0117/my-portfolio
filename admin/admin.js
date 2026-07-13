const API = '/api';
const LOCALES = [
  { code: 'uz', label: "UZ (lotin)" },
  { code: 'uz_cyr', label: 'ЎЗ (кирилл)' },
  { code: 'en', label: 'EN' },
  { code: 'ru', label: 'RU' },
];

let TOKEN = localStorage.getItem('admin_token') || null;

// ===== Helpers =====
function esc(str) {
  return String(str ?? '').replace(/[&<>"']/g, (c) => ({
    '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
  }[c]));
}

function toast(message, isError = false) {
  const el = document.getElementById('toast');
  document.getElementById('toast-text').textContent = message;
  document.getElementById('toast-bar').classList.add('hidden');
  el.classList.toggle('error', isError);
  el.classList.add('show');
  clearTimeout(toast._t);
  toast._t = setTimeout(() => el.classList.remove('show'), 2800);
}

// Shows a persistent toast with a live upload-progress bar. Call with percent = 100 (or let uploadImage resolve) to finish.
function toastProgress(message, percent) {
  const el = document.getElementById('toast');
  const bar = document.getElementById('toast-bar');
  document.getElementById('toast-text').textContent = `${message} ${percent}%`;
  el.classList.remove('error');
  bar.classList.remove('hidden');
  document.getElementById('toast-bar-fill').style.width = `${percent}%`;
  el.classList.add('show');
  clearTimeout(toast._t);
}

async function api(path, opts = {}) {
  const headers = Object.assign({}, opts.headers);
  if (!(opts.body instanceof FormData)) {
    headers['Content-Type'] = 'application/json';
  }
  if (TOKEN) headers['Authorization'] = `Bearer ${TOKEN}`;

  const res = await fetch(API + path, { ...opts, headers });
  let data = null;
  try { data = await res.json(); } catch (_) { /* no body */ }

  if (!res.ok) {
    throw new Error((data && data.error) || `Xatolik (${res.status})`);
  }
  return data;
}

// Uploads with a visible progress overlay. If targetEl is given (the preview/manager
// element the user is looking at), the overlay is drawn directly on top of it —
// impossible to miss, unlike a toast at the edge of the screen. The overlay switches
// to a spinner once the client->server leg hits 100%, since the server still has to
// relay the file to S3 and that leg has no progress events of its own.
function uploadImage(file, folder, targetEl) {
  const label = file.type.startsWith('video/') ? 'Video yuklanmoqda' : 'Rasm yuklanmoqda';
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('POST', `${API}/admin/upload?folder=${encodeURIComponent(folder)}`);
    if (TOKEN) xhr.setRequestHeader('Authorization', `Bearer ${TOKEN}`);

    let overlay = null, ring = null, pctEl = null;
    if (targetEl) {
      const cs = getComputedStyle(targetEl);
      if (cs.position === 'static') targetEl.style.position = 'relative';
      overlay = document.createElement('div');
      overlay.className = 'upload-progress-overlay';
      overlay.innerHTML = '<div class="upload-ring"><div class="upload-ring-inner"><span class="upload-progress-pct">0%</span></div></div>';
      targetEl.appendChild(overlay);
      ring = overlay.querySelector('.upload-ring');
      pctEl = overlay.querySelector('.upload-progress-pct');
    }

    xhr.upload.addEventListener('progress', (e) => {
      if (!e.lengthComputable) return;
      const pct = Math.round((e.loaded / e.total) * 100);
      toastProgress(label, pct);
      if (!ring) return;
      ring.style.setProperty('--pct', pct);
      pctEl.textContent = `${pct}%`;
      ring.classList.toggle('waiting-server', pct >= 100);
    });

    xhr.onload = () => {
      if (overlay) overlay.remove();
      let data = null;
      try { data = JSON.parse(xhr.responseText); } catch (_) { /* no body */ }
      if (xhr.status >= 200 && xhr.status < 300) {
        toast('Yuklandi ✓');
        resolve(data);
      } else {
        reject(new Error((data && data.error) || `Xatolik (${xhr.status})`));
      }
    };
    xhr.onerror = () => { if (overlay) overlay.remove(); reject(new Error('Tarmoq xatoligi yuz berdi.')); };

    const fd = new FormData();
    fd.append('image', file);
    xhr.send(fd);
  });
}

// Builds a language-tabbed set of inputs for a group of fields.
// fields: [{ key, label, type }] ; values: { uz: {key: val}, uz_cyr: {...}, ... }
function langTabGroup(groupId, fields, values) {
  const tabs = LOCALES.map((l, i) => `<button type="button" class="lang-tab ${i === 0 ? 'active' : ''}" data-group="${groupId}" data-lang="${l.code}">${l.label}</button>`).join('');
  const panels = LOCALES.map((l, i) => `
    <div class="lang-field" data-group="${groupId}" data-lang="${l.code}" style="${i === 0 ? '' : 'display:none'}">
      ${fields.map((f) => `
        <div class="field-group" style="margin-bottom:10px;">
          <label>${esc(f.label)}</label>
          ${f.type === 'textarea'
            ? `<textarea rows="3" data-key="${f.key}" data-lang="${l.code}" data-group-field="${groupId}">${esc(values?.[l.code]?.[f.key])}</textarea>`
            : `<input type="text" data-key="${f.key}" data-lang="${l.code}" data-group-field="${groupId}" value="${esc(values?.[l.code]?.[f.key])}">`}
        </div>
      `).join('')}
    </div>
  `).join('');

  return `<div class="lang-tabs">${tabs}</div><div class="lang-panels">${panels}</div>`;
}

function wireLangTabs(root) {
  root.querySelectorAll('.lang-tab').forEach((btn) => {
    btn.addEventListener('click', () => {
      const group = btn.dataset.group;
      root.querySelectorAll(`.lang-tab[data-group="${group}"]`).forEach((b) => b.classList.toggle('active', b === btn));
      root.querySelectorAll(`.lang-field[data-group="${group}"]`).forEach((p) => {
        p.style.display = p.dataset.lang === btn.dataset.lang ? '' : 'none';
      });
    });
  });
}

function readLangTabGroup(root, groupId) {
  const result = {};
  LOCALES.forEach((l) => { result[l.code] = {}; });
  root.querySelectorAll(`[data-group-field="${groupId}"]`).forEach((el) => {
    result[el.dataset.lang][el.dataset.key] = el.value;
  });
  return result;
}

// ===== Auth =====
function showLogin() {
  document.getElementById('login-screen').classList.remove('hidden');
  document.getElementById('dashboard').classList.add('hidden');
}
function showDashboard() {
  document.getElementById('login-screen').classList.add('hidden');
  document.getElementById('dashboard').classList.remove('hidden');
  switchTab('content');
  refreshMessagesBadge();
}

async function refreshMessagesBadge() {
  try {
    const messages = await api('/admin/messages');
    const unread = messages.filter((m) => !m.is_read).length;
    const badge = document.getElementById('messages-badge');
    badge.textContent = unread;
    badge.classList.toggle('hidden', unread === 0);
  } catch (_) { /* ignore */ }
}

document.getElementById('login-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const username = document.getElementById('login-username').value.trim();
  const password = document.getElementById('login-password').value;
  const errorEl = document.getElementById('login-error');
  errorEl.textContent = '';
  try {
    const data = await api('/auth/login', { method: 'POST', body: JSON.stringify({ username, password }) });
    TOKEN = data.token;
    localStorage.setItem('admin_token', TOKEN);
    showDashboard();
  } catch (err) {
    errorEl.textContent = err.message;
  }
});

document.getElementById('logout-btn').addEventListener('click', () => {
  TOKEN = null;
  localStorage.removeItem('admin_token');
  showLogin();
});

async function checkAuth() {
  if (!TOKEN) return showLogin();
  try {
    await api('/auth/me');
    showDashboard();
  } catch (_) {
    TOKEN = null;
    localStorage.removeItem('admin_token');
    showLogin();
  }
}

// ===== Tab switching =====
const TAB_RENDERERS = {
  content: renderContentTab,
  stats: renderStatsTab,
  skills: renderSkillsTab,
  projects: renderProjectsTab,
  social: renderSocialTab,
  reviews: renderReviewsTab,
  messages: renderMessagesTab,
};

function switchTab(tab) {
  document.querySelectorAll('.sidebar-nav button').forEach((b) => b.classList.toggle('active', b.dataset.tab === tab));
  const container = document.getElementById('tab-content');
  container.innerHTML = '<p style="color:var(--text-muted)">Yuklanmoqda…</p>';
  TAB_RENDERERS[tab](container).catch((err) => {
    container.innerHTML = `<p style="color:var(--danger)">${esc(err.message)}</p>`;
  });
}

document.querySelectorAll('.sidebar-nav button').forEach((btn) => {
  btn.addEventListener('click', () => switchTab(btn.dataset.tab));
});

// ===== TAB: Asosiy kontent (hero / about / contact / marquee) =====
async function renderContentTab(container) {
  const content = await api('/content');
  const hero = content.hero || {};
  const about = content.about || {};
  const contact = content.contact || {};
  const marquee = content.marquee || {};

  container.innerHTML = `
    <div class="panel-header"><div><h2>Asosiy kontent</h2><p>Bosh sahifadagi matnlar — har bir til uchun alohida.</p></div></div>

    <div class="card">
      <h3>Hero (bosh banner)</h3>
      ${langTabGroup('hero', [
        { key: 'eyebrow', label: 'Kichik sarlavha (masalan: Salom, men)' },
        { key: 'name', label: 'Ism-familiya' },
        { key: 'role', label: "Kasb / lavozim (bir nechta bo'lsa, vergul bilan ajrating — ekranda birma-bir yozilib-o'chirib turadi)" },
        { key: 'text', label: 'Tavsif matni', type: 'textarea' },
      ], hero)}
      <button class="btn btn-primary" id="save-hero">Saqlash</button>
    </div>

    <div class="card">
      <h3>Men haqimda</h3>
      <div class="upload-zone" style="margin-bottom:16px;">
        <div class="upload-preview" id="about-photo-preview">${about.photo_url ? `<img src="${esc(about.photo_url)}">` : '🖼️'}</div>
        <div>
          <input type="file" id="about-photo-input" accept="image/*" style="display:none">
          <button type="button" class="btn btn-secondary btn-sm" id="about-photo-btn">Rasmni o'zgartirish</button>
        </div>
      </div>
      ${langTabGroup('about', [
        { key: 'paragraph1', label: '1-paragraf', type: 'textarea' },
        { key: 'paragraph2', label: '2-paragraf', type: 'textarea' },
      ], about)}
      <button class="btn btn-primary" id="save-about">Saqlash</button>
    </div>

    <div class="card">
      <h3>Bog'lanish ma'lumotlari</h3>
      <div class="field-row">
        <div class="field-group"><label>Email</label><input type="text" id="contact-email" value="${esc(contact.email)}"></div>
        <div class="field-group"><label>Telefon</label><input type="text" id="contact-phone" value="${esc(contact.phone)}"></div>
      </div>
      <button class="btn btn-primary" id="save-contact">Saqlash</button>
    </div>

    <div class="card">
      <h3>Marquee lenta (o'tib turadigan matnlar)</h3>
      <p style="color:var(--text-muted);font-size:0.85rem;margin-bottom:14px;">Har bir tilda ro'yxatni vergul bilan ajratib yozing.</p>
      ${langTabGroup('marquee', [{ key: 'items', label: 'Iboralar (vergul bilan)' }],
        Object.fromEntries(LOCALES.map((l) => [l.code, { items: (marquee[l.code] || []).join(', ') }])))}
      <button class="btn btn-primary" id="save-marquee">Saqlash</button>
    </div>
  `;

  wireLangTabs(container);

  let pendingAboutPhoto = about.photo_url || null;
  document.getElementById('about-photo-btn').addEventListener('click', () => document.getElementById('about-photo-input').click());
  document.getElementById('about-photo-input').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    try {
      const { url } = await uploadImage(file, 'about', document.getElementById('about-photo-preview'));
      pendingAboutPhoto = url;
      document.getElementById('about-photo-preview').innerHTML = `<img src="${esc(url)}">`;
      toast("Rasm yuklandi. Saqlash tugmasini bosing.");
    } catch (err) {
      toast(err.message, true);
    }
  });

  document.getElementById('save-hero').addEventListener('click', async () => {
    try {
      await api('/admin/content/hero', { method: 'PUT', body: JSON.stringify(readLangTabGroup(container, 'hero')) });
      toast('Hero saqlandi.');
    } catch (err) { toast(err.message, true); }
  });

  document.getElementById('save-about').addEventListener('click', async () => {
    try {
      const data = readLangTabGroup(container, 'about');
      data.photo_url = pendingAboutPhoto;
      await api('/admin/content/about', { method: 'PUT', body: JSON.stringify(data) });
      toast("Men haqimda saqlandi.");
    } catch (err) { toast(err.message, true); }
  });

  document.getElementById('save-contact').addEventListener('click', async () => {
    try {
      const data = {
        email: document.getElementById('contact-email').value.trim(),
        phone: document.getElementById('contact-phone').value.trim(),
      };
      await api('/admin/content/contact', { method: 'PUT', body: JSON.stringify(data) });
      toast("Bog'lanish ma'lumotlari saqlandi.");
    } catch (err) { toast(err.message, true); }
  });

  document.getElementById('save-marquee').addEventListener('click', async () => {
    try {
      const raw = readLangTabGroup(container, 'marquee');
      const data = {};
      LOCALES.forEach((l) => {
        data[l.code] = (raw[l.code].items || '').split(',').map((s) => s.trim()).filter(Boolean);
      });
      await api('/admin/content/marquee', { method: 'PUT', body: JSON.stringify(data) });
      toast('Marquee saqlandi.');
    } catch (err) { toast(err.message, true); }
  });
}

// ===== TAB: Statistika =====
async function renderStatsTab(container) {
  const stats = await api('/stats');

  container.innerHTML = `
    <div class="panel-header"><div><h2>Statistika</h2><p>"Men haqimda" bo'limidagi raqamlar (20+, 2+, 15+...).</p></div>
    <button class="btn btn-primary" id="add-stat">+ Qo'shish</button></div>
    <div id="stats-list"></div>
  `;

  const list = document.getElementById('stats-list');
  stats.forEach((s) => list.appendChild(statCard(s)));

  document.getElementById('add-stat').addEventListener('click', () => {
    list.appendChild(statCard({ id: null, count: 0, label: {} }, true));
  });

  function statCard(stat, isNew = false) {
    const div = document.createElement('div');
    div.className = 'card';
    div.innerHTML = `
      <div class="field-row">
        <div class="field-group" style="max-width:120px;"><label>Raqam</label><input type="number" class="stat-count" value="${stat.count}"></div>
      </div>
      ${langTabGroup(`stat-${stat.id || 'new'}-${Math.random()}`, [{ key: 'label', label: 'Yorliq matni' }],
        Object.fromEntries(LOCALES.map((l) => [l.code, { label: stat.label?.[l.code] }])))}
      <div style="display:flex;gap:10px;margin-top:10px;">
        <button class="btn btn-primary btn-sm save-stat">Saqlash</button>
        ${!isNew ? '<button class="btn btn-danger btn-sm del-stat">O\'chirish</button>' : ''}
      </div>
    `;
    wireLangTabs(div);
    const groupId = div.querySelector('.lang-tab').dataset.group;

    div.querySelector('.save-stat').addEventListener('click', async () => {
      const label = {};
      const raw = readLangTabGroup(div, groupId);
      LOCALES.forEach((l) => { label[l.code] = raw[l.code].label || ''; });
      const count = parseInt(div.querySelector('.stat-count').value, 10) || 0;
      try {
        if (stat.id) {
          await api(`/admin/stats/${stat.id}`, { method: 'PUT', body: JSON.stringify({ count, label }) });
        } else {
          const created = await api('/admin/stats', { method: 'POST', body: JSON.stringify({ count, label, order_index: stats.length }) });
          stat.id = created.id;
          div.querySelector('.save-stat').insertAdjacentHTML('afterend', '<button class="btn btn-danger btn-sm del-stat">O\'chirish</button>');
          wireDelete();
        }
        toast('Saqlandi.');
      } catch (err) { toast(err.message, true); }
    });

    wireDelete();
    function wireDelete() {
      const delBtn = div.querySelector('.del-stat');
      if (!delBtn) return;
      delBtn.onclick = async () => {
        if (!confirm("Rostdan ham o'chirmoqchimisiz?")) return;
        try {
          if (stat.id) await api(`/admin/stats/${stat.id}`, { method: 'DELETE' });
          div.remove();
          toast("O'chirildi.");
        } catch (err) { toast(err.message, true); }
      };
    }

    return div;
  }
}

// ===== TAB: Ko'nikmalar =====
async function renderSkillsTab(container) {
  const skills = await api('/skills');

  container.innerHTML = `
    <div class="panel-header"><div><h2>Ko'nikmalar</h2><p>Rasm/ikon, nomi va foizi.</p></div>
    <button class="btn btn-primary" id="add-skill">+ Qo'shish</button></div>
    <div id="skills-list"></div>
  `;

  const list = document.getElementById('skills-list');
  skills.forEach((s) => list.appendChild(skillCard(s)));

  document.getElementById('add-skill').addEventListener('click', () => {
    list.appendChild(skillCard({ id: null, image_url: null, percent: 50, name: {} }, true));
  });

  function skillCard(skill, isNew = false) {
    const div = document.createElement('div');
    div.className = 'card';
    let pendingImage = skill.image_url || null;
    const groupId = `skill-${skill.id || 'new'}-${Math.random()}`;
    div.innerHTML = `
      <div class="upload-zone" style="margin-bottom:14px;">
        <div class="upload-preview skill-preview">${skill.image_url ? `<img src="${esc(skill.image_url)}">` : '🎨'}</div>
        <div>
          <input type="file" class="skill-photo-input" accept="image/*" style="display:none">
          <button type="button" class="btn btn-secondary btn-sm skill-photo-btn">Rasm tanlash</button>
        </div>
        <div class="field-group" style="max-width:120px;"><label>Foiz (%)</label><input type="number" class="skill-percent" min="0" max="100" value="${skill.percent}"></div>
      </div>
      ${langTabGroup(groupId, [{ key: 'name', label: 'Nomi' }],
        Object.fromEntries(LOCALES.map((l) => [l.code, { name: skill.name?.[l.code] }])))}
      <div style="display:flex;gap:10px;margin-top:10px;">
        <button class="btn btn-primary btn-sm save-skill">Saqlash</button>
        ${!isNew ? '<button class="btn btn-danger btn-sm del-skill">O\'chirish</button>' : ''}
      </div>
    `;
    wireLangTabs(div);

    div.querySelector('.skill-photo-btn').addEventListener('click', () => div.querySelector('.skill-photo-input').click());
    div.querySelector('.skill-photo-input').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const { url } = await uploadImage(file, 'skills', div.querySelector('.skill-preview'));
        pendingImage = url;
        div.querySelector('.skill-preview').innerHTML = `<img src="${esc(url)}">`;
      } catch (err) { toast(err.message, true); }
    });

    div.querySelector('.save-skill').addEventListener('click', async () => {
      const name = {};
      const raw = readLangTabGroup(div, groupId);
      LOCALES.forEach((l) => { name[l.code] = raw[l.code].name || ''; });
      const percent = Math.max(0, Math.min(100, parseInt(div.querySelector('.skill-percent').value, 10) || 0));
      try {
        if (skill.id) {
          await api(`/admin/skills/${skill.id}`, { method: 'PUT', body: JSON.stringify({ image_url: pendingImage, percent, name }) });
        } else {
          const created = await api('/admin/skills', { method: 'POST', body: JSON.stringify({ image_url: pendingImage, percent, name, order_index: skills.length }) });
          skill.id = created.id;
          div.querySelector('.save-skill').insertAdjacentHTML('afterend', '<button class="btn btn-danger btn-sm del-skill">O\'chirish</button>');
          wireDelete();
        }
        toast('Saqlandi.');
      } catch (err) { toast(err.message, true); }
    });

    wireDelete();
    function wireDelete() {
      const delBtn = div.querySelector('.del-skill');
      if (!delBtn) return;
      delBtn.onclick = async () => {
        if (!confirm("Rostdan ham o'chirmoqchimisiz?")) return;
        try {
          if (skill.id) await api(`/admin/skills/${skill.id}`, { method: 'DELETE' });
          div.remove();
          toast("O'chirildi.");
        } catch (err) { toast(err.message, true); }
      };
    }

    return div;
  }
}

// ===== TAB: Loyihalar =====
async function renderProjectsTab(container) {
  let allProjects = await api('/projects');

  container.innerHTML = `
    <div class="panel-header">
      <div><h2>Loyihalar</h2><p>"Bosh sahifada ko'rsatish" belgilangan loyihalar bosh sahifada chiqadi.</p></div>
      <button class="btn btn-primary" id="add-project">+ Yangi loyiha</button>
    </div>
    <input type="text" class="search-input" id="projects-search" placeholder="Loyihalarni qidirish...">
    <div class="projects-tile-grid" id="projects-tile-grid"></div>

    <div class="modal-overlay hidden" id="project-modal-overlay">
      <div class="modal-card">
        <div class="modal-header">
          <h3 id="project-modal-title">Loyiha</h3>
          <button type="button" class="modal-close" id="project-modal-close">&times;</button>
        </div>
        <div class="modal-body" id="project-modal-body"></div>
      </div>
    </div>
  `;

  const grid = document.getElementById('projects-tile-grid');
  const searchInput = document.getElementById('projects-search');
  const overlay = document.getElementById('project-modal-overlay');
  const modalBody = document.getElementById('project-modal-body');
  const modalTitle = document.getElementById('project-modal-title');

  function closeModal() {
    overlay.classList.add('hidden');
    modalBody.innerHTML = '';
  }
  document.getElementById('project-modal-close').addEventListener('click', closeModal);
  overlay.addEventListener('click', (e) => { if (e.target === overlay) closeModal(); });

  function renderGrid() {
    const term = searchInput.value.trim().toLowerCase();
    const filtered = allProjects.filter((p) => {
      if (!term) return true;
      const titles = Object.values(p.title || {}).join(' ').toLowerCase();
      return p.slug.toLowerCase().includes(term) || titles.includes(term);
    });
    grid.innerHTML = '';
    if (!filtered.length) {
      grid.innerHTML = '<p style="color:var(--text-muted);grid-column:1/-1;">Hech narsa topilmadi.</p>';
      return;
    }
    filtered.forEach((p) => grid.appendChild(projectTile(p)));
  }
  searchInput.addEventListener('input', renderGrid);

  document.getElementById('add-project').addEventListener('click', () => {
    openModal({
      id: null, slug: '', image_url: null, logo_url: null, screenshots: [], video_url: null, rating: 5.0, link: '#', github_link: '#',
      tags: [], title: {}, tagline: {}, description: {}, category: {}, featured: false, featured_order: 0, author_name: 'Sardorxon Valiyev',
    }, true);
  });

  function projectTile(p) {
    const div = document.createElement('div');
    div.className = 'project-tile';
    const title = p.title?.uz || p.title?.en || p.slug;
    div.innerHTML = `
      <div class="project-tile-img">${p.image_url ? `<img src="${esc(p.image_url)}">` : '🖼️'}</div>
      <div class="project-tile-info">
        <strong>${esc(title)}</strong>
        <span>${esc(p.slug)}${p.featured ? ' · ⭐ bosh sahifada' : ''}</span>
      </div>
      <div class="project-tile-actions">
        <button class="btn btn-secondary btn-sm edit-tile-btn">Tahrirlash</button>
        <button class="btn btn-danger btn-sm del-tile-btn">O'chirish</button>
      </div>
    `;
    div.querySelector('.edit-tile-btn').addEventListener('click', () => openModal(p, false));
    div.querySelector('.del-tile-btn').addEventListener('click', async () => {
      if (!confirm("Loyihani rostdan ham o'chirmoqchimisiz?")) return;
      try {
        await api(`/admin/projects/${p.id}`, { method: 'DELETE' });
        allProjects = allProjects.filter((x) => x.id !== p.id);
        renderGrid();
        toast("O'chirildi.");
      } catch (err) { toast(err.message, true); }
    });
    return div;
  }

  function openModal(project, isNew) {
    modalTitle.textContent = isNew ? 'Yangi loyiha' : 'Loyihani tahrirlash';
    let pendingImage = project.image_url || null;
    let pendingLogo = project.logo_url || null;
    let pendingScreenshots = [...(project.screenshots || [])];
    let pendingVideo = project.video_url || null;
    let pendingVideoPoster = project.video_poster_url || null;
    const groupId = `project-modal-${Math.random()}`;

    modalBody.innerHTML = `
      <div class="field-row" style="margin-bottom:16px;">
        <div class="upload-zone">
          <div class="upload-preview" id="modal-project-preview">${project.image_url ? `<img src="${esc(project.image_url)}">` : '🖼️'}</div>
          <div>
            <input type="file" id="modal-project-photo-input" accept="image/*" style="display:none">
            <button type="button" class="btn btn-secondary btn-sm" id="modal-project-photo-btn">Banner (ro'yxatlarda)</button>
          </div>
        </div>
        <div class="upload-zone">
          <div class="upload-preview" id="modal-project-logo-preview">${project.logo_url ? `<img src="${esc(project.logo_url)}">` : '🏷️'}</div>
          <div>
            <input type="file" id="modal-project-logo-input" accept="image/*" style="display:none">
            <button type="button" class="btn btn-secondary btn-sm" id="modal-project-logo-btn">Logo (ichki sahifada)</button>
          </div>
        </div>
      </div>
      <div class="field-row">
        <div class="field-group"><label>Slug (URL uchun, masalan: ecommerce)</label><input type="text" id="modal-project-slug" value="${esc(project.slug)}"></div>
        <div class="field-group" style="max-width:100px;"><label>Reyting</label><input type="number" step="0.1" min="1" max="5" id="modal-project-rating" value="${project.rating}"></div>
      </div>
      <div class="field-row">
        <div class="field-group"><label>Loyiha havolasi</label><input type="text" id="modal-project-link" value="${esc(project.link)}"></div>
        <div class="field-group"><label>GitHub havolasi</label><input type="text" id="modal-project-github" value="${esc(project.github_link)}"></div>
      </div>
      <div class="field-group" style="margin-bottom:16px;">
        <label>Muallif (loyiha sahifasida ko'rsatiladi)</label>
        <input type="text" id="modal-project-author" value="${esc(project.author_name || 'Sardorxon Valiyev')}">
      </div>
      <div class="field-group" style="margin-bottom:16px;">
        <label>Texnologiyalar (vergul bilan)</label>
        <input type="text" id="modal-project-tags" value="${esc((project.tags || []).join(', '))}">
      </div>

      <div class="field-group" style="margin-bottom:16px;">
        <label>Skrinshotlar</label>
        <div class="screenshots-manager" id="modal-screenshots-manager"></div>
        <input type="file" id="modal-screenshot-input" accept="image/*" style="display:none">
        <button type="button" class="btn btn-secondary btn-sm" id="modal-add-screenshot-btn" style="margin-top:10px;">+ Rasm qo'shish</button>
      </div>

      <div class="field-group" style="margin-bottom:16px;">
        <label>Video (ixtiyoriy)</label>
        <div class="video-manager" id="modal-video-manager"></div>
        <input type="file" id="modal-video-input" accept="video/*" style="display:none">
      </div>

      <div class="upload-zone" style="margin-bottom:16px;">
        <div class="upload-preview" id="modal-video-poster-preview">${project.video_poster_url ? `<img src="${esc(project.video_poster_url)}">` : '🖼️'}</div>
        <div>
          <input type="file" id="modal-video-poster-input" accept="image/*" style="display:none">
          <button type="button" class="btn btn-secondary btn-sm" id="modal-video-poster-btn">Video uchun banner (ixtiyoriy)</button>
        </div>
      </div>

      ${langTabGroup(groupId, [
        { key: 'title', label: 'Nomi' },
        { key: 'tagline', label: 'Qisqa tavsif' },
        { key: 'category', label: 'Kategoriya' },
        { key: 'description', label: "To'liq tavsif", type: 'textarea' },
      ], Object.fromEntries(LOCALES.map((l) => [l.code, {
        title: project.title?.[l.code], tagline: project.tagline?.[l.code],
        category: project.category?.[l.code], description: project.description?.[l.code],
      }])))}

      <div class="checkbox-row" style="margin:14px 0;">
        <input type="checkbox" id="modal-project-featured" ${project.featured ? 'checked' : ''}>
        <label style="text-transform:none;font-size:0.88rem;">Bosh sahifada ko'rsatish</label>
        <input type="number" id="modal-project-featured-order" placeholder="tartib" value="${project.featured_order || 0}" style="width:70px;padding:6px 8px;border-radius:8px;border:1px solid var(--border);margin-left:8px;">
      </div>

      <div style="display:flex;gap:10px;">
        <button class="btn btn-primary" id="modal-save-project">Saqlash</button>
        <button class="btn btn-secondary" id="modal-cancel-project">Bekor qilish</button>
      </div>
    `;

    wireLangTabs(modalBody);
    overlay.classList.remove('hidden');

    function renderScreenshots() {
      const mgr = document.getElementById('modal-screenshots-manager');
      mgr.innerHTML = pendingScreenshots.map((url, i) => `
        <div class="screenshot-thumb">
          <img src="${esc(url)}">
          <button type="button" class="remove-screenshot-btn" data-i="${i}">&times;</button>
        </div>
      `).join('') || '<p style="color:var(--text-muted);font-size:0.82rem;">Hali rasm qo\'shilmagan.</p>';
      mgr.querySelectorAll('.remove-screenshot-btn').forEach((btn) => {
        btn.addEventListener('click', () => {
          pendingScreenshots.splice(parseInt(btn.dataset.i, 10), 1);
          renderScreenshots();
        });
      });
    }
    renderScreenshots();

    function renderVideo() {
      const mgr = document.getElementById('modal-video-manager');
      if (pendingVideo) {
        mgr.innerHTML = `<div class="video-thumb"><video src="${esc(pendingVideo)}" muted></video><button type="button" class="remove-video-btn">&times;</button></div>`;
        mgr.querySelector('.remove-video-btn').addEventListener('click', () => { pendingVideo = null; renderVideo(); });
      } else {
        mgr.innerHTML = `<button type="button" class="btn btn-secondary btn-sm" id="modal-add-video-btn">+ Video qo'shish</button>`;
        mgr.querySelector('#modal-add-video-btn').addEventListener('click', () => document.getElementById('modal-video-input').click());
      }
    }
    renderVideo();

    document.getElementById('modal-project-photo-btn').addEventListener('click', () => document.getElementById('modal-project-photo-input').click());
    document.getElementById('modal-project-photo-input').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const { url } = await uploadImage(file, 'projects', document.getElementById('modal-project-preview'));
        pendingImage = url;
        document.getElementById('modal-project-preview').innerHTML = `<img src="${esc(url)}">`;
      } catch (err) { toast(err.message, true); }
    });

    document.getElementById('modal-project-logo-btn').addEventListener('click', () => document.getElementById('modal-project-logo-input').click());
    document.getElementById('modal-project-logo-input').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const { url } = await uploadImage(file, 'logos', document.getElementById('modal-project-logo-preview'));
        pendingLogo = url;
        document.getElementById('modal-project-logo-preview').innerHTML = `<img src="${esc(url)}">`;
      } catch (err) { toast(err.message, true); }
    });

    document.getElementById('modal-add-screenshot-btn').addEventListener('click', () => document.getElementById('modal-screenshot-input').click());
    document.getElementById('modal-screenshot-input').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const { url } = await uploadImage(file, 'screenshots', document.getElementById('modal-screenshots-manager'));
        pendingScreenshots.push(url);
        renderScreenshots();
      } catch (err) { toast(err.message, true); }
      e.target.value = '';
    });

    document.getElementById('modal-video-input').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      const MAX_MB = 150;
      if (file.size > MAX_MB * 1024 * 1024) {
        toast(`Video hajmi juda katta (maksimal ${MAX_MB}MB). Tanlangan fayl: ${(file.size / 1024 / 1024).toFixed(1)}MB`, true);
        e.target.value = '';
        return;
      }
      try {
        const { url } = await uploadImage(file, 'videos', document.getElementById('modal-video-manager'));
        pendingVideo = url;
        renderVideo();
      } catch (err) { toast(err.message, true); }
      e.target.value = '';
    });

    document.getElementById('modal-video-poster-btn').addEventListener('click', () => document.getElementById('modal-video-poster-input').click());
    document.getElementById('modal-video-poster-input').addEventListener('change', async (e) => {
      const file = e.target.files[0];
      if (!file) return;
      try {
        const { url } = await uploadImage(file, 'posters', document.getElementById('modal-video-poster-preview'));
        pendingVideoPoster = url;
        document.getElementById('modal-video-poster-preview').innerHTML = `<img src="${esc(url)}">`;
      } catch (err) { toast(err.message, true); }
    });

    document.getElementById('modal-cancel-project').addEventListener('click', closeModal);

    document.getElementById('modal-save-project').addEventListener('click', async () => {
      const raw = readLangTabGroup(modalBody, groupId);
      const title = {}, tagline = {}, category = {}, description = {};
      LOCALES.forEach((l) => {
        title[l.code] = raw[l.code].title || '';
        tagline[l.code] = raw[l.code].tagline || '';
        category[l.code] = raw[l.code].category || '';
        description[l.code] = raw[l.code].description || '';
      });
      const payload = {
        slug: document.getElementById('modal-project-slug').value.trim(),
        rating: parseFloat(document.getElementById('modal-project-rating').value) || 5.0,
        link: document.getElementById('modal-project-link').value.trim() || '#',
        github_link: document.getElementById('modal-project-github').value.trim() || '#',
        author_name: document.getElementById('modal-project-author').value.trim() || 'Sardorxon Valiyev',
        tags: document.getElementById('modal-project-tags').value.split(',').map((s) => s.trim()).filter(Boolean),
        image_url: pendingImage,
        logo_url: pendingLogo,
        screenshots: pendingScreenshots,
        video_url: pendingVideo,
        video_poster_url: pendingVideoPoster,
        title, tagline, category, description,
      };
      if (!payload.slug) { toast('Slug kiritilishi shart.', true); return; }

      try {
        let id = project.id;
        let saved;
        if (id) {
          saved = await api(`/admin/projects/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
        } else {
          saved = await api('/admin/projects', { method: 'POST', body: JSON.stringify(payload) });
          id = saved.id;
        }
        const featured = document.getElementById('modal-project-featured').checked;
        const featured_order = parseInt(document.getElementById('modal-project-featured-order').value, 10) || 0;
        saved = await api(`/admin/projects/${id}/feature`, { method: 'PUT', body: JSON.stringify({ featured, featured_order }) });

        if (isNew) {
          allProjects.push(saved);
        } else {
          allProjects = allProjects.map((x) => (x.id === id ? saved : x));
        }
        renderGrid();
        closeModal();
        toast('Saqlandi.');
      } catch (err) { toast(err.message, true); }
    });
  }

  renderGrid();
}

// ===== TAB: Ijtimoiy tarmoq =====
const SOCIAL_LABELS = {
  telegram: 'Telegram',
  telegram_channel: 'Telegram kanal',
  github: 'GitHub',
  facebook: 'Facebook',
  instagram: 'Instagram',
};

async function renderSocialTab(container) {
  const links = await api('/social-links');
  const byPlatform = Object.fromEntries(links.map((l) => [l.platform, l]));

  container.innerHTML = `
    <div class="panel-header"><div><h2>Ijtimoiy tarmoqlar</h2><p>Havolalarni tahrirlang.</p></div></div>
    <div class="card">
      ${Object.entries(SOCIAL_LABELS).map(([platform, label]) => `
        <div class="field-row">
          <div class="field-group">
            <label>${esc(label)}</label>
            <input type="text" class="social-input" data-platform="${platform}" value="${esc(byPlatform[platform]?.url || '')}" placeholder="https://...">
          </div>
        </div>
      `).join('')}
      <button class="btn btn-primary" id="save-social">Barchasini saqlash</button>
    </div>
  `;

  document.getElementById('save-social').addEventListener('click', async () => {
    try {
      const inputs = container.querySelectorAll('.social-input');
      for (const input of inputs) {
        await api(`/admin/social-links/${input.dataset.platform}`, { method: 'PUT', body: JSON.stringify({ url: input.value.trim() }) });
      }
      toast('Saqlandi.');
    } catch (err) { toast(err.message, true); }
  });
}

// ===== TAB: Sharhlar =====
async function renderReviewsTab(container) {
  const reviews = await api('/admin/reviews');

  container.innerHTML = `
    <div class="panel-header"><div><h2>Sharhlar</h2><p>Foydalanuvchilar qoldirgan fikrlarga javob bering.</p></div></div>
    <div id="reviews-list"></div>
  `;

  const list = document.getElementById('reviews-list');
  if (!reviews.length) {
    list.innerHTML = '<p style="color:var(--text-muted)">Hozircha sharhlar yo\'q.</p>';
    return;
  }

  reviews.forEach((r) => {
    const card = document.createElement('div');
    card.className = 'review-card';
    const title = r.project_title?.uz || r.project_slug;
    card.innerHTML = `
      <div class="review-head">
        <div>
          <strong>${esc(r.name)}</strong>
          <div class="review-stars">${'★'.repeat(r.rating)}${'☆'.repeat(5 - r.rating)}</div>
        </div>
        <span class="review-project">${esc(title)}</span>
      </div>
      <p class="review-comment">${esc(r.comment)}</p>
      ${r.admin_reply ? `<div class="review-reply"><strong>Javobingiz:</strong> ${esc(r.admin_reply)}</div>` : ''}
      <div class="reply-form">
        <textarea placeholder="Javob yozing...">${esc(r.admin_reply || '')}</textarea>
        <button class="btn btn-primary btn-sm reply-btn">Yuborish</button>
        <button class="btn btn-danger btn-sm del-review-btn">O'chirish</button>
      </div>
    `;
    card.querySelector('.reply-btn').addEventListener('click', async () => {
      const reply = card.querySelector('textarea').value.trim();
      if (!reply) return toast("Javob matni bo'sh.", true);
      try {
        await api(`/admin/reviews/${r.id}/reply`, { method: 'PUT', body: JSON.stringify({ reply }) });
        toast('Javob yuborildi.');
        switchTab('reviews');
      } catch (err) { toast(err.message, true); }
    });
    card.querySelector('.del-review-btn').addEventListener('click', async () => {
      if (!confirm("Sharhni o'chirmoqchimisiz?")) return;
      try {
        await api(`/admin/reviews/${r.id}`, { method: 'DELETE' });
        card.remove();
      } catch (err) { toast(err.message, true); }
    });
    list.appendChild(card);
  });
}

// ===== TAB: Xabarlar (contact form submissions) =====
async function renderMessagesTab(container) {
  const messages = await api('/admin/messages');

  container.innerHTML = `
    <div class="panel-header"><div><h2>Xabarlar</h2><p>Bog'lanish formasi orqali kelgan xabarlar.</p></div></div>
    <div id="messages-list"></div>
  `;

  const list = document.getElementById('messages-list');
  if (!messages.length) {
    list.innerHTML = '<p style="color:var(--text-muted)">Hozircha xabarlar yo\'q.</p>';
    return;
  }

  const dateFmt = (d) => new Date(d).toLocaleString('uz-UZ', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' });

  messages.forEach((m) => {
    const card = document.createElement('div');
    card.className = `message-card${m.is_read ? '' : ' unread'}`;
    card.innerHTML = `
      <div class="message-head">
        <div class="message-from">
          <strong>${esc(m.name)}</strong>
          <span>${esc(m.email)}</span>
        </div>
        <span class="message-date">${dateFmt(m.created_at)}</span>
      </div>
      <div class="message-subject">${esc(m.subject)}</div>
      <div class="message-body">${esc(m.message)}</div>
      <div class="message-actions">
        <a class="btn btn-secondary btn-sm" href="mailto:${esc(m.email)}?subject=${encodeURIComponent('Re: ' + m.subject)}">Javob yozish</a>
        ${!m.is_read ? '<button class="btn btn-secondary btn-sm mark-read-btn">O\'qildi deb belgilash</button>' : ''}
        <button class="btn btn-danger btn-sm del-msg-btn">O'chirish</button>
      </div>
    `;
    const markBtn = card.querySelector('.mark-read-btn');
    if (markBtn) {
      markBtn.addEventListener('click', async () => {
        try {
          await api(`/admin/messages/${m.id}/read`, { method: 'PUT' });
          card.classList.remove('unread');
          markBtn.remove();
          refreshMessagesBadge();
        } catch (err) { toast(err.message, true); }
      });
    }
    card.querySelector('.del-msg-btn').addEventListener('click', async () => {
      if (!confirm("Xabarni o'chirmoqchimisiz?")) return;
      try {
        await api(`/admin/messages/${m.id}`, { method: 'DELETE' });
        card.remove();
        refreshMessagesBadge();
      } catch (err) { toast(err.message, true); }
    });
    list.appendChild(card);
  });
}

checkAuth();
