const http = require('http');

const PORT = 3000;

const server = http.createServer((req, res) => {
  const proto = req.headers['x-forwarded-proto'] || 'http';
  const host = req.headers['host'] || 'localhost';

  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} - Proto: ${proto}`);

  // BUG: App also forces HTTPS redirect if it thinks the connection is not HTTPS
  // Since Nginx doesn't send X-Forwarded-Proto, the app always thinks it's HTTP
  // and always redirects to HTTPS — creating an infinite loop with Nginx's redirect
  if (proto !== 'https') {
    console.log(`[REDIRECT] Redirecting to HTTPS (proto detected: ${proto})`);
    res.writeHead(301, {
      'Location': `https://${host}${req.url}`,
      'Content-Type': 'text/html'
    });
    res.end('<html><body>Redirecting to HTTPS...</body></html>');
    return;
  }

  // Normal response (only reached if X-Forwarded-Proto is 'https')
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'ok',
    message: 'Application is running securely!',
    protocol: proto,
    timestamp: new Date().toISOString()
  }));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`App listening on port ${PORT}`);
  console.log('⚠️  This app redirects to HTTPS if X-Forwarded-Proto is not "https"');
});
