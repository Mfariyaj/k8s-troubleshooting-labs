const http = require('http');

const PORT = 3000;

const server = http.createServer((req, res) => {
  const host = req.headers['host'] || 'NOT SET';
  const realIP = req.headers['x-real-ip'] || 'NOT SET';
  const forwardedFor = req.headers['x-forwarded-for'] || 'NOT SET';
  const forwardedProto = req.headers['x-forwarded-proto'] || 'NOT SET';
  const remoteAddr = req.socket.remoteAddress;

  // Application logic that depends on these headers
  const issues = [];

  if (host.includes('backend') || host.includes('app:')) {
    issues.push('Host header shows internal service name instead of client-facing hostname');
  }

  if (realIP === 'NOT SET') {
    issues.push('X-Real-IP not set - cannot determine client IP for logging/security');
  }

  if (forwardedFor === 'NOT SET') {
    issues.push('X-Forwarded-For not set - cannot track request chain');
  }

  if (forwardedProto === 'NOT SET') {
    issues.push('X-Forwarded-Proto not set - cannot determine if original request was HTTPS');
  }

  const response = {
    received_headers: {
      host: host,
      'x-real-ip': realIP,
      'x-forwarded-for': forwardedFor,
      'x-forwarded-proto': forwardedProto
    },
    connection_info: {
      remote_address: remoteAddr,
      server_port: PORT
    },
    issues: issues,
    status: issues.length === 0 ? 'HEALTHY' : 'MISCONFIGURED',
    message: issues.length > 0
      ? `⚠️  ${issues.length} proxy header issue(s) detected! Application cannot function correctly.`
      : '✅ All proxy headers are correctly configured.'
  };

  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} - Host: ${host}, Real-IP: ${realIP}`);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(response, null, 2));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend app listening on port ${PORT}`);
  console.log('This app checks for proper proxy headers from Nginx');
});
