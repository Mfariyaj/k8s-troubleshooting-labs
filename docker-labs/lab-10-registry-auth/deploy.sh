#!/bin/bash
# Lab 10 - Registry Authentication Failure
echo "🔐 Lab 10: Attempting to pull from private registry..."
echo "======================================================"

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "📋 Docker Compose configuration references these private images:"
echo "  - registry.internal.company.io/myteam/api-service:v2.1.0"
echo "  - registry.internal.company.io/myteam/worker-service:v2.1.0"
echo "  - registry.internal.company.io/myteam/scheduler-service:v3.0.0-beta"

echo ""
echo "🔑 Checking for stored credentials..."
echo "  Found expired credentials in docker-config-expired.json:"
cat docker-config-expired.json 2>/dev/null

echo ""
echo "📥 Attempting to pull images..."
docker compose pull 2>&1

echo ""
echo "❌ Pull FAILED - authentication/access errors! (Expected)"
echo ""
echo "🔍 Your task: Fix the registry authentication issues"
echo "💡 Hints:"
echo "   1. Is the registry URL correct and reachable?"
echo "   2. Are the credentials valid (not expired)?"
echo "   3. Do the image tags actually exist?"
echo "   4. For this lab: consider replacing with local builds or public images"
echo ""
echo "📝 In a real scenario, you would:"
echo "   - Run 'docker login registry.internal.company.io'"
echo "   - Verify image tags exist in the registry"
echo "   - Check if credentials are expired"
echo "   - Verify network access to the registry"
