#!/bin/bash
# Lab 10: Deployment Gates & Rollback - Cleanup
LAB_NAME="lab-10-deployment-gates"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
