const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/stats', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM stats ORDER BY order_index ASC, id ASC');
  res.json(rows);
});

router.post('/admin/stats', requireAuth, async (req, res) => {
  const { count, label, order_index } = req.body || {};
  const { rows } = await pool.query(
    'INSERT INTO stats (count, label, order_index) VALUES ($1, $2, $3) RETURNING *',
    [count || 0, label || {}, order_index ?? 0]
  );
  res.status(201).json(rows[0]);
});

router.put('/admin/stats/reorder', requireAuth, async (req, res) => {
  const { order } = req.body || {}; // [{id, order_index}, ...]
  if (!Array.isArray(order)) return res.status(400).json({ error: 'order array required' });

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of order) {
      await client.query('UPDATE stats SET order_index = $1 WHERE id = $2', [item.order_index, item.id]);
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

router.put('/admin/stats/:id', requireAuth, async (req, res) => {
  const { count, label } = req.body || {};
  const { rows } = await pool.query(
    'UPDATE stats SET count = $1, label = $2 WHERE id = $3 RETURNING *',
    [count || 0, label || {}, req.params.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Not found' });
  res.json(rows[0]);
});

router.delete('/admin/stats/:id', requireAuth, async (req, res) => {
  await pool.query('DELETE FROM stats WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

module.exports = router;
