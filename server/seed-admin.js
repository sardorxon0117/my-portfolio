require('dotenv').config();
const bcrypt = require('bcryptjs');
const pool = require('./db');

async function seedAdmin() {
  const username = process.env.ADMIN_USERNAME;
  const password = process.env.ADMIN_PASSWORD;

  if (!username || !password) {
    console.error('ADMIN_USERNAME and ADMIN_PASSWORD must be set in .env before running this script.');
    process.exit(1);
  }

  const hash = await bcrypt.hash(password, 12);

  await pool.query(
    `INSERT INTO admin_users (username, password_hash) VALUES ($1, $2)
     ON CONFLICT (username) DO UPDATE SET password_hash = EXCLUDED.password_hash`,
    [username, hash]
  );

  console.log(`Admin user "${username}" created/updated successfully.`);
  await pool.end();
}

seedAdmin().catch((err) => {
  console.error('Failed to seed admin:', err);
  process.exit(1);
});
