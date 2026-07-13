const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Public: all site_content sections keyed by section name
router.get('/content', async (req, res) => {
  const { rows } = await pool.query('SELECT section, data FROM site_content');
  const result = {};
  rows.forEach((r) => { result[r.section] = r.data; });
  res.json(result);
});

// Admin: replace a section's data wholesale
router.put('/admin/content/:section', requireAuth, async (req, res) => {
  const { section } = req.params;
  const data = req.body || {};

  await pool.query(
    `INSERT INTO site_content (section, data, updated_at) VALUES ($1, $2, now())
     ON CONFLICT (section) DO UPDATE SET data = EXCLUDED.data, updated_at = now()`,
    [section, data]
  );

  res.json({ ok: true });
});

module.exports = router;
