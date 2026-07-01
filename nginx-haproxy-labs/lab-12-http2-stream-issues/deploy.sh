#!/bin/bash
set -e

echo "============================================"
echo " Lab 12: HTTP/2 Stream Multiplexing Issues"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Generate self-signed SSL cert if not present
if [ ! -d "ssl" ]; then
    echo "[*] Generating SSL certificates..."
    mkdir -p ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout ssl/server.key -out ssl/server.crt \
        -subj "/CN=app.example.com/O=Lab12" \
        -addext "subjectAltName=DNS:app.example.com,DNS:localhost,IP:127.0.0.1"
fi

echo "[*] Building and starting services..."
docker-compose up -d --build

echo ""
echo "[*] Waiting for services to initialize..."
sleep 5

echo ""
echo "============================================"
echo " SCENARIO: HTTP/2 Connections Dropping"
echo "============================================"
echo ""
echo "Your API gateway uses HTTP/2 for frontend connections."
echo "Under load, clients experience:"
echo "  - GOAWAY frames sent prematurely"
echo "  - Stream RST errors"
echo "  - Head-of-line blocking"
echo "  - Slow requests blocking fast requests"
echo ""
echo "Test with concurrent requests:"
echo "  # Single request (works)"
echo "  curl -k --http2 https://localhost:8443/fast"
echo ""
echo "  # Concurrent requests (fails under load)"
echo "  for i in \$(seq 1 20); do"
echo "    curl -k --http2 https://localhost:8443/slow &"
echo "  done"
echo ""
echo "  # Watch for GOAWAY with nghttp"
echo "  nghttp -nv https://localhost:8443/fast"
echo ""
echo "============================================"
