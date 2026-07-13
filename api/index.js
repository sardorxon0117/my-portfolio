// Vercel serverless entry point: all /api/* requests are rewritten here
// (see vercel.json) and handled by the same Express app used for local dev.
module.exports = require('../server/server.js');
