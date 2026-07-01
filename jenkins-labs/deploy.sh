#!/bin/bash
# Deploy all Jenkins troubleshooting labs
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "  Deploying All Jenkins Troubleshooting Labs"
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
    echo "Deploying: $lab"
    echo "-------------------------------------------"
    if [ -f "$SCRIPT_DIR/$lab/deploy.sh" ]; then
        bash "$SCRIPT_DIR/$lab/deploy.sh"
        echo ""
    else
        echo "  [WARN] deploy.sh not found for $lab"
    fi
done

echo "=========================================="
echo "  All labs deployed!"
echo "  Access Jenkins at http://localhost:8080"
echo "=========================================="
