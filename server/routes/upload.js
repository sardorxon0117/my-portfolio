const express = require('express');
const multer = require('multer');
const { requireAuth } = require('../middleware/auth');
const { uploadImage } = require('../s3');

const router = express.Router();

const MAX_FILE_SIZE = 150 * 1024 * 1024; // 150MB — comfortable for short video clips

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_FILE_SIZE },
  fileFilter: (req, file, cb) => {
    if (!file.mimetype.startsWith('image/') && !file.mimetype.startsWith('video/')) {
      return cb(new Error('Faqat rasm yoki video fayllari qabul qilinadi.'));
    }
    cb(null, true);
  },
});

router.post('/admin/upload', requireAuth, (req, res, next) => {
  upload.single('image')(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({ error: `Fayl hajmi juda katta (maksimal ${Math.round(MAX_FILE_SIZE / 1024 / 1024)}MB).` });
      }
      return res.status(400).json({ error: `Yuklashda xatolik: ${err.message}` });
    }
    if (err) {
      return res.status(400).json({ error: err.message || 'Fayl qabul qilinmadi.' });
    }
    next();
  });
}, async (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'Fayl topilmadi.' });

  try {
    const url = await uploadImage(req.file, req.query.folder || 'uploads');
    res.json({ url });
  } catch (err) {
    console.error('Upload failed:', err);
    res.status(500).json({ error: 'Yuklashda xatolik yuz berdi.' });
  }
});

module.exports = router;
