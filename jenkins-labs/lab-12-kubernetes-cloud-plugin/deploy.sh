#!/bin/bash
set -e

echo "============================================"
echo "  Lab 12: Kubernetes Cloud Plugin Failures"
echo "  Difficulty: ⭐⭐⭐⭐⭐ Expert"
echo "============================================"
echo ""
echo "Scenario: Jenkins Kubernetes plugin pod templates don't work."
echo "Pods never schedule, JNLP can't connect back, workspace PVC fails."
echo ""

cd "$(dirname "$0")"

# Stop any existing instance
docker compose down -v 2>/dev/null || true

# Start Jenkins Master
echo "Starting Jenkins master..."
docker compose up -d

echo ""
echo "Waiting for Jenkins to start..."
sleep 20

echo ""
echo "============================================"
echo "  Lab deployed!"
echo "============================================"
echo ""
echo "Jenkins UI: http://localhost:8080"
echo ""
echo "Your task: Fix the Kubernetes plugin configuration so agent pods"
echo "can be scheduled and connect back to the Jenkins master."
echo ""
echo "Issues to investigate:"
echo "  1. Pod template service name mismatch"
echo "  2. JNLP port connectivity"
echo "  3. Container naming conflicts"
echo "  4. RBAC and ServiceAccount issues"
echo "  5. PVC mount failures"
echo ""
echo "Files to examine:"
echo "  - Jenkinsfile (inline pod template)"
echo "  - pod-template.yaml (system pod template)"
echo "  - docker-compose.yml (Jenkins master config)"
echo ""
