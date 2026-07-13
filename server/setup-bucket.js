require('dotenv').config();
const {
  S3Client,
  PutPublicAccessBlockCommand,
  PutBucketPolicyCommand,
  GetBucketPolicyCommand,
} = require('@aws-sdk/client-s3');

const BUCKET = process.env.S3_BUCKET_NAME;
const s3 = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  },
});

async function main() {
  console.log(`Configuring public read access for bucket "${BUCKET}"...`);

  try {
    await s3.send(new PutPublicAccessBlockCommand({
      Bucket: BUCKET,
      PublicAccessBlockConfiguration: {
        BlockPublicAcls: false,
        IgnorePublicAcls: false,
        BlockPublicPolicy: false,
        RestrictPublicBuckets: false,
      },
    }));
    console.log('✔ Public access block disabled.');
  } catch (err) {
    console.error('✘ Failed to update public access block:', err.message);
    console.error('  You may need to disable "Block Public Access" manually in the AWS S3 console for this bucket.');
  }

  const policy = {
    Version: '2012-10-17',
    Statement: [
      {
        Sid: 'PublicReadGetObject',
        Effect: 'Allow',
        Principal: '*',
        Action: 's3:GetObject',
        Resource: `arn:aws:s3:::${BUCKET}/*`,
      },
    ],
  };

  try {
    await s3.send(new PutBucketPolicyCommand({
      Bucket: BUCKET,
      Policy: JSON.stringify(policy),
    }));
    console.log('✔ Public read bucket policy applied.');
  } catch (err) {
    console.error('✘ Failed to apply bucket policy:', err.message);
    console.error('  You may need to add this policy manually in the AWS S3 console (Permissions -> Bucket Policy):');
    console.error(JSON.stringify(policy, null, 2));
    process.exit(1);
  }

  try {
    const { Policy } = await s3.send(new GetBucketPolicyCommand({ Bucket: BUCKET }));
    console.log('Current bucket policy:', Policy);
  } catch (err) {
    console.error('Could not verify policy:', err.message);
  }

  console.log('Done. Uploaded images should now be publicly viewable.');
}

main();
