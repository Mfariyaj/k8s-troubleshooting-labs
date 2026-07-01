#!/bin/bash
# Lab 07: GitLab CI Stages & Dependencies - Cleanup
LAB_NAME="lab-07-gitlab-ci-stages"
WORK_DIR="/tmp/cicd-labs/${LAB_NAME}"

echo "[${LAB_NAME}] Cleaning up..."
rm -rf "${WORK_DIR}"
echo "[${LAB_NAME}] Cleaned up ${WORK_DIR}"
