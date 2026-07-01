#!/bin/bash
set -e

echo "============================================"
echo "  Lab 11: JCasC YAML Merge Failures"
echo "  Difficulty: ⭐⭐⭐⭐⭐ Expert"
echo "============================================"
echo ""
echo "Scenario: Jenkins Configuration as Code fails to load after plugin upgrade."
echo "Multiple YAML files have broken anchors, wrong schema, and type mismatches."
echo ""
echo "Starting Jenkins with broken JCasC configuration..."
echo ""

cd "$(dirname "$0")"

# Stop any existing instance
docker compose down -v 2>/dev/null || true

# Start Jenkins
docker compose up -d

echo ""
echo "Waiting for Jenkins to start..."
sleep 15

echo ""
echo "============================================"
echo "  Lab deployed! Jenkins is starting up."
echo "============================================"
echo ""
echo "Check the CasC errors:"
echo "  docker logs jenkins-casc-lab 2>&1 | grep -i 'casc\|error\|severe'"
echo ""
echo "Jenkins UI: http://localhost:8080"
echo ""
echo "Your task: Fix ALL JCasC YAML files so configuration loads correctly."
echo "  - Fix cross-file anchor references"
echo "  - Correct schema changes from plugin upgrade"
echo "  - Fix credential type names"
echo "  - Resolve YAML merge key issues"
echo ""
echo "Files to fix:"
echo "  - casc/jenkins.yaml"
echo "  - casc/credentials.yaml"
echo "  - casc/security.yaml"
echo ""
