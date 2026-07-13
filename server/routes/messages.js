const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

// Public: submit a contact form message
router.post('/messages', async (req, res) => {
  const { name, email, subject, message } = req.body || {};

  if (!name?.trim() || !email?.trim() || !subject?.trim() || !message?.trim()) {
    return res.status(400).json({ error: "Barcha maydonlar to'ldirilishi shart." });
  }
  if ([name, email, subject].some((v) => v.length > 200) || message.length > 4000) {
    return res.status(400).json({ error: 'Matn juda uzun.' });
  }

  const { rows } = await pool.query(
    'INSERT INTO messages (name, email, subject, message) VALUES ($1, $2, $3, $4) RETURNING *',
    [name.trim(), email.trim(), subject.trim(), message.trim()]
  );

  res.status(201).json(rows[0]);
});

// Admin: list all messages, newest first
router.get('/admin/messages', requireAuth, async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM messages ORDER BY created_at DESC');
  res.json(rows);
});

router.put('/admin/messages/:id/read', requireAuth, async (req, res) => {
  const { rows } = await pool.query(
    'UPDATE messages SET is_read = true WHERE id = $1 RETURNING *',
    [req.params.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Not found' });
  res.json(rows[0]);
});

router.delete('/admin/messages/:id', requireAuth, async (req, res) => {
  await pool.query('DELETE FROM messages WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

module.exports = router;
