const express = require('express');
const app = express();
const PORT = 3000;  // App runs on port 3000
const startTime = Date.now();

app.get('/', (req, res) => {
  res.json({ message: 'API is working!', version: '2.1.0' });
});

// Health endpoint is at /health (not /healthz)
app.get('/health', (req, res) => {
  const uptime = Math.floor((Date.now() - startTime) / 1000);
  res.status(200).json({ 
    status: 'healthy', 
    uptime: uptime,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/users', (req, res) => {
  res.json([
    { id: 1, name: 'Alice', role: 'admin' },
    { id: 2, name: 'Bob', role: 'user' },
    { id: 3, name: 'Charlie', role: 'user' }
  ]);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Health endpoint: http://localhost:${PORT}/health`);
});
