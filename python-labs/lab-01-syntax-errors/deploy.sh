#!/bin/bash
# Deploy Lab 01 - Syntax Errors

LAB_DIR="/tmp/python-lab-01"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 01: Python Syntax Errors"
echo "================================"
echo ""

# Create lab directory
rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

# Copy files
cp "$SCRIPT_DIR/broken_script.py" "$LAB_DIR/"

echo "📁 Lab files deployed to: $LAB_DIR"
echo ""
echo "🚀 Running broken script..."
echo "----------------------------"
echo ""

cd "$LAB_DIR" && python3 broken_script.py 2>&1

echo ""
echo "----------------------------"
echo "❌ The script has syntax errors!"
echo ""
echo "📝 Your task: Fix the syntax errors in $LAB_DIR/broken_script.py"
echo "💡 Read the error message carefully — it tells you the line number"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
