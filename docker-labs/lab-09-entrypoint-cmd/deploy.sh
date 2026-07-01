#!/bin/bash
# Lab 09 - Entrypoint vs CMD Confusion
echo "🔄 Lab 09: Testing container argument passing..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

docker build -t lab09-tool . 2>&1 | tail -3

echo ""
echo "Test 1: Running with '--version' argument:"
echo "  \$ docker run lab09-tool --version"
docker run --rm lab09-tool --version

echo ""
echo "Test 2: Running with 'list --format json' arguments:"
echo "  \$ docker run lab09-tool list --format json"
docker run --rm lab09-tool list --format json

echo ""
echo "Test 3: Running with 'help' argument:"
echo "  \$ docker run lab09-tool help"
docker run --rm lab09-tool help

echo ""
echo "❌ All commands gave the same output! Arguments are ignored! (Expected)"
echo "🔍 Your task: Fix the Dockerfile so runtime arguments work correctly"
echo "💡 Hint: Look at how ENTRYPOINT is defined - shell form vs exec form"
