#!/bin/bash
# Lab 14: Redis Setup for Fact Caching
# This script sets up Redis with intentionally problematic configuration

set -e

echo "Setting up Redis for fact caching lab..."

# Check if Redis is installed
if ! command -v redis-server &> /dev/null; then
    echo "Redis is not installed. Installing..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y redis-server redis-tools
    elif command -v yum &> /dev/null; then
        sudo yum install -y redis
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y redis
    else
        echo "Cannot determine package manager. Please install Redis manually."
        echo "Alternatively, use Docker: docker run -d -p 6379:6379 redis:latest"
        exit 1
    fi
fi

# Check if Redis is running
if ! redis-cli ping &> /dev/null 2>&1; then
    echo "Starting Redis server..."
    redis-server --daemonize yes --port 6379 --databases 16
    sleep 1
fi

# Verify Redis is operational
if redis-cli ping | grep -q "PONG"; then
    echo "✓ Redis is running on localhost:6379"
else
    echo "✗ Failed to start Redis"
    exit 1
fi

# Pre-poison the cache with stale/wrong facts
# BUG: These simulate previously cached facts that are now stale
# The empty prefix means all keys are at the root level

echo "Pre-loading poisoned fact cache..."

# Simulate fact cache poisoning - web-01's facts stored without proper namespacing
redis-cli SET "web-01" '{"ansible_hostname": "db-01", "ansible_distribution": "Ubuntu", "ansible_distribution_version": "22.04", "ansible_architecture": "x86_64", "ansible_memtotal_mb": 4096, "ansible_processor_vcpus": 2}' > /dev/null

# web-02 gets web-01's facts due to key collision
redis-cli SET "web-02" '{"ansible_hostname": "web-01", "ansible_distribution": "CentOS", "ansible_distribution_version": "8.5", "ansible_architecture": "x86_64", "ansible_memtotal_mb": 8192, "ansible_processor_vcpus": 4}' > /dev/null

# db-01 gets lb-01's facts
redis-cli SET "db-01" '{"ansible_hostname": "lb-01", "ansible_distribution": "Debian", "ansible_distribution_version": "11", "ansible_architecture": "x86_64", "ansible_memtotal_mb": 2048, "ansible_processor_vcpus": 1}' > /dev/null

# Set extremely long TTLs (24 hours) - BUG
redis-cli EXPIRE "web-01" 86400 > /dev/null
redis-cli EXPIRE "web-02" 86400 > /dev/null
redis-cli EXPIRE "db-01" 86400 > /dev/null

echo "✓ Poisoned fact cache loaded"
echo ""
echo "Cache contents:"
redis-cli KEYS '*' 2>/dev/null | head -20
echo ""
echo "Sample poisoned entry (web-01 has db-01's hostname):"
redis-cli GET "web-01" 2>/dev/null | python3 -m json.tool 2>/dev/null | head -5

echo ""
echo "Done. Redis is ready with poisoned fact cache."
