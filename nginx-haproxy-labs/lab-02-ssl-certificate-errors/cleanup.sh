#!/bin/bash
echo "🧹 Cleaning up Lab 02: SSL Certificate Errors..."
docker-compose down -v --remove-orphans
rm -rf ssl/
echo "✅ Lab 02 cleaned up."
