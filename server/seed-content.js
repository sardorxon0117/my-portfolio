const pool = require('./db');

// Seeds the DB with the content that currently lives hardcoded in the static
// HTML, translated into the 4 locales, so the admin panel starts populated
// instead of empty. Safe to re-run (upserts).
const LOCALES = ['uz', 'uz_cyr', 'en', 'ru'];

const siteContent = {
  hero: {
    uz: { eyebrow: 'Salom, men', name: 'Sardorxon Valiyev', role: 'Frontend Dasturchi', text: "Zamonaviy, tez va chiroyli veb-saytlar yarataman. Har bir loyihada puxtalik va foydalanuvchi tajribasiga alohida e'tibor beraman." },
    uz_cyr: { eyebrow: 'Салом, мен', name: 'Сардорхон Валиев', role: 'Фронтенд Дастурчи', text: 'Замонавий, тез ва чиройли веб-сайтлар яратаман. Ҳар бир лойиҳада пухталик ва фойдаланувчи тажрибасига алоҳида эътибор бераман.' },
    en: { eyebrow: "Hi, I'm", name: 'Sardorxon Valiyev', role: 'Frontend Developer', text: 'I build modern, fast and beautiful websites. I pay close attention to craftsmanship and user experience in every project.' },
    ru: { eyebrow: 'Привет, я', name: 'Сардорхон Валиев', role: 'Frontend Разработчик', text: 'Я создаю современные, быстрые и красивые веб-сайты. В каждом проекте уделяю особое внимание качеству и удобству пользователей.' },
  },
  about: {
    uz: { paragraph1: 'Men veb-dasturlash sohasida ijodiy va puxta yechimlar yaratishga qiziqadigan dasturchiman. HTML, CSS, JavaScript va zamonaviy freymvorklar bilan ishlayman, foydalanuvchi tajribasi va dizaynga katta e\'tibor qarataman.', paragraph2: 'Har bir loyihada aniqlik, tezlik va estetikani birlashtirishga harakat qilaman. Yangi texnologiyalarni o\'rganish va ularni amaliyotda qo\'llashni yaxshi ko\'raman.' },
    uz_cyr: { paragraph1: 'Мен веб-дастурлаш соҳасида ижодий ва пухта ечимлар яратишга қизиқадиган дастурчиман. HTML, CSS, JavaScript ва замонавий фреймворклар билан ишлайман, фойдаланувчи тажрибаси ва дизайнга катта эътибор қаратаман.', paragraph2: 'Ҳар бир лойиҳада аниқлик, тезлик ва эстетикани бирлаштиришга ҳаракат қиламан. Янги технологияларни ўрганиш ва уларни амалиётда қўллашни яхши кўраман.' },
    en: { paragraph1: "I'm a developer passionate about crafting creative, polished solutions for the web. I work with HTML, CSS, JavaScript and modern frameworks, with close attention to UX and design.", paragraph2: 'In every project I aim to combine precision, speed and aesthetics. I love learning new technologies and putting them into practice.' },
    ru: { paragraph1: 'Я разработчик, увлечённый созданием креативных и качественных веб-решений. Работаю с HTML, CSS, JavaScript и современными фреймворками, уделяя большое внимание UX и дизайну.', paragraph2: 'В каждом проекте я стремлюсь сочетать точность, скорость и эстетику. Люблю изучать новые технологии и применять их на практике.' },
    photo_url: null,
  },
  contact: {
    email: 'sardorxonvvaliyev006@gmail.com',
    phone: '+998 90 000 00 00',
    address: {
      uz: "O'zbekiston",
      uz_cyr: 'Ўзбекистон',
      en: 'Uzbekistan',
      ru: 'Узбекистан',
    },
  },
  marquee: {
    uz: ['Frontend Dasturchi', 'UI/UX Dizayn', 'Creative Developer', 'Ishga tayyorman'],
    uz_cyr: ['Фронтенд Дастурчи', 'UI/UX Дизайн', 'Креатив Девелопер', 'Ишга тайёрман'],
    en: ['Frontend Developer', 'UI/UX Design', 'Creative Developer', 'Available for work'],
    ru: ['Frontend Разработчик', 'UI/UX Дизайн', 'Креативный Разработчик', 'Готов к работе'],
  },
};

const stats = [
  { order_index: 0, count: 20, label: { uz: 'Loyihalar', uz_cyr: 'Лойиҳалар', en: 'Projects', ru: 'Проекты' } },
  { order_index: 1, count: 2, label: { uz: 'Yil tajriba', uz_cyr: 'Йил тажриба', en: 'Years experience', ru: 'Года опыта' } },
  { order_index: 2, count: 15, label: { uz: 'Mamnun mijozlar', uz_cyr: 'Мамнун мижозлар', en: 'Happy clients', ru: 'Довольных клиентов' } },
];

