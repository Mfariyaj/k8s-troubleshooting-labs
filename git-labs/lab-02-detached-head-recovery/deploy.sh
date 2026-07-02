#!/bin/bash
# Lab 02: Detached HEAD Recovery
# Creates a repo where commits were made in detached HEAD state
set -e

LAB_DIR="/tmp/git-lab-02"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create a series of commits on main
echo "v1: initial code" > app.py
git add app.py
git commit -m "v1: initial application"

echo "v2: added feature" > app.py
git add app.py
git commit -m "v2: added feature X"

echo "v3: refactored" > app.py
git add app.py
git commit -m "v3: refactored code"

echo "v4: fixed bug" > app.py
git add app.py
git commit -m "v4: fixed critical bug"

echo "v5: latest release" > app.py
git add app.py
git commit -m "v5: latest release"

# Now simulate: user checks out an old commit
OLD_COMMIT=$(git rev-parse HEAD~3)
git checkout "$OLD_COMMIT"

# User makes important commits while in detached HEAD
echo "v2-patched: emergency hotfix for v2" > app.py
git add app.py
git commit -m "IMPORTANT: emergency hotfix for production v2"

echo "v2-patched: hotfix + monitoring" > app.py
echo "monitoring enabled" > monitoring.py
git add .
git commit -m "IMPORTANT: added monitoring to hotfix"

# Save the detached commit SHA for verification
LOST_COMMIT=$(git rev-parse HEAD)

# Now simulate: user accidentally switches back to main
# The detached HEAD commits are now "lost"
git checkout main 2>/dev/null || true

echo ""
echo "============================================="
echo "🔧 Lab 02: Detached HEAD Recovery"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  A developer checked out an old commit to investigate a bug,"
echo "  then made 2 important commits (emergency hotfix + monitoring)"
echo "  while in detached HEAD state. They then switched back to main."
echo ""
echo "  The commits appear to be LOST — they're not on any branch!"
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Find and recover the two lost commits."
echo "  Put them on a proper branch called 'hotfix-recovery'."
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git log --oneline --all  # Notice: lost commits don't show here!"
echo "  git branch -a            # No hotfix branch exists"
echo ""
