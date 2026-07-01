const express = require('express');
const axios = require('axios');

const app = express();
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend:8080';

app.get('/', async (req, res) => {
  try {
    const response = await axios.get(`${BACKEND_URL}/api/data`, { timeout: 5000 });
    res.json({ frontend: 'ok', backend_data: response.data });
  } catch (error) {
    console.error(`Error connecting to backend at ${BACKEND_URL}:`, error.message);
    res.status(502).json({ 
      error: 'Cannot reach backend', 
      details: error.message,
      backend_url: BACKEND_URL 
    });
  }
});

app.get('/health', (req, res) => {
  res.json({ status: 'frontend running' });
});

app.listen(80, () => {
  console.log('Frontend running on port 80');
  console.log(`Backend URL: ${BACKEND_URL}`);
  
  // Attempt initial connection
  setTimeout(async () => {
    try {
      await axios.get(`${BACKEND_URL}/health`, { timeout: 3000 });
      console.log('✅ Backend connection successful');
    } catch (err) {
      console.error(`❌ Error: connect ECONNREFUSED ${BACKEND_URL}`);
    }
  }, 2000);
});
