#!/bin/bash
# Lab 10: Reflog Time Travel
# Creates a repo, then resets hard to lose 5 commits
set -e

LAB_DIR="/tmp/git-lab-10"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create 10 commits with meaningful content
for i in $(seq 1 10); do
    cat > "module_${i}.py" <<EOF
#!/usr/bin/env python3
"""Module $i - Critical business logic."""

def process_${i}(data):
    """Process data using algorithm $i."""
    result = data * $i
    return {"module": $i, "result": result, "status": "active"}
EOF
    git add .
    git commit -m "feat: add module $i (critical business logic)"
done

# Show current state
echo "Full history (before disaster):"
git log --oneline

# Now simulate: developer accidentally resets hard
git reset --hard HEAD~5

echo ""
echo "============================================="
echo "🔧 Lab 10: Reflog Time Travel"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  A developer accidentally ran 'git reset --hard HEAD~5'"
echo "  thinking they were on a feature branch, but they were on main."
echo ""
echo "  5 critical commits (modules 6-10) are now GONE."
echo "  The working tree only shows modules 1-5."
echo ""
echo "EVIDENCE:"
echo "  $(ls module_*.py | tr '\n' ' ')"
echo "  Modules 6-10 are MISSING!"
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Recover all 10 commits. Modules 6-10 must be restored."
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git log --oneline          # Only shows 5 commits"
echo "  ls module_*.py             # Only modules 1-5"
echo "  git reflog                 # Your lifeline!"
echo ""
