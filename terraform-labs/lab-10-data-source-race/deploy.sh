#!/bin/bash
# Lab 10 - Data Source Race Condition
# This script sets up the broken lab environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$SCRIPT_DIR/workspace"

echo "=============================================="
echo "  Lab 10: Data Source Race Condition"
echo "=============================================="
echo ""
echo "  SCENARIO:"
echo "  A developer created an RDS instance and then used a data source"
echo "  to query that same instance's endpoint for a Lambda function's"
echo "  environment variables. The data source is evaluated at PLAN TIME"
echo "  before the resource exists, so it fails."
echo ""
echo "=============================================="

# Create workspace
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# Copy terraform files to workspace
cp "$SCRIPT_DIR/main.tf" "$WORK_DIR/"

# Create a dummy lambda.zip for the lambda function resource
echo "placeholder" > "$WORK_DIR/lambda.zip"

echo ""
echo "  📁 Lab files created in: $WORK_DIR"
echo ""
echo "  TO REPRODUCE THE ERROR:"
echo "  ─────────────────────────────────────────"
echo "  cd $WORK_DIR"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "  You will see an error like:"
echo "  'no matching RDS Instance found'"
echo "  because the data source tries to read a resource that"
echo "  doesn't exist yet during plan."
echo ""
echo "  YOUR TASK:"
echo "  ─────────────────────────────────────────"
echo "  1. Identify the data source that reads a non-existent resource"
echo "  2. Replace data source references with direct resource references"
echo "  3. Remove the unnecessary data source"
echo "  4. Ensure terraform validate passes"
echo ""
echo "  HINT: Use aws_db_instance.app_db.endpoint instead of the data source"
echo ""
