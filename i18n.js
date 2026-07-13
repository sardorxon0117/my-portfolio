// Static UI-chrome strings (nav, buttons, form labels) per locale.
// Actual content (hero text, about, skills, projects...) comes from the API.
const UI_STRINGS = {
  uz: {
    nav_home: 'Bosh sahifa', nav_about: 'Men haqimda', nav_skills: "Ko'nikmalar", nav_projects: 'Loyihalar', nav_contact: 'Aloqa',
    cta_projects: "Loyihalarni ko'rish", cta_contact: "Bog'lanish",
    about_eyebrow: 'Tanishuv', about_heading: 'Men haqimda',
    skills_eyebrow: 'Texnologiyalar', skills_heading: "Ko'nikmalarim",
    projects_eyebrow: 'Ishlarim', projects_heading: 'Men qilgan ishlar', view_all_projects: "Barcha loyihalarni ko'rish →",
    search_placeholder: 'Loyihalarni qidirish...',
    cta_eyebrow: 'Keling boshlaylik', cta_title1: 'Loyihangizni birga', cta_title2: 'hayotga tatbiq etaylik', cta_contact_btn: "Bog'lanish →",
    contact_eyebrow: "Bog'lanish", contact_heading: 'Keling, gaplashamiz',
    email_label: 'Email', phone_label: 'Telefon', telegram_channel_label: 'Telegram kanal', social_label: 'Ijtimoiy tarmoqlar',
    form_name: 'Ismingiz', form_email: 'Emailingiz', form_subject: 'Mavzu', form_message: 'Xabaringiz', form_submit: 'Xabar yuborish',
    footer_rights: 'Barcha huquqlar himoyalangan.',
    view_project_btn: "Loyihani ko'rish", view_label: "Ko'rish", views_label: "Ko'rishlar", github_btn: 'GitHub', screenshots: 'Skrinshotlar', description: 'Tavsif', technologies: 'Texnologiyalar',
    reviews_heading: 'Fikrlar', reviews_empty: "Hozircha fikrlar yo'q. Birinchi bo'lib fikr qoldiring!",
    review_name_ph: 'Ismingiz', review_comment_ph: 'Fikringizni yozing...', review_submit: 'Fikr qoldirish', review_sent: 'Rahmat! Fikringiz qo\'shildi.',
    admin_reply_label: 'Muallif javobi', back_to_all: '← Barcha loyihalar', back_to_home: '← Bosh sahifaga qaytish', error_not_found: 'Loyiha topilmadi',
    social_github: 'GitHub', social_telegram: 'Telegram', social_telegram_channel: 'Telegram kanal', social_facebook: 'Facebook', social_instagram: 'Instagram',
  },
  uz_cyr: {
    nav_home: 'Бош сахифа', nav_about: 'Мен ҳақимда', nav_skills: 'Кўникмалар', nav_projects: 'Лойиҳалар', nav_contact: 'Алоқа',
    cta_projects: 'Лойиҳаларни кўриш', cta_contact: 'Боғланиш',
    about_eyebrow: 'Танишув', about_heading: 'Мен ҳақимда',
    skills_eyebrow: 'Технологиялар', skills_heading: 'Кўникмаларим',
    projects_eyebrow: 'Ишларим', projects_heading: 'Мен қилган ишлар', view_all_projects: 'Барча лойиҳаларни кўриш →',
    search_placeholder: 'Лойиҳаларни қидириш...',
    cta_eyebrow: 'Келинг бошлайлик', cta_title1: 'Лойиҳангизни бирга', cta_title2: 'ҳаётга татбиқ этайлик', cta_contact_btn: 'Боғланиш →',
    contact_eyebrow: 'Боғланиш', contact_heading: 'Келинг, гаплашамиз',
    email_label: 'Email', phone_label: 'Телефон', telegram_channel_label: 'Телеграм канал', social_label: 'Ижтимоий тармоқлар',
    form_name: 'Исмингиз', form_email: 'Емайлингиз', form_subject: 'Мавзу', form_message: 'Хабарингиз', form_submit: 'Хабар юбориш',
    footer_rights: 'Барча ҳуқуқлар ҳимояланган.',
    view_project_btn: 'Лойиҳани кўриш', view_label: 'Кўриш', views_label: 'Кўришлар', github_btn: 'GitHub', screenshots: 'Скриншотлар', description: 'Тавсиф', technologies: 'Технологиялар',
    reviews_heading: 'Фикрлар', reviews_empty: "Ҳозирча фикрлар йўқ. Биринчи бўлиб фикр қолдиринг!",
    review_name_ph: 'Исмингиз', review_comment_ph: 'Фикрингизни ёзинг...', review_submit: 'Фикр қолдириш', review_sent: 'Раҳмат! Фикрингиз қўшилди.',
    admin_reply_label: 'Муаллиф жавоби', back_to_all: '← Барча лойиҳалар', back_to_home: '← Бош сахифага қайтиш', error_not_found: 'Лойиҳа топилмади',
    social_github: 'GitHub', social_telegram: 'Telegram', social_telegram_channel: 'Телеграм канал', social_facebook: 'Facebook', social_instagram: 'Instagram',
  },
  en: {
    nav_home: 'Home', nav_about: 'About', nav_skills: 'Skills', nav_projects: 'Projects', nav_contact: 'Contact',
    cta_projects: 'View projects', cta_contact: 'Contact me',
    about_eyebrow: 'Introduction', about_heading: 'About me',
    skills_eyebrow: 'Technologies', skills_heading: 'My skills',
    projects_eyebrow: 'My work', projects_heading: 'Work I have done', view_all_projects: 'View all projects →',
    search_placeholder: 'Search projects...',
    cta_eyebrow: "Let's start", cta_title1: "Let's bring your project", cta_title2: 'to life together', cta_contact_btn: 'Contact me →',
    contact_eyebrow: 'Contact', contact_heading: "Let's talk",
    email_label: 'Email', phone_label: 'Phone', telegram_channel_label: 'Telegram channel', social_label: 'Social media',
    form_name: 'Your name', form_email: 'Your email', form_subject: 'Subject', form_message: 'Your message', form_submit: 'Send message',
    footer_rights: 'All rights reserved.',
    view_project_btn: 'View project', view_label: 'View', views_label: 'Views', github_btn: 'GitHub', screenshots: 'Screenshots', description: 'Description', technologies: 'Technologies',
    reviews_heading: 'Reviews', reviews_empty: 'No reviews yet. Be the first to leave one!',
    review_name_ph: 'Your name', review_comment_ph: 'Write your feedback...', review_submit: 'Submit review', review_sent: 'Thanks! Your review was added.',
    admin_reply_label: "Author's reply", back_to_all: '← All projects', back_to_home: '← Back to home', error_not_found: 'Project not found',
    social_github: 'GitHub', social_telegram: 'Telegram', social_telegram_channel: 'Telegram channel', social_facebook: 'Facebook', social_instagram: 'Instagram',
  },
  ru: {
    nav_home: 'Главная', nav_about: 'Обо мне', nav_skills: 'Навыки', nav_projects: 'Проекты', nav_contact: 'Контакты',
    cta_projects: 'Смотреть проекты', cta_contact: 'Связаться',
    about_eyebrow: 'Знакомство', about_heading: 'Обо мне',
    skills_eyebrow: 'Технологии', skills_heading: 'Мои навыки',
    projects_eyebrow: 'Мои работы', projects_heading: 'Мои выполненные работы', view_all_projects: 'Все проекты →',
    search_placeholder: 'Поиск проектов...',
    cta_eyebrow: 'Давайте начнём', cta_title1: 'Воплотим ваш проект', cta_title2: 'в жизнь вместе', cta_contact_btn: 'Связаться →',
    contact_eyebrow: 'Контакты', contact_heading: 'Давайте пообщаемся',
    email_label: 'Email', phone_label: 'Телефон', telegram_channel_label: 'Telegram канал', social_label: 'Социальные сети',
    form_name: 'Ваше имя', form_email: 'Ваш email', form_subject: 'Тема', form_message: 'Ваше сообщение', form_submit: 'Отправить',
    footer_rights: 'Все права защищены.',
    view_project_btn: 'Смотреть проект', view_label: 'Смотреть', views_label: 'Просмотры', github_btn: 'GitHub', screenshots: 'Скриншоты', description: 'Описание', technologies: 'Технологии',
    reviews_heading: 'Отзывы', reviews_empty: 'Пока нет отзывов. Оставьте первый!',
    review_name_ph: 'Ваше имя', review_comment_ph: 'Напишите отзыв...', review_submit: 'Оставить отзыв', review_sent: 'Спасибо! Ваш отзыв добавлен.',
    admin_reply_label: 'Ответ автора', back_to_all: '← Все проекты', back_to_home: '← Вернуться на главную', error_not_found: 'Проект не найден',
    social_github: 'GitHub', social_telegram: 'Telegram', social_telegram_channel: 'Telegram канал', social_facebook: 'Facebook', social_instagram: 'Instagram',
  },
};

