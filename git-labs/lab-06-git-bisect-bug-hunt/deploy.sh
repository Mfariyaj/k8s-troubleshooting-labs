#!/bin/bash
# Lab 06: Git Bisect Bug Hunt
# Creates a repo with 20 commits where commit 12 introduces a bug
set -e

LAB_DIR="/tmp/git-lab-06"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Copy the test script
cp "$SCRIPT_DIR/test.sh" "$LAB_DIR/test.sh"
chmod +x "$LAB_DIR/test.sh"
git add test.sh
git commit -m "Add test script"

# Create 20 commits, with bug introduced at commit 12
for i in $(seq 1 20); do
    if [ $i -lt 12 ]; then
        # Before the bug: calculator works correctly
        cat > calculator.py <<EOF
#!/usr/bin/env python3
"""Simple calculator module - build $i"""

def add(a, b):
    """Add two numbers."""
    return a + b

def subtract(a, b):
    """Subtract b from a."""
    return a - b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b

def divide(a, b):
    """Divide a by b."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def calculate_total(items):
    """Calculate total price with tax."""
    subtotal = sum(item['price'] * item['quantity'] for item in items)
    tax = subtotal * 0.1
    return subtotal + tax

BUILD = $i
EOF
    elif [ $i -eq 12 ]; then
        # THE BUG: wrong tax calculation (multiplies by 10 instead of 0.1)
        cat > calculator.py <<EOF
#!/usr/bin/env python3
"""Simple calculator module - build $i"""

def add(a, b):
    """Add two numbers."""
    return a + b

def subtract(a, b):
    """Subtract b from a."""
    return a - b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b

def divide(a, b):
    """Divide a by b."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def calculate_total(items):
    """Calculate total price with tax."""
    subtotal = sum(item['price'] * item['quantity'] for item in items)
    tax = subtotal * 10
    return subtotal + tax

BUILD = $i
EOF
    else
        # After the bug: bug persists, more features added
        cat > calculator.py <<EOF
#!/usr/bin/env python3
"""Simple calculator module - build $i"""

def add(a, b):
    """Add two numbers."""
    return a + b

def subtract(a, b):
    """Subtract b from a."""
    return a - b

def multiply(a, b):
    """Multiply two numbers."""
    return a * b

def divide(a, b):
    """Divide a by b."""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b

def calculate_total(items):
    """Calculate total price with tax."""
    subtotal = sum(item['price'] * item['quantity'] for item in items)
    tax = subtotal * 10
    return subtotal + tax

def discount(total, percent):
    """Apply discount percentage."""
    return total * (1 - percent / 100)

BUILD = $i
EOF
    fi

    git add calculator.py
    git commit -m "build $i: $([ $i -eq 12 ] && echo 'refactored tax calculation' || echo "feature update $i")"
done

echo ""
echo "============================================="
echo "🔧 Lab 06: Git Bisect Bug Hunt"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  The calculator.py module has a bug in calculate_total()."
echo "  The tax calculation is wrong — it should multiply by 0.1"
echo "  (10% tax) but somewhere in the last 20 commits, someone"
echo "  changed it to multiply by 10 (1000% tax!)."
echo ""
echo "  Build 1 is known-good. Build 20 (current) is broken."
echo "  Use git bisect to find exactly which commit introduced the bug."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Use 'git bisect' with the test.sh script to find the"
echo "  exact commit that introduced the bug."
echo ""
echo "TEST:"
echo "  ./test.sh exits 0 if calculator is correct, 1 if buggy"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  ./test.sh                    # Fails (current is broken)"
echo "  git bisect start"
echo "  git bisect bad HEAD"
echo "  git bisect good HEAD~19      # First commit is good"
echo ""
