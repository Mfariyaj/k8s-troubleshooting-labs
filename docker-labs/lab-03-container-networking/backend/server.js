const express = require('express');
const { createClient } = require('redis');
const { Pool } = require('pg');

const app = express();
const PORT = 3000;

// Database connection
const pool = new Pool({
  host: process.env.DATABASE_HOST || 'database',
  port: parseInt(process.env.DATABASE_PORT || '5432'),
  user: process.env.DATABASE_USER || 'appuser',
  password: process.env.DATABASE_PASSWORD || 'secret123',
  database: process.env.DATABASE_NAME || 'myapp',
});

// Redis connection
const redisHost = process.env.REDIS_HOST || 'cache';
const redisPort = process.env.REDIS_PORT || '6379';

async function connectRedis() {
  const client = createClient({
    url: `redis://${redisHost}:${redisPort}`
  });
  client.on('error', (err) => {
    console.error(`Error: connect ECONNREFUSED ${redisHost}:${redisPort} -`, err.message);
  });
  try {
    await client.connect();
    console.log('✅ Redis connected');
  } catch (err) {
    console.error(`❌ Error: connect ECONNREFUSED ${redisHost}:${redisPort}`);
  }
  return client;
}

async function connectDB() {
  try {
    const client = await pool.connect();
    console.log('✅ Database connected');
    client.release();
  } catch (err) {
    console.error(`❌ Error: getaddrinfo ENOTFOUND ${process.env.DATABASE_HOST || 'database'}`);
    console.error(`   Details: ${err.message}`);
  }
}

app.get('/api/data', (req, res) => {
  res.json({ message: 'Backend API response', timestamp: new Date().toISOString() });
});

app.get('/health', (req, res) => {
  res.json({ status: 'backend running' });
});

app.listen(PORT, async () => {
  console.log(`Backend running on port ${PORT}`);
  
  // Attempt connections after startup
  setTimeout(async () => {
    await connectDB();
    await connectRedis();
  }, 2000);
});
