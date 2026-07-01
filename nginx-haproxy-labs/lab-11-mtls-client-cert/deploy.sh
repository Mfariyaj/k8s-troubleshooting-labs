#!/bin/bash
set -e

echo "============================================"
echo " Lab 11: Mutual TLS Client Certificate Auth"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Generate certificates if they don't exist
if [ ! -d "certs" ] || [ ! -f "certs/server.crt" ]; then
    echo "[*] Generating PKI certificates..."
    chmod +x generate-certs.sh
    ./generate-certs.sh
    echo ""
fi

echo "[*] Starting mTLS environment..."
docker-compose up -d

echo ""
echo "[*] Waiting for services to start..."
sleep 3

echo ""
echo "============================================"
echo " SCENARIO: mTLS Authentication Failing"
echo "============================================"
echo ""
echo "Your internal API gateway uses mutual TLS."
echo "Clients present certificates signed by your internal PKI."
echo "After a PKI rotation, ALL client connections are being rejected."
echo ""
echo "Try connecting:"
echo "  curl --cert certs/client.crt --key certs/client.key \\"
echo "       --cacert certs/ca-bundle.crt -k https://localhost:8443/health"
echo ""
echo "Check logs:"
echo "  docker exec mtls-nginx tail -f /var/log/nginx/error.log"
echo ""
echo "Verify chain:"
echo "  openssl verify -CAfile certs/ca-bundle.crt certs/client.crt"
echo ""
echo "============================================"
