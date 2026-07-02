#!/bin/bash
# Deploy Lab 05 - Dictionary Errors

LAB_DIR="/tmp/python-lab-05"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 05: Python Dictionary Errors"
echo "====================================="
echo ""

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

cp "$SCRIPT_DIR/broken_script.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/sample_data.json" "$LAB_DIR/"

echo "📁 Lab files deployed to: $LAB_DIR"
echo ""
echo "🚀 Running broken script..."
echo "----------------------------"
echo ""

cd "$LAB_DIR" && python3 broken_script.py 2>&1

echo ""
echo "----------------------------"
echo "❌ The script has dictionary/JSON errors!"
echo ""
echo "📝 Your task: Fix the dict access bugs in $LAB_DIR/broken_script.py"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
