#!/bin/bash
# Deploy Lab 04 - File Handling

LAB_DIR="/tmp/python-lab-04"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 04: Python File Handling Errors"
echo "======================================="
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
echo "❌ The script has file handling errors!"
echo ""
echo "📝 Your task: Fix the file I/O bugs in $LAB_DIR/broken_script.py"
echo "💡 Think about: file paths, context managers, and encoding"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
