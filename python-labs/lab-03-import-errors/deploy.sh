#!/bin/bash
# Deploy Lab 03 - Import Errors

LAB_DIR="/tmp/python-lab-03"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 03: Python Import Errors"
echo "================================"
echo ""

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

cp "$SCRIPT_DIR/broken_script.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/utils.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/config.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/requirements.txt" "$LAB_DIR/"

echo "📁 Lab files deployed to: $LAB_DIR"
echo ""
echo "🚀 Running broken script..."
echo "----------------------------"
echo ""

cd "$LAB_DIR" && python3 broken_script.py 2>&1

echo ""
echo "----------------------------"
echo "❌ The script has import errors!"
echo ""
echo "📝 Your task: Fix the import errors in $LAB_DIR/"
echo "💡 Check broken_script.py, config.py, and utils.py"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
