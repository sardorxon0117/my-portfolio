const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/social-links', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM social_links ORDER BY order_index ASC, id ASC');
  res.json(rows);
});

router.put('/admin/social-links/:platform', requireAuth, async (req, res) => {
  const { url } = req.body || {};
  const { rows } = await pool.query(
    `INSERT INTO social_links (platform, url) VALUES ($1, $2)
     ON CONFLICT (platform) DO UPDATE SET url = EXCLUDED.url
     RETURNING *`,
    [req.params.platform, url || '']
  );
  res.json(rows[0]);
});

module.exports = router;
