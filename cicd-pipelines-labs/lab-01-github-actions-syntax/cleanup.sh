#!/bin/bash
# Lab 01: GitHub Actions Syntax Errors - Cleanup
LAB_NAME="lab-01-github-actions-syntax"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
