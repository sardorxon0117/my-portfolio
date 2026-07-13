const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Public: last 5 reviews for a project + average rating / count
router.get('/projects/:slug/reviews', async (req, res) => {
  const { rows: projRows } = await pool.query('SELECT id FROM projects WHERE slug = $1', [req.params.slug]);
  if (!projRows[0]) return res.status(404).json({ error: 'Loyiha topilmadi' });
  const projectId = projRows[0].id;

  const { rows } = await pool.query(
    'SELECT * FROM reviews WHERE project_id = $1 ORDER BY created_at DESC LIMIT 5',
    [projectId]
  );
  const { rows: statsRows } = await pool.query(
    'SELECT COUNT(*)::int AS count, COALESCE(AVG(rating), 0)::float AS average FROM reviews WHERE project_id = $1',
    [projectId]
  );

  res.json({ reviews: rows, count: statsRows[0].count, average: statsRows[0].average });
});

// Public: submit a review
router.post('/projects/:slug/reviews', async (req, res) => {
  const { name, rating, comment } = req.body || {};

  if (!name || !String(name).trim() || !comment || !String(comment).trim()) {
    return res.status(400).json({ error: "Ism va fikr bo'sh bo'lmasligi kerak." });
  }
  const ratingNum = parseInt(rating, 10);
  if (!Number.isInteger(ratingNum) || ratingNum < 1 || ratingNum > 5) {
    return res.status(400).json({ error: "Baho 1 dan 5 gacha bo'lishi kerak." });
  }
  if (String(name).length > 80 || String(comment).length > 1000) {
    return res.status(400).json({ error: 'Matn juda uzun.' });
  }

  const { rows: projRows } = await pool.query('SELECT id FROM projects WHERE slug = $1', [req.params.slug]);
  if (!projRows[0]) return res.status(404).json({ error: 'Loyiha topilmadi' });

  const { rows } = await pool.query(
    'INSERT INTO reviews (project_id, name, rating, comment) VALUES ($1, $2, $3, $4) RETURNING *',
    [projRows[0].id, String(name).trim(), ratingNum, String(comment).trim()]
  );

  res.status(201).json(rows[0]);
});

// Admin: list all reviews (for a moderation dashboard)
router.get('/admin/reviews', requireAuth, async (req, res) => {
  const { rows } = await pool.query(
    `SELECT reviews.*, projects.slug AS project_slug, projects.title AS project_title
     FROM reviews JOIN projects ON projects.id = reviews.project_id
     ORDER BY reviews.created_at DESC`
  );
  res.json(rows);
});

// Admin: reply to a review
router.put('/admin/reviews/:id/reply', requireAuth, async (req, res) => {
  const { reply } = req.body || {};
  if (!reply || !String(reply).trim()) {
    return res.status(400).json({ error: "Javob matni bo'sh bo'lmasligi kerak." });
  }
  const { rows } = await pool.query(
    'UPDATE reviews SET admin_reply = $1, replied_at = now() WHERE id = $2 RETURNING *',
    [String(reply).trim(), req.params.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Not found' });
  res.json(rows[0]);
});

router.delete('/admin/reviews/:id', requireAuth, async (req, res) => {
  await pool.query('DELETE FROM reviews WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

module.exports = router;
