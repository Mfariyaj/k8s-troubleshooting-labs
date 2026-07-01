#!/bin/bash
# Lab 05 - Multi-stage Build Failure
echo "🏗️  Lab 05: Building multi-stage Docker image..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "Building image..."
docker build -t lab05-app . 2>&1

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build succeeded! Now running the container..."
    echo ""
    docker run --rm --name lab05-container lab05-app 2>&1
    
    echo ""
    echo "❌ Container crashed with 'not found' error! (Expected)"
    echo "🔍 Your task: Fix the Dockerfile so the binary runs in the final stage"
    echo "💡 Hint: The binary exists but something it NEEDS is missing"
else
    echo ""
    echo "❌ Build failed!"
fi
