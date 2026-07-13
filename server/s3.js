require('dotenv').config();
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const crypto = require('crypto');
const path = require('path');

const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

const BUCKET = process.env.S3_BUCKET_NAME;

async function uploadImage(file, folder = 'uploads') {
  const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
  const key = `${folder}/${Date.now()}-${crypto.randomBytes(6).toString('hex')}${ext}`;

  await s3.send(new PutObjectCommand({
    Bucket: BUCKET,
    Key: key,
    Body: file.buffer,
    ContentType: file.mimetype,
  }));

  return `https://${BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
}

async function deleteImage(url) {
  if (!url || !url.includes(`${BUCKET}.s3.`)) return;
  const key = url.split('.amazonaws.com/')[1];
  if (!key) return;
  try {
    await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
  } catch (err) {
    console.error('S3 delete failed:', err.message);
  }
}

module.exports = { uploadImage, deleteImage };
