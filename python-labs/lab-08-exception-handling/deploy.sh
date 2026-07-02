#!/bin/bash
# Deploy Lab 08 - Exception Handling

LAB_DIR="/tmp/python-lab-08"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 08: Python Exception Handling Errors"
echo "============================================="
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
echo "❌ The script has exception handling problems!"
echo ""
echo "📝 Your task: Fix the error handling in $LAB_DIR/broken_script.py"
echo "💡 Some errors are silent — the script runs but produces wrong results"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
