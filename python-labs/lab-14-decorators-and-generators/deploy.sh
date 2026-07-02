#!/bin/bash
# Deploy Lab 14 - Decorators and Generators

LAB_DIR="/tmp/python-lab-14"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 14: Python Decorators & Generators"
echo "==========================================="
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
echo "❌ The script has decorator/generator bugs!"
echo ""
echo "📝 Your task: Fix the decorator and generator bugs in $LAB_DIR/broken_script.py"
echo "💡 Check function metadata and generator exhaustion"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
