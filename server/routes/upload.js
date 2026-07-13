const express = require('express');
const { requireAuth } = require('../middleware/auth');
const { getUploadUrl } = require('../s3');

const router = express.Router();

router.post('/admin/upload-url', requireAuth, async (req, res) => {
  const { filename, contentType, folder } = req.body || {};
  if (!filename || !contentType) {
    return res.status(400).json({ error: 'filename va contentType kerak.' });
  }
  if (!contentType.startsWith('image/') && !contentType.startsWith('video/')) {
    return res.status(400).json({ error: 'Faqat rasm yoki video fayllari qabul qilinadi.' });
  }

  try {
    const { uploadUrl, publicUrl } = await getUploadUrl(filename, contentType, folder || 'uploads');
    res.json({ uploadUrl, publicUrl });
  } catch (err) {
    console.error('Presigned URL generation failed:', err);
    res.status(500).json({ error: 'Yuklash havolasini olishda xatolik yuz berdi.' });
  }
});

module.exports = router;
