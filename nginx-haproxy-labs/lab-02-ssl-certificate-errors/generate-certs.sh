#!/bin/bash
# Generate mismatched SSL certificates for Lab 02
# This creates a cert signed by one key and provides a DIFFERENT key to Nginx

SSL_DIR="./ssl"
mkdir -p "$SSL_DIR"

echo "🔐 Generating SSL certificates (intentionally mismatched)..."

# Generate the CORRECT key and certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$SSL_DIR/correct-server.key" \
  -out "$SSL_DIR/server.crt" \
  -subj "/C=US/ST=California/L=San Francisco/O=Lab02/CN=localhost" \
  2>/dev/null

# Generate a DIFFERENT key (this will be the "wrong" key)
openssl genrsa -out "$SSL_DIR/wrong-server.key" 2048 2>/dev/null

echo "✅ Certificates generated:"
echo "   - server.crt (signed with correct-server.key)"
echo "   - wrong-server.key (DIFFERENT key - will cause mismatch!)"
echo ""
echo "⚠️  The certificate and key DO NOT match!"

# Verify mismatch
CERT_MD5=$(openssl x509 -noout -modulus -in "$SSL_DIR/server.crt" | openssl md5)
KEY_MD5=$(openssl rsa -noout -modulus -in "$SSL_DIR/wrong-server.key" | openssl md5 2>/dev/null)

echo ""
echo "Certificate modulus MD5: $CERT_MD5"
echo "Key modulus MD5:         $KEY_MD5"

if [ "$CERT_MD5" != "$KEY_MD5" ]; then
  echo "❌ MISMATCH CONFIRMED - Lab is ready!"
else
  echo "⚠️  Unexpected match - regenerating..."
fi
