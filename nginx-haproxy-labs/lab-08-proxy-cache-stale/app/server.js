const http = require('http');

const PORT = 3000;

// Simulated user database
const users = {
  'user-alice': { name: 'Alice Johnson', email: 'alice@company.com', role: 'admin', salary: '$150,000' },
  'user-bob': { name: 'Bob Smith', email: 'bob@company.com', role: 'developer', salary: '$120,000' },
  'user-carol': { name: 'Carol Williams', email: 'carol@company.com', role: 'manager', salary: '$135,000' }
};

const server = http.createServer((req, res) => {
  // Extract user from cookie
  const cookieHeader = req.headers['cookie'] || '';
  const sessionMatch = cookieHeader.match(/session=([^;]+)/);
  const userId = sessionMatch ? sessionMatch[1] : 'anonymous';

  const userData = users[userId] || { name: 'Anonymous', email: 'none', role: 'guest', salary: 'N/A' };

  console.log(`[${new Date().toISOString()}] Request from user: ${userId} (${userData.name})`);

  const response = {
    profile: userData,
    session: userId,
    message: `Welcome back, ${userData.name}!`,
    sensitive_data: true,
    warning: 'This response contains user-specific data that should NOT be cached globally',
    timestamp: new Date().toISOString()
  };

  // The app correctly sets Cache-Control and Vary headers
  // But Nginx is configured to ignore them!
  res.writeHead(200, {
    'Content-Type': 'application/json',
    'Cache-Control': 'private, no-cache',
    'Vary': 'Cookie'
  });
  res.end(JSON.stringify(response, null, 2));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`User Profile Server listening on port ${PORT}`);
  console.log('⚠️  This app returns user-specific data - caching without user context is dangerous!');
});
