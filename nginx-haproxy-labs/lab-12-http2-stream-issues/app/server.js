const http = require('http');
const url = require('url');

const SLOW_RESPONSE_MS = parseInt(process.env.SLOW_RESPONSE_MS || '2000');
const PORT = 3000;

let requestCount = 0;
let activeRequests = 0;

const server = http.createServer((req, res) => {
    const parsedUrl = url.parse(req.url, true);
    const path = parsedUrl.pathname;
    
    requestCount++;
    activeRequests++;
    
    const reqId = requestCount;
    console.log(`[REQ ${reqId}] ${req.method} ${path} - Active: ${activeRequests}`);

    if (path === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            status: 'ok', 
            requests: requestCount, 
            active: activeRequests 
        }));
        activeRequests--;
        return;
    }

    if (path === '/fast') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            endpoint: 'fast', 
            reqId,
            timestamp: Date.now() 
        }));
        activeRequests--;
        return;
    }

    if (path === '/slow') {
        // Simulate slow backend processing (database query, external API call)
        setTimeout(() => {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
                endpoint: 'slow', 
                reqId,
                processingTime: SLOW_RESPONSE_MS,
                timestamp: Date.now() 
            }));
            activeRequests--;
            console.log(`[REQ ${reqId}] Completed after ${SLOW_RESPONSE_MS}ms - Active: ${activeRequests}`);
        }, SLOW_RESPONSE_MS);
        return;
    }

    if (path === '/streaming') {
        // Simulate streaming response (chunked transfer)
        res.writeHead(200, { 
            'Content-Type': 'text/event-stream',
            'Cache-Control': 'no-cache',
            'Connection': 'keep-alive'
        });
        
        let chunks = 0;
        const interval = setInterval(() => {
            chunks++;
            res.write(`data: {"chunk":${chunks},"reqId":${reqId},"time":"${new Date().toISOString()}"}\n\n`);
            
            if (chunks >= 10) {
                clearInterval(interval);
                res.end();
                activeRequests--;
                console.log(`[REQ ${reqId}] Stream complete (${chunks} chunks) - Active: ${activeRequests}`);
            }
        }, 500);
        return;
    }

    if (path === '/large-headers') {
        // Return response with many headers (simulates microservice metadata)
        const headers = { 'Content-Type': 'application/json' };
        for (let i = 0; i < 50; i++) {
            headers[`X-Custom-Meta-${i}`] = `value-${i}-${'x'.repeat(100)}`;
        }
        res.writeHead(200, headers);
        res.end(JSON.stringify({ endpoint: 'large-headers', headerCount: 50 }));
        activeRequests--;
        return;
    }

    // Default: moderate delay
    setTimeout(() => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
            endpoint: 'default', 
            path, 
            reqId,
            timestamp: Date.now() 
        }));
        activeRequests--;
    }, 500);
});

server.keepAliveTimeout = 120000;
server.headersTimeout = 125000;

server.listen(PORT, () => {
    console.log(`Backend server running on port ${PORT}`);
    console.log(`Slow response delay: ${SLOW_RESPONSE_MS}ms`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM received, shutting down...');
    server.close(() => process.exit(0));
});
