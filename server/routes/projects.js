const express = require('express');
const pool = require('../db');
const { requireAuth } = require('../middleware/auth');
const { deleteImage } = require('../s3');

const router = express.Router();

router.get('/projects', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM projects ORDER BY order_index ASC, id ASC');
  res.json(rows);
});

router.get('/projects/featured', async (req, res) => {
  const { rows } = await pool.query(
    'SELECT * FROM projects WHERE featured = true ORDER BY featured_order ASC, id ASC'
  );
  res.json(rows);
});

router.get('/projects/:slug', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM projects WHERE slug = $1', [req.params.slug]);
  if (!rows[0]) return res.status(404).json({ error: 'Loyiha topilmadi' });
  res.json(rows[0]);
});

router.post('/projects/:slug/view', async (req, res) => {
  const { rows } = await pool.query(
    'UPDATE projects SET views_count = views_count + 1 WHERE slug = $1 RETURNING views_count',
    [req.params.slug]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Loyiha topilmadi' });
  res.json({ views_count: rows[0].views_count });
});

router.post('/admin/projects', requireAuth, async (req, res) => {
  const p = req.body || {};
  try {
    const { rows } = await pool.query(
      `INSERT INTO projects (slug, image_url, logo_url, screenshots, video_url, video_poster_url, rating, link, github_link, tags, title, tagline, description, category, author_name, order_index)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16) RETURNING *`,
      [p.slug, p.image_url || null, p.logo_url || null, JSON.stringify(p.screenshots || []), p.video_url || null, p.video_poster_url || null, p.rating || 5.0, p.link || '#', p.github_link || '#',
       JSON.stringify(p.tags || []), p.title || {}, p.tagline || {}, p.description || {}, p.category || {}, p.author_name || 'Sardorxon Valiyev', p.order_index ?? 0]
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    if (err.code === '23505') return res.status(409).json({ error: 'Bu slug allaqachon mavjud.' });
    throw err;
  }
});

router.put('/admin/projects/:id', requireAuth, async (req, res) => {
  const p = req.body || {};
  const { rows: existingRows } = await pool.query('SELECT image_url, logo_url, screenshots, video_url, video_poster_url FROM projects WHERE id = $1', [req.params.id]);
  if (!existingRows[0]) return res.status(404).json({ error: 'Not found' });
  const existing = existingRows[0];

  if (p.image_url && existing.image_url && p.image_url !== existing.image_url) {
    await deleteImage(existing.image_url);
  }
  if (p.logo_url && existing.logo_url && p.logo_url !== existing.logo_url) {
    await deleteImage(existing.logo_url);
  }
  if (p.screenshots) {
    const removed = (existing.screenshots || []).filter((url) => !p.screenshots.includes(url));
    await Promise.all(removed.map((url) => deleteImage(url)));
  }
  if (p.video_url !== undefined && existing.video_url && p.video_url !== existing.video_url) {
    await deleteImage(existing.video_url);
  }
  if (p.video_poster_url && existing.video_poster_url && p.video_poster_url !== existing.video_poster_url) {
    await deleteImage(existing.video_poster_url);
  }

  const { rows } = await pool.query(
    `UPDATE projects SET slug=$1, image_url=$2, logo_url=$3, screenshots=$4, video_url=$5, video_poster_url=$6, rating=$7, link=$8, github_link=$9, tags=$10,
       title=$11, tagline=$12, description=$13, category=$14, author_name=$15
     WHERE id = $16 RETURNING *`,
    [p.slug, p.image_url ?? existing.image_url, p.logo_url ?? existing.logo_url, JSON.stringify(p.screenshots ?? existing.screenshots ?? []),
     p.video_url !== undefined ? p.video_url : existing.video_url, p.video_poster_url !== undefined ? p.video_poster_url : existing.video_poster_url,
     p.rating || 5.0, p.link || '#', p.github_link || '#',
     JSON.stringify(p.tags || []), p.title || {}, p.tagline || {}, p.description || {}, p.category || {}, p.author_name || 'Sardorxon Valiyev', req.params.id]
  );
  res.json(rows[0]);
});

router.put('/admin/projects/:id/feature', requireAuth, async (req, res) => {
  const { featured, featured_order } = req.body || {};
  const { rows } = await pool.query(
    'UPDATE projects SET featured = $1, featured_order = $2 WHERE id = $3 RETURNING *',
    [!!featured, featured_order ?? 0, req.params.id]
  );
  if (!rows[0]) return res.status(404).json({ error: 'Not found' });
  res.json(rows[0]);
});

router.put('/admin/projects/reorder', requireAuth, async (req, res) => {
  const { order } = req.body || {}; // [{id, order_index}] or [{id, featured_order}]
  if (!Array.isArray(order)) return res.status(400).json({ error: 'order array required' });

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const item of order) {
      if (item.featured_order !== undefined) {
        await client.query('UPDATE projects SET featured_order = $1 WHERE id = $2', [item.featured_order, item.id]);
      } else {
        await client.query('UPDATE projects SET order_index = $1 WHERE id = $2', [item.order_index, item.id]);
      }
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

router.delete('/admin/projects/:id', requireAuth, async (req, res) => {
  const { rows } = await pool.query('SELECT image_url, logo_url, screenshots, video_url, video_poster_url FROM projects WHERE id = $1', [req.params.id]);
  if (rows[0]) {
    const { image_url, logo_url, screenshots, video_url, video_poster_url } = rows[0];
    const urls = [image_url, logo_url, video_url, video_poster_url, ...(screenshots || [])].filter(Boolean);
    await Promise.all(urls.map((url) => deleteImage(url)));
  }
  await pool.query('DELETE FROM projects WHERE id = $1', [req.params.id]);
  res.json({ ok: true });
});

module.exports = router;
