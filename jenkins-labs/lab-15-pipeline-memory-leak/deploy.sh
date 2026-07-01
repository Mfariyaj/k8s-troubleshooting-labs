#!/bin/bash
set -e

echo "============================================"
echo "  Lab 15: Pipeline Memory Leak"
echo "  Difficulty: ⭐⭐⭐⭐⭐ Expert"
echo "============================================"
echo ""
echo "Scenario: Long-running pipeline accumulates memory until Jenkins"
echo "master is OOM-killed. Groovy closures holding references, large"
echo "strings in variables, CPS transform issues causing serialization bloat."
echo ""

cd "$(dirname "$0")"

# Stop any existing instance
docker compose down -v 2>/dev/null || true

# Build and start
echo "Building Jenkins image with low memory limits..."
docker compose build --no-cache

echo "Starting Jenkins with 256MB heap (intentionally low)..."
docker compose up -d

echo ""
echo "Waiting for Jenkins to start..."
sleep 25

echo ""
echo "============================================"
echo "  Lab deployed!"
echo "============================================"
echo ""
echo "Jenkins UI: http://localhost:8080"
echo ""
echo "Configuration:"
echo "  - Heap: 128MB min / 256MB max (-Xms128m -Xmx256m)"
echo "  - Container memory limit: 384MB"
echo "  - GC: G1GC with logging enabled"
echo "  - Heap dumps enabled on OOM"
echo ""
echo "Your task:"
echo "  1. Create a pipeline job using the provided Jenkinsfile"
echo "  2. Run it and watch memory consumption grow"
echo "  3. Identify the 4-5 memory leak patterns in the Jenkinsfile"
echo "  4. Fix the pipeline to process the same data without OOM"
echo ""
echo "Monitor memory:"
echo "  docker stats jenkins-memory-lab"
echo "  docker exec jenkins-memory-lab jcmd 1 GC.heap_info"
echo ""
