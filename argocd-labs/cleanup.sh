#!/bin/bash
# Cleanup all ArgoCD troubleshooting labs
set -e

echo "============================================"
echo "  Cleaning Up All ArgoCD Troubleshooting Labs"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LABS=(
    "lab-01-sync-failed"
    "lab-02-health-degraded"
    "lab-03-hook-failure"
    "lab-04-repo-connection"
    "lab-05-app-of-apps"
    "lab-06-resource-exclusion"
    "lab-07-sync-waves"
    "lab-08-image-updater"
    "lab-09-multi-cluster"
    "lab-10-rbac-policy"
)

for lab in "${LABS[@]}"; do
    echo "-------------------------------------------"
    echo "Cleaning: $lab"
    echo "-------------------------------------------"
    if [ -f "$SCRIPT_DIR/$lab/cleanup.sh" ]; then
        bash "$SCRIPT_DIR/$lab/cleanup.sh"
    else
        echo "  SKIP: cleanup.sh not found for $lab"
    fi
    echo ""
done

echo "============================================"
echo "  All labs cleaned up!"
echo "============================================"
