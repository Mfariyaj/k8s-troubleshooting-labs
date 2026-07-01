#!/bin/bash
# Lab 04: Artifact Passing Between Jobs - Cleanup
LAB_NAME="lab-04-artifact-passing"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
