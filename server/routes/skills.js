const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');
const { deleteImage } = require('../s3');

const router = express.Router();

router.get('/skills', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM skills ORDER BY order_index ASC, id ASC');
  res.json(rows);
});

router.post('/admin/skills', requireAuth, async (req, res) => {
  const { image_url, percent, name, order_index } = req.body || {};
  const { rows } = await pool.query(
    'INSERT INTO skills (image_url, percent, name, order_index) VALUES ($1, $2, $3, $4) RETURNING *',
    [image_url || null, percent || 0, name || {}, order_index ?? 0]
  );
  res.status(201).json(rows[0]);
});

router.put('/admin/skills/reorder', requireAuth, async (req, res) => {
  const { order } = req.body || {};
  if (!Array.isArray(order)) return res.status(400).json({ error: 'order array required' });

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of order) {
      await client.query('UPDATE skills SET order_index = $1 WHERE id = $2', [item.order_index, item.id]);
    }
    await client.query('COMMIT');
    res.json({ ok: true });
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
});

router.put('/admin/skills/:id', requireAuth, async (req, res) => {
  const { image_url, percent, name } = req.body || {};

  const { rows: existingRows } = await pool.query('SELECT image_url FROM skills WHERE id = $1', [req.params.id]);
  if (!existingRows[0]) return res.status(404).json({ error: 'Not found' });

  if (image_url && existingRows[0].image_url && image_url !== existingRows[0].image_url) {
    await deleteImage(existingRows[0].image_url);
  }

  const { rows } = await pool.query(
    'UPDATE skills SET image_url = $1, percent = $2, name = $3 WHERE id = $4 RETURNING *',
    [image_url ?? existingRows[0].image_url, percent || 0, name || {}, req.params.id]
  );
  res.json(rows[0]);
});

router.delete('/admin/skills/:id', requireAuth, async (req, res) => {
  const { rows } = await pool.query('SELECT image_url FROM skills WHERE id = $1', [req.params.id]);
  if (rows[0]?.image_url) await deleteImage(rows[0].image_url);
  await pool.query('DELETE FROM skills WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

module.exports = router;
