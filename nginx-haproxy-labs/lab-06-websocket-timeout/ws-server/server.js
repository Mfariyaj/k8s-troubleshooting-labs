const http = require('http');
const crypto = require('crypto');

const PORT = 3000;

const server = http.createServer((req, res) => {
  // Regular HTTP endpoint
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'WebSocket Echo Server',
    info: 'Connect via ws://localhost:8086/ for WebSocket',
    status: 'running'
  }));
});

// Manual WebSocket upgrade handling (no external deps)
server.on('upgrade', (req, socket, head) => {
  const key = req.headers['sec-websocket-key'];

  if (!key) {
    socket.destroy();
    return;
  }

  const acceptKey = crypto
    .createHash('sha1')
    .update(key + '258EAFA5-E914-47DA-95CA-5AB5DC085B11')
    .digest('base64');

  const responseHeaders = [
    'HTTP/1.1 101 Switching Protocols',
    'Upgrade: websocket',
    'Connection: Upgrade',
    `Sec-WebSocket-Accept: ${acceptKey}`,
    '',
    ''
  ].join('\r\n');

  socket.write(responseHeaders);
  console.log(`[${new Date().toISOString()}] WebSocket connection established`);

  // Echo back any messages received
  socket.on('data', (buffer) => {
    // Simple WebSocket frame parsing for text messages
    const firstByte = buffer[0];
    const opcode = firstByte & 0x0f;

    if (opcode === 0x08) {
      // Close frame
      console.log('Client disconnected');
      socket.end();
      return;
    }

    if (opcode === 0x09) {
      // Ping - send pong
      const pong = Buffer.from([0x8a, 0x00]);
      socket.write(pong);
      return;
    }

    if (opcode === 0x01) {
      // Text frame
      const secondByte = buffer[1];
      const masked = (secondByte & 0x80) !== 0;
      let payloadLength = secondByte & 0x7f;
      let offset = 2;

      if (payloadLength === 126) {
        payloadLength = buffer.readUInt16BE(2);
        offset = 4;
      }

      if (masked) {
        const mask = buffer.slice(offset, offset + 4);
        offset += 4;
        const payload = buffer.slice(offset, offset + payloadLength);
        for (let i = 0; i < payload.length; i++) {
          payload[i] ^= mask[i % 4];
        }
        const message = payload.toString('utf8');
        console.log(`[Echo] Received: ${message}`);

        // Send echo response
        const response = `Echo: ${message}`;
        const responseBuffer = Buffer.from(response);
        const frame = Buffer.alloc(2 + responseBuffer.length);
        frame[0] = 0x81; // Final frame, text
        frame[1] = responseBuffer.length;
        responseBuffer.copy(frame, 2);
        socket.write(frame);
      }
    }
  });

  socket.on('error', (err) => {
    console.log(`WebSocket error: ${err.message}`);
  });

  socket.on('close', () => {
    console.log('WebSocket connection closed');
  });

  // Send periodic pings to keep connection alive
  const pingInterval = setInterval(() => {
    if (socket.writable) {
      const ping = Buffer.from([0x89, 0x00]);
      socket.write(ping);
    } else {
      clearInterval(pingInterval);
    }
  }, 30000);

  socket.on('close', () => clearInterval(pingInterval));
});

server.listen(PORT, '0.0.0.0', () => {
  console.log(`WebSocket Echo Server listening on port ${PORT}`);
});
