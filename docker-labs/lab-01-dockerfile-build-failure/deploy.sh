#!/bin/bash
# Lab 01 - Dockerfile Build Failure
# This will attempt to build a broken Dockerfile

echo "🔨 Lab 01: Attempting to build broken Dockerfile..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

docker build -t lab01-broken-app .

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Build FAILED! (Expected)"
    echo "🔍 Your task: Fix the Dockerfile so it builds successfully"
    echo "💡 Hint: There are 3 separate bugs to find"
fi
