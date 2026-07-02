#!/bin/bash
# Lab 04: Force Push Recovery
# Simulates someone force-pushing to main, overwriting commits
set -e

LAB_DIR="/tmp/git-lab-04"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"

# Create a bare "remote" repo
REMOTE_DIR="$LAB_DIR/origin.git"
git init --bare "$REMOTE_DIR"

# Create the working repo (simulates developer's local)
WORK_DIR="$LAB_DIR/repo"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"
git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"
git remote add origin "$REMOTE_DIR"

# Create history with 10 important commits
for i in $(seq 1 10); do
    echo "Feature $i implementation" > "feature-$i.py"
    cat >> app.py <<EOF
# Feature $i - added by developer $((i % 3 + 1))
def feature_${i}():
    return "feature $i working"

EOF
    git add .
    git commit -m "feat: implement feature $i (important work by dev $((i % 3 + 1)))"
done

# Push all to "remote"
git push origin main

# Save the full HEAD for verification
FULL_HEAD=$(git rev-parse HEAD)

# Now simulate: someone force-pushes a truncated history
# (they rebased and force-pushed, losing commits 6-10)
git reset --hard HEAD~5
git push --force origin main

echo ""
echo "============================================="
echo "🔧 Lab 04: Force Push Recovery"
echo "============================================="
echo ""
echo "📁 Lab directory: $WORK_DIR"
echo "📁 Remote directory: $REMOTE_DIR"
echo ""
echo "SCENARIO:"
echo "  Someone ran 'git push --force origin main' after resetting"
echo "  to an earlier commit. The remote now only has commits 1-5."
echo "  Commits 6-10 (including feature-6.py through feature-10.py)"
echo "  are GONE from the remote."
echo ""
echo "  The reflog in this local repo still has the full history."
echo ""
echo "YOUR TASK:"
echo "  cd $WORK_DIR"
echo "  Recover the lost commits (6 through 10) and restore"
echo "  the full history on both local and remote."
echo ""
echo "COMMANDS TO START:"
echo "  cd $WORK_DIR"
echo "  git log --oneline          # Only shows 5 commits!"
echo "  git log --oneline origin/main  # Remote also only 5"
echo "  ls feature-*.py            # Only features 1-5 exist"
echo ""