function getLocale() {
  return localStorage.getItem('site_locale') || 'uz';
}
function setLocale(loc) {
  localStorage.setItem('site_locale', loc);
}
function t(key) {
  const loc = getLocale();
  return (UI_STRINGS[loc] && UI_STRINGS[loc][key]) || UI_STRINGS.uz[key] || key;
}

// ===== Shared across all public pages =====
function applyStaticStrings() {
  document.querySelectorAll('[data-i18n]').forEach((el) => { el.textContent = t(el.dataset.i18n); });
  document.querySelectorAll('[data-i18n-nav]').forEach((el) => { el.textContent = t(`nav_${el.dataset.i18nNav}`); });
  document.querySelectorAll('[data-i18n-ph]').forEach((el) => { el.placeholder = t(el.dataset.i18nPh); });
}
const LOCALE_SHORT = { uz: 'UZ', uz_cyr: 'ЎЗ', en: 'EN', ru: 'RU' };

function updateLangSwitchUI() {
  const current = document.getElementById('lang-current');
  if (current) current.textContent = LOCALE_SHORT[getLocale()] || getLocale().toUpperCase();
  document.querySelectorAll('.lang-panel button').forEach((btn) => {
    btn.classList.toggle('active', btn.dataset.locale === getLocale());
  });
}

function wireLangSwitch(onChange) {
  const wrap = document.getElementById('lang-switch');
  const trigger = document.getElementById('lang-trigger');
  if (!wrap || !trigger) return;

  trigger.addEventListener('click', (e) => {
    e.stopPropagation();
    wrap.classList.toggle('open');
  });
  document.addEventListener('click', () => wrap.classList.remove('open'));
  wrap.querySelector('.lang-panel')?.addEventListener('click', (e) => e.stopPropagation());

  document.querySelectorAll('.lang-panel button').forEach((btn) => {
    btn.addEventListener('click', () => {
      wrap.classList.remove('open');
      if (btn.dataset.locale === getLocale()) return;
      setLocale(btn.dataset.locale);
      updateLangSwitchUI();
      applyStaticStrings();
      document.documentElement.lang = btn.dataset.locale.startsWith('uz') ? 'uz' : btn.dataset.locale;
      if (onChange) onChange();
    });
  });
}
