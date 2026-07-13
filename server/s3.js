require('dotenv').config();
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
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

// Returns a short-lived presigned PUT URL so the browser can upload the file
// bytes straight to S3 — the request body never passes through our server/
// serverless function, so there's no platform payload-size limit to hit.
async function getUploadUrl(originalName, contentType, folder = 'uploads') {
  const ext = path.extname(originalName).toLowerCase() || '.bin';
  const key = `${folder}/${Date.now()}-${crypto.randomBytes(6).toString('hex')}${ext}`;

  const uploadUrl = await getSignedUrl(
    s3,
    new PutObjectCommand({ Bucket: BUCKET, Key: key, ContentType: contentType }),
    { expiresIn: 300 }
  );
  const publicUrl = `https://${BUCKET}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`;
  return { uploadUrl, publicUrl };
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

module.exports = { getUploadUrl, deleteImage };
