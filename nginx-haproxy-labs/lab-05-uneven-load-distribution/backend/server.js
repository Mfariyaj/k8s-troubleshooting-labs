const http = require('http');

const PORT = 3000;
const SERVER_ID = process.env.SERVER_ID || 'unknown';

let requestCount = 0;

const server = http.createServer((req, res) => {
  requestCount++;
  const response = {
    server_id: SERVER_ID,
    request_number: requestCount,
    timestamp: new Date().toISOString(),
    client_ip: req.headers['x-real-ip'] || req.socket.remoteAddress
  };

  console.log(`[${SERVER_ID}] Request #${requestCount} from ${response.client_ip}`);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(response));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`[${SERVER_ID}] Backend listening on port ${PORT}`);
});
