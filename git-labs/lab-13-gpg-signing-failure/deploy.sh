#!/bin/bash
# Lab 13: GPG Signing Failure
# Creates a repo configured with broken GPG signing
set -e

LAB_DIR="/tmp/git-lab-13"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Initial commit (before GPG was set up)
echo "# Signed Commits Project" > README.md
git add .
git commit -m "Initial commit (unsigned)"

echo "version 1.0" > version.txt
git add .
git commit -m "Add version file (unsigned)"

# Now configure BROKEN GPG signing
# Use a non-existent key ID
git config commit.gpgsign true
git config user.signingkey "DEADBEEF12345678"

# Also set a wrong gpg program path (for extra fun)
git config gpg.program "/usr/local/bin/gpg-nonexistent"

# Create a file that the user will try to commit (and fail due to GPG)
echo "important feature code" > feature.py
git add feature.py

echo ""
echo "============================================="
echo "🔧 Lab 13: GPG Signing Failure"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  The team mandated commit signing. Git is configured to sign"
echo "  all commits, but the configuration has multiple issues:"
echo "  - gpg.program points to a non-existent binary"
echo "  - user.signingkey references a key that doesn't exist"
echo "  - commit.gpgsign is set to true (so ALL commits require signing)"
echo ""
echo "  You have a staged change (feature.py) that you cannot commit."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Fix the git configuration so you can commit."
echo ""
echo "  Options:"
echo "  a) Disable signing entirely (if you don't have GPG set up)"
echo "  b) Fix the gpg program path and create/use a real key"
echo "  c) Commit this one without signing (bypass)"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git commit -m 'add feature'   # Will FAIL"
echo "  git config --list --local | grep -i gpg"
echo "  git config --list --local | grep -i sign"
echo ""
