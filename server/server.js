require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const authRoutes = require('./routes/auth');
const contentRoutes = require('./routes/content');
const statsRoutes = require('./routes/stats');
const skillsRoutes = require('./routes/skills');
const projectsRoutes = require('./routes/projects');
const socialRoutes = require('./routes/social');
const reviewsRoutes = require('./routes/reviews');
const uploadRoutes = require('./routes/upload');
const messagesRoutes = require('./routes/messages');

const app = express();

app.use(cors());
app.use(express.json({ limit: '2mb' }));

app.use('/api/auth', authRoutes);
app.use('/api', contentRoutes);
app.use('/api', statsRoutes);
app.use('/api', skillsRoutes);
app.use('/api', projectsRoutes);
app.use('/api', socialRoutes);
app.use('/api', reviewsRoutes);
app.use('/api', uploadRoutes);
app.use('/api', messagesRoutes);

app.get('/api/health', (req, res) => res.json({ ok: true }));

// Serve the static frontend (project root) and the admin panel
const ROOT_DIR = path.join(__dirname, '..');
app.use(express.static(ROOT_DIR));
app.use('/admin', express.static(path.join(ROOT_DIR, 'admin')));

// Centralized error handler (catches thrown errors from async routes too,
// since Express 4 needs next(err) — our routes mostly let this bubble via
// the default async rejection -> Express 5 semantics aren't in play here,
// so wrap with a final safety net for anything unexpected).
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Serverda kutilmagan xatolik yuz berdi.' });
});

// On Vercel this file is required by api/index.js as a serverless function —
// there's no persistent process to listen on a port there, Vercel invokes the
// exported app per-request instead. Only bind a port for local/traditional hosting.
if (require.main === module) {
  const PORT = process.env.PORT || 4000;
  app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
  });
}

module.exports = app;
