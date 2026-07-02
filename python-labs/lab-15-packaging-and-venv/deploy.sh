#!/bin/bash
# Deploy Lab 15 - Packaging and Venv

LAB_DIR="/tmp/python-lab-15"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 15: Python Packaging & Venv Errors"
echo "==========================================="
echo ""

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR/src/mytools"

cp "$SCRIPT_DIR/broken_script.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/setup.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/pyproject.toml" "$LAB_DIR/"
cp "$SCRIPT_DIR/src/mytools/__init__.py" "$LAB_DIR/src/mytools/"

echo "📁 Lab files deployed to: $LAB_DIR"
echo ""
echo "🚀 Running broken script..."
echo "----------------------------"
echo ""

cd "$LAB_DIR" && python3 broken_script.py 2>&1

echo ""
echo "----------------------------"
echo "❌ The script has import/packaging errors!"
echo ""
echo "📝 Your task: Fix the packaging issues in $LAB_DIR/"
echo "💡 Check the imports, __init__.py, setup.py, and pyproject.toml"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
