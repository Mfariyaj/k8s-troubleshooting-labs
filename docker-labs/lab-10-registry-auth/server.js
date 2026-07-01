const express = require('express');
const app = express();
const PORT = 8080;

app.get('/', (req, res) => {
  res.json({ service: 'api', version: '2.1.0', status: 'running' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`API service running on port ${PORT}`);
});