const skills = [
  { order_index: 0, image_url: null, percent: 95, name: { uz: 'HTML & CSS', uz_cyr: 'HTML & CSS', en: 'HTML & CSS', ru: 'HTML и CSS' } },
  { order_index: 1, image_url: null, percent: 85, name: { uz: 'JavaScript', uz_cyr: 'JavaScript', en: 'JavaScript', ru: 'JavaScript' } },
  { order_index: 2, image_url: null, percent: 80, name: { uz: 'React', uz_cyr: 'React', en: 'React', ru: 'React' } },
  { order_index: 3, image_url: null, percent: 75, name: { uz: 'UI/UX Dizayn', uz_cyr: 'UI/UX Дизайн', en: 'UI/UX Design', ru: 'UI/UX Дизайн' } },
  { order_index: 4, image_url: null, percent: 70, name: { uz: 'Node.js', uz_cyr: 'Node.js', en: 'Node.js', ru: 'Node.js' } },
  { order_index: 5, image_url: null, percent: 88, name: { uz: 'Git & GitHub', uz_cyr: 'Git & GitHub', en: 'Git & GitHub', ru: 'Git и GitHub' } },
];

const projects = [
  {
    slug: 'ecommerce', order_index: 0, featured: true, featured_order: 0, image_url: null, rating: 4.9,
    link: '#', github_link: '#', tags: ['React', 'Node.js', 'MongoDB'],
    title: { uz: 'E-commerce Platforma', uz_cyr: 'E-commerce Платформа', en: 'E-commerce Platform', ru: 'E-commerce Платформа' },
    tagline: { uz: "Onlayn savdo uchun to'liq yechim", uz_cyr: 'Онлайн савдо учун тўлиқ ечим', en: 'A complete solution for online retail', ru: 'Полное решение для онлайн-торговли' },
    description: {
      uz: "Onlayn do'kon uchun to'liq funksional veb-ilova. Mahsulotlar katalogi, savat, xavfsiz to'lov tizimi va admin panel bilan jihozlangan.",
      uz_cyr: 'Онлайн дўкон учун тўлиқ функсионал веб-илова. Маҳсулотлар каталоги, сават, хавфсиз тўлов тизими ва админ панел билан жиҳозланган.',
      en: 'A fully functional web app for an online store. Equipped with a product catalog, cart, secure checkout and an admin panel.',
      ru: 'Полнофункциональное веб-приложение для интернет-магазина. Каталог товаров, корзина, безопасная оплата и админ-панель.',
    },
    category: { uz: 'Web ilova', uz_cyr: 'Веб илова', en: 'Web app', ru: 'Веб-приложение' },
  },
  {
    slug: 'analytics', order_index: 1, featured: true, featured_order: 1, image_url: null, rating: 4.8,
    link: '#', github_link: '#', tags: ['JavaScript', 'Chart.js', 'API'],
    title: { uz: 'Analitika Dashboard', uz_cyr: 'Аналитика Дашборд', en: 'Analytics Dashboard', ru: 'Аналитическая Панель' },
    tagline: { uz: "Real vaqtli ma'lumotlar tahlili", uz_cyr: 'Реал вақтли маълумотлар таҳлили', en: 'Real-time data analysis', ru: 'Анализ данных в реальном времени' },
    description: {
      uz: "Real vaqt rejimida ma'lumotlarni vizualizatsiya qiluvchi boshqaruv paneli. Grafiklar, hisobotlar va real-time API integratsiyasi.",
      uz_cyr: 'Реал вақт режимида маълумотларни визуализация қилувчи бошқарув панели. Графиклар, ҳисоботлар ва реал вақтли API интеграцияси.',
      en: 'A dashboard visualizing data in real time — charts, reports, and live API integration.',
      ru: 'Панель для визуализации данных в реальном времени — графики, отчёты и интеграция с API.',
    },
    category: { uz: 'Dashboard', uz_cyr: 'Дашборд', en: 'Dashboard', ru: 'Панель' },
  },
  {
    slug: 'mobile', order_index: 2, featured: true, featured_order: 2, image_url: null, rating: 4.9,
    link: '#', github_link: '#', tags: ['Figma', 'React Native'],
    title: { uz: 'Mobil Ilova UI', uz_cyr: 'Мобил Илова UI', en: 'Mobile App UI', ru: 'UI Мобильного Приложения' },
    tagline: { uz: 'Fitnes kuzatuv ilovasi dizayni', uz_cyr: 'Фитнес кузатув иловаси дизайни', en: 'Fitness tracking app design', ru: 'Дизайн приложения для фитнеса' },
    description: {
      uz: "Zamonaviy va intuitiv interfeysga ega fitnes kuzatuv ilovasi dizayni. Mashqlar rejasi, progress kuzatuvi va motivatsion elementlar.",
      uz_cyr: 'Замонавий ва интуитив интерфейсга эга фитнес кузатув иловаси дизайни. Машғулотлар режаси, прогресс кузатуви ва мотивацион элементлар.',
      en: 'A modern, intuitive fitness tracking app design with workout plans, progress tracking and motivational elements.',
      ru: 'Современный и интуитивный дизайн приложения для фитнеса с планами тренировок и отслеживанием прогресса.',
    },
    category: { uz: 'Mobil dizayn', uz_cyr: 'Мобил дизайн', en: 'Mobile design', ru: 'Мобильный дизайн' },
  },
  {
    slug: 'corporate', order_index: 3, featured: true, featured_order: 3, image_url: null, rating: 5.0,
    link: '#', github_link: '#', tags: ['HTML', 'CSS', 'JS'],
    title: { uz: 'Korporativ Veb-sayt', uz_cyr: 'Корпоратив Веб-сайт', en: 'Corporate Website', ru: 'Корпоративный Сайт' },
    tagline: { uz: 'Tezkor va SEO-optimallashtirilgan', uz_cyr: 'Тезкор ва SEO-оптималлаштирилган', en: 'Fast and SEO-optimized', ru: 'Быстрый и SEO-оптимизированный' },
    description: {
      uz: "Kompaniya uchun tezkor, SEO-optimallashtirilgan va responsiv veb-sayt. Yuqori Lighthouse ko'rsatkichlari va toza kod tuzilishi.",
      uz_cyr: 'Компания учун тезкор, SEO-оптималлаштирилган ва респонсив веб-сайт. Юқори Lighthouse кўрсаткичлари ва тоза код тузилиши.',
      en: 'A fast, SEO-optimized, responsive website for a company. High Lighthouse scores and clean code architecture.',
      ru: 'Быстрый, SEO-оптимизированный, адаптивный сайт для компании. Высокие показатели Lighthouse и чистая архитектура кода.',
    },
    category: { uz: 'Veb-sayt', uz_cyr: 'Веб-сайт', en: 'Website', ru: 'Веб-сайт' },
  },
];

