#!/bin/bash
echo "🚀 Deploying Lab 02: SSL Certificate Errors..."

# Generate the mismatched certificates first
bash generate-certs.sh

docker-compose up -d --build
echo ""
echo "✅ Lab deployed! Test with:"
echo "   curl -vk https://localhost:8443/"
echo "   openssl s_client -connect localhost:8443"
echo ""
echo "📋 Expected behavior: SSL handshake failure (cert/key mismatch)"
