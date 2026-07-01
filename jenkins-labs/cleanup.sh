#!/bin/bash
# Clean up all Jenkins troubleshooting labs
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Cleaning Up All Jenkins Labs"
echo "=========================================="
echo ""

LABS=(
    "lab-01-pipeline-syntax"
    "lab-02-agent-offline"
    "lab-03-credentials-binding"
    "lab-04-shared-library"
    "lab-05-parallel-stages"
    "lab-06-artifact-failures"
    "lab-07-docker-in-docker"
    "lab-08-webhook-triggers"
    "lab-09-workspace-disk-full"
    "lab-10-matrix-build"
)

for lab in "${LABS[@]}"; do
    echo "-------------------------------------------"
    echo "Cleaning: $lab"
    echo "-------------------------------------------"
    if [ -f "$SCRIPT_DIR/$lab/cleanup.sh" ]; then
        bash "$SCRIPT_DIR/$lab/cleanup.sh"
        echo ""
    else
        echo "  [WARN] cleanup.sh not found for $lab"
    fi
done

# Remove any dangling Jenkins resources
echo "Removing any remaining Jenkins containers..."
docker ps -a --filter "name=jenkins-lab" -q 2>/dev/null | xargs -r docker rm -f 2>/dev/null || true
docker volume ls --filter "name=jenkins-lab" -q 2>/dev/null | xargs -r docker volume rm 2>/dev/null || true
docker network ls --filter "name=jenkins-lab" -q 2>/dev/null | xargs -r docker network rm 2>/dev/null || true

echo ""
echo "=========================================="
echo "  All labs cleaned up!"
echo "=========================================="
