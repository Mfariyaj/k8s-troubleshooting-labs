#!/bin/bash
# Lab 02 - Layer Caching Broken
# Demonstrates how poor Dockerfile ordering destroys cache efficiency

echo "🔨 Lab 02: Building Docker image (first build)..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "⏱️  Timing first build..."
time docker build -t lab02-caching-app . 2>&1

echo ""
echo "📝 Now simulating a one-line code change..."
echo "// Build $(date +%s)" >> src/app.js

echo ""
echo "⏱️  Timing second build (after tiny code change)..."
time docker build -t lab02-caching-app . 2>&1

echo ""
echo "❌ Notice: npm install ran AGAIN despite no dependency changes!"
echo "🔍 Your task: Restructure the Dockerfile so npm install is cached"
echo "💡 Hint: What determines if a Docker layer cache is invalidated?"

# Revert the change
git checkout -- src/app.js 2>/dev/null || sed -i '$ d' src/app.js
