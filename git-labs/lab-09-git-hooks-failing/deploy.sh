#!/bin/bash
# Lab 09: Git Hooks Failing
# Creates a repo with broken pre-commit and pre-push hooks
set -e

LAB_DIR="/tmp/git-lab-09"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

# Create a bare repo as fake remote
REMOTE_DIR="$LAB_DIR/origin.git"
git init --bare "$REMOTE_DIR"

# Working repo
mkdir -p "$LAB_DIR/repo"
cd "$LAB_DIR/repo"
git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"
git remote add origin "$REMOTE_DIR"

# Initial commit
echo "# Project" > README.md
echo "print('hello')" > app.py
git add .
git commit -m "Initial commit"
git push origin main

# Install broken hooks

# Hook 1: pre-commit with WRONG shebang
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/bsh
# This hook runs linting before commit
# BUG: shebang says /bin/bsh which doesn't exist

echo "Running pre-commit lint check..."

# Check for debug statements
if grep -r "import pdb" --include="*.py" .; then
    echo "ERROR: Found pdb import! Remove debug statements."
    exit 1
fi

# Check for trailing whitespace
if grep -rP '\s+$' --include="*.py" .; then
    echo "ERROR: Trailing whitespace found!"
    exit 1
fi

echo "Pre-commit checks passed!"
exit 0
HOOK
# Note: NOT making it executable (bug #2)

# Hook 2: pre-push with syntax error
cat > .git/hooks/pre-push <<'HOOK'
#!/bin/bash
# This hook validates before pushing
# BUG: syntax error (missing 'then' after if)

echo "Running pre-push validation..."

# Check that tests pass
if [ -f "tests.py" ]
    echo "Running tests..."
    python3 tests.py
    if [ $? -ne 0 ]; then
        echo "ERROR: Tests failed! Cannot push."
        exit 1
    fi
fi

# Check branch name format
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ ! "$BRANCH" =~ ^(main|develop|feature/|hotfix/|release/) ]]; then
    echo "ERROR: Branch name '$BRANCH' doesn't follow naming convention."
    exit 1
fi

echo "Pre-push checks passed!"
exit 0
HOOK
chmod +x .git/hooks/pre-push

# Make a change that should be committable
echo "print('feature')" > feature.py

echo ""
echo "============================================="
echo "🔧 Lab 09: Git Hooks Failing"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR/repo"
echo ""
echo "SCENARIO:"
echo "  The team added pre-commit and pre-push hooks but they're"
echo "  both broken in different ways:"
echo "  - pre-commit: wrong shebang + not executable"
echo "  - pre-push: syntax error in the script"
echo ""
echo "  You can't commit (pre-commit fails) and you can't push"
echo "  (pre-push fails). You need to fix the hooks."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR/repo"
echo "  1. Try to commit feature.py (will fail)"
echo "  2. Fix the pre-commit hook"
echo "  3. Successfully commit"
echo "  4. Try to push (will fail)"
echo "  5. Fix the pre-push hook"
echo "  6. Successfully push"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR/repo"
echo "  git add feature.py"
echo "  git commit -m 'add feature'   # Will fail!"
echo "  cat .git/hooks/pre-commit     # Inspect the hook"
echo ""
