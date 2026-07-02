#!/bin/bash
# Deploy Lab 11 - API Requests

LAB_DIR="/tmp/python-lab-11"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 11: Python API Request Errors"
echo "======================================"
echo ""

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

cp "$SCRIPT_DIR/broken_script.py" "$LAB_DIR/"

echo "📁 Lab files deployed to: $LAB_DIR"
echo ""
echo "🚀 Running broken script..."
echo "----------------------------"
echo ""

cd "$LAB_DIR" && python3 broken_script.py 2>&1

echo ""
echo "----------------------------"
echo "❌ The script has API handling errors!"
echo ""
echo "📝 Your task: Fix the API client in $LAB_DIR/broken_script.py"
echo "💡 Check auth headers and response handling"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