const socialLinks = [
  { platform: 'telegram', url: '#', order_index: 0 },
  { platform: 'telegram_channel', url: '#', order_index: 1 },
  { platform: 'github', url: '#', order_index: 2 },
  { platform: 'facebook', url: '#', order_index: 3 },
  { platform: 'instagram', url: '#', order_index: 4 },
];

async function seed() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    for (const [section, data] of Object.entries(siteContent)) {
      await client.query(
        `INSERT INTO site_content (section, data) VALUES ($1, $2)
         ON CONFLICT (section) DO NOTHING`,
        [section, data]
      );
    }

    const { rows: existingStats } = await client.query('SELECT COUNT(*)::int AS n FROM stats');
    if (existingStats[0].n === 0) {
      for (const s of stats) {
        await client.query(
          'INSERT INTO stats (order_index, count, label) VALUES ($1, $2, $3)',
          [s.order_index, s.count, s.label]
        );
      }
    }

    const { rows: existingSkills } = await client.query('SELECT COUNT(*)::int AS n FROM skills');
    if (existingSkills[0].n === 0) {
      for (const s of skills) {
        await client.query(
          'INSERT INTO skills (order_index, image_url, percent, name) VALUES ($1, $2, $3, $4)',
          [s.order_index, s.image_url, s.percent, s.name]
        );
      }
    }

    const { rows: existingProjects } = await client.query('SELECT COUNT(*)::int AS n FROM projects');
    if (existingProjects[0].n === 0) {
      for (const p of projects) {
        await client.query(
          `INSERT INTO projects (slug, order_index, featured, featured_order, image_url, rating, link, github_link, tags, title, tagline, description, category)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)`,
          [p.slug, p.order_index, p.featured, p.featured_order, p.image_url, p.rating, p.link, p.github_link, JSON.stringify(p.tags), p.title, p.tagline, p.description, p.category]
        );
      }
    }

    for (const link of socialLinks) {
      await client.query(
        `INSERT INTO social_links (platform, url, order_index) VALUES ($1, $2, $3)
         ON CONFLICT (platform) DO NOTHING`,
        [link.platform, link.url, link.order_index]
      );
    }

    await client.query('COMMIT');
    console.log('Seed complete.');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
    await pool.end();
  }
}

seed().catch((err) => {
  console.error('Seeding failed:', err);
  process.exit(1);
});
