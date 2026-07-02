#!/bin/bash
# Lab 05: Submodule Sync Broken
# Creates a parent repo with broken submodule references
set -e

LAB_DIR="/tmp/git-lab-05"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

# Create the "library" submodule repository
LIB_DIR="$LAB_DIR/shared-lib.git"
mkdir -p "$LIB_DIR"
cd "$LIB_DIR"
git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

echo 'def helper(): return "v1"' > lib.py
git add lib.py
git commit -m "lib v1"

echo 'def helper(): return "v2"' > lib.py
git add lib.py
git commit -m "lib v2"

LIB_V2_SHA=$(git rev-parse HEAD)

echo 'def helper(): return "v3"' > lib.py
git add lib.py
git commit -m "lib v3"

LIB_V3_SHA=$(git rev-parse HEAD)

# Create the parent project
PROJECT_DIR="$LAB_DIR/project"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

echo "# My Project" > README.md
git add README.md
git commit -m "Initial project"

# Add submodule properly
git submodule add "$LIB_DIR" libs/shared
cd libs/shared
git checkout "$LIB_V2_SHA"
cd "$PROJECT_DIR"
git add .
git commit -m "Add shared-lib submodule at v2"

# Now BREAK things:

# 1. Change .gitmodules URL to a wrong path
sed -i "s|$LIB_DIR|/tmp/git-lab-05/WRONG-PATH/shared-lib.git|" .gitmodules
git add .gitmodules
git commit -m "Updated submodule path (BROKEN)"

# 2. Mess up the .git/config submodule URL (doesn't match .gitmodules)
git config submodule.libs/shared.url "/tmp/git-lab-05/ANOTHER-WRONG-PATH"

# 3. Manually point the submodule to a wrong commit by editing the index
cd libs/shared
# Put the submodule in detached HEAD at wrong commit
git checkout "$LIB_V3_SHA" 2>/dev/null
cd "$PROJECT_DIR"

# 4. Don't stage the submodule change — mismatch between index and actual

echo ""
echo "============================================="
echo "🔧 Lab 05: Submodule Sync Broken"
echo "============================================="
echo ""
echo "📁 Lab directory: $PROJECT_DIR"
echo "📁 Library repo: $LIB_DIR"
echo ""
echo "SCENARIO:"
echo "  The project has a submodule 'libs/shared' that is completely"
echo "  broken. Multiple things are wrong:"
echo "  - .gitmodules has wrong URL path"
echo "  - .git/config has a DIFFERENT wrong URL"
echo "  - Submodule is checked out at wrong commit (v3 instead of v2)"
echo "  - Submodule is in detached HEAD state"
echo ""
echo "YOUR TASK:"
echo "  cd $PROJECT_DIR"
echo "  Fix all submodule issues so that:"
echo "  - .gitmodules points to correct library path"
echo "  - git submodule sync works"
echo "  - git submodule update --init works"
echo "  - Submodule is at the correct commit (v2)"
echo ""
echo "COMMANDS TO START:"
echo "  cd $PROJECT_DIR"
echo "  git submodule status"
echo "  cat .gitmodules"
echo "  git config --get submodule.libs/shared.url"
echo ""
