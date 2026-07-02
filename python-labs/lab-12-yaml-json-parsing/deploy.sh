#!/bin/bash
# Deploy Lab 12 - YAML/JSON Parsing

LAB_DIR="/tmp/python-lab-12"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔬 Lab 12: Python YAML/JSON Parsing Errors"
echo "============================================"
echo ""

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

cp "$SCRIPT_DIR/broken_script.py" "$LAB_DIR/"
cp "$SCRIPT_DIR/broken_config.yaml" "$LAB_DIR/"
cp "$SCRIPT_DIR/broken_data.json" "$LAB_DIR/"

echo "📁 Lab files deployed to: $LAB_DIR"
echo ""
echo "🚀 Running broken script..."
echo "----------------------------"
echo ""

cd "$LAB_DIR" && python3 broken_script.py 2>&1

echo ""
echo "----------------------------"
echo "❌ The script has YAML/JSON parsing errors!"
echo ""
echo "📝 Your task: Fix the parser in $LAB_DIR/broken_script.py"
echo "💡 Also check the YAML and JSON files!"
echo "🔄 After fixing, run: cd $LAB_DIR && python3 broken_script.py"
