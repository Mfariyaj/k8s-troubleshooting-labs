#!/bin/bash
# Lab 02: Secrets Exposed in Logs - Cleanup
LAB_NAME="lab-02-secrets-exposed"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
