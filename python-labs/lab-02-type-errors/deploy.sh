#!/bin/bash
# Deploy Lab 02 - Type Errors

LAB_DIR="/tmp/python-lab-02"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 02: Python Type Errors"
echo "================================"
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
echo "❌ The script has type errors!"
echo ""
echo "📝 Your task: Fix the type errors in $LAB_DIR/broken_script.py"
echo "💡 Python won't automatically convert between types"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
