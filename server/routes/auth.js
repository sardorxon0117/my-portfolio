const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.post('/login', async (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) {
    return res.status(400).json({ error: 'Login va parol kiritilishi shart.' });
  }

  const { rows } = await pool.query('SELECT * FROM admin_users WHERE username = $1', [username]);
  const user = rows[0];
  if (!user) {
    return res.status(401).json({ error: "Login yoki parol noto'g'ri." });
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    return res.status(401).json({ error: "Login yoki parol noto'g'ri." });
  }

  const token = jwt.sign({ sub: user.id, username: user.username }, process.env.JWT_SECRET, {
    expiresIn: '7d',
  });

  res.json({ token, username: user.username });
});

router.get('/me', requireAuth, (req, res) => {
  res.json({ username: req.admin.username });
});

module.exports = router;
