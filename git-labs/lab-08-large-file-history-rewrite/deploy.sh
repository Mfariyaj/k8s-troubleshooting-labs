#!/bin/bash
# Lab 08: Large File History Rewrite
# Creates a repo with a large file committed in history
set -e

LAB_DIR="/tmp/git-lab-08"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Commit 1: Initial project
cat > app.py <<'EOF'
#!/usr/bin/env python3
"""Main application."""
print("Hello from app v1")
EOF
echo "# Project" > README.md
git add .
git commit -m "Initial commit"

# Commit 2: Add a "large" binary file (50MB simulated with random data)
echo "Generating large file (this simulates a database dump)..."
dd if=/dev/urandom of=database_dump.sql bs=1M count=50 2>/dev/null
git add .
git commit -m "feat: added database dump for seeding (ACCIDENT - 50MB!)"

# Commit 3: More legitimate work on top
cat > app.py <<'EOF'
#!/usr/bin/env python3
"""Main application."""
import os

def get_version():
    return "2.0.0"

print(f"Hello from app v{get_version()}")
EOF
git add app.py
git commit -m "feat: add version function"

# Commit 4: Even more work on top
cat > config.py <<'EOF'
"""Configuration module."""
DATABASE_URL = "postgresql://localhost/myapp"
REDIS_URL = "redis://localhost:6379"
SECRET_KEY = "development-key"
EOF
git add config.py
git commit -m "feat: add configuration module"

# Commit 5: Someone "removed" the file but it's still in history
rm database_dump.sql
git add .
git commit -m "chore: remove database dump (file too large)"

# Commit 6: Latest work
cat > app.py <<'EOF'
#!/usr/bin/env python3
"""Main application."""
import os
from config import DATABASE_URL

def get_version():
    return "3.0.0"

def connect():
    return f"Connected to {DATABASE_URL}"

print(f"Hello from app v{get_version()}")
print(connect())
EOF
git add .
git commit -m "feat: connect to database"

# Show the repo size (it's bloated because of the large file in history)
echo ""
echo "============================================="
echo "🔧 Lab 08: Large File History Rewrite"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  Someone accidentally committed a 50MB database dump file to"
echo "  the repo at commit 2. It was deleted in commit 5, but it's"
echo "  still in the Git history, making the repo 50MB+."
echo ""
echo "  You need to remove it from ALL history, not just the current tree."
echo ""
echo "CURRENT REPO SIZE:"
du -sh "$LAB_DIR/.git"
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Remove database_dump.sql from ALL history."
echo "  After the fix, 'du -sh .git' should be ~100KB, not 50MB."
echo "  All other commits/files must be preserved."
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git log --oneline --stat      # See the large file in history"
echo "  git rev-list --objects --all | grep database_dump"
echo "  du -sh .git                   # See bloated size"
echo ""
