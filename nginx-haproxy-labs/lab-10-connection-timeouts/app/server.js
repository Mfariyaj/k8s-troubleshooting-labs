const http = require('http');

const PORT = 3000;
let requestCount = 0;

const server = http.createServer((req, res) => {
  requestCount++;
  const reqId = requestCount;
  const delay = req.url === '/slow' ? 5000 : (req.url === '/medium' ? 2000 : 100);

  console.log(`[${new Date().toISOString()}] Request #${reqId} ${req.url} - will take ${delay}ms`);

  // Simulate slow processing
  setTimeout(() => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      request_id: reqId,
      path: req.url,
      processing_time_ms: delay,
      timestamp: new Date().toISOString()
    }));
    console.log(`[${new Date().toISOString()}] Request #${reqId} completed`);
  }, delay);
});

// Set high max connections on the backend (the bottleneck should be Nginx)
server.maxConnections = 1000;

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Slow Backend App listening on port ${PORT}`);
  console.log('Endpoints: / (100ms), /medium (2s), /slow (5s)');
});
