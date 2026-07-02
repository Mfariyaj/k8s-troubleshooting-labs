#!/bin/bash
# Lab 12: Worktree Corruption
# Creates a repo with broken worktrees after branch deletion
set -e

LAB_DIR="/tmp/git-lab-12"

rm -rf "$LAB_DIR"
rm -rf /tmp/git-lab-12-worktree-*
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create initial commits
echo "# Main Project" > README.md
echo "main code" > main.py
git add .
git commit -m "Initial commit on main"

echo "main v2" > main.py
git add .
git commit -m "Update main v2"

# Create branches for worktrees
git branch feature-auth
git branch feature-api
git branch feature-dashboard

# Add worktrees
git worktree add /tmp/git-lab-12-worktree-auth feature-auth
git worktree add /tmp/git-lab-12-worktree-api feature-api
git worktree add /tmp/git-lab-12-worktree-dashboard feature-dashboard

# Make some commits in worktrees
cd /tmp/git-lab-12-worktree-auth
echo "auth module" > auth.py
git add . && git commit -m "Add auth module"

cd /tmp/git-lab-12-worktree-api
echo "api module" > api.py
git add . && git commit -m "Add API module"

cd /tmp/git-lab-12-worktree-dashboard
echo "dashboard module" > dashboard.py
git add . && git commit -m "Add dashboard module"

# Go back to main repo
cd "$LAB_DIR"

# Now BREAK things:
# 1. Delete a worktree directory manually (without git worktree remove)
rm -rf /tmp/git-lab-12-worktree-auth

# 2. Delete a branch that has a worktree (by hacking refs directly)
# Force-delete the branch ref for feature-api
rm -f .git/refs/heads/feature-api
# Also corrupt the worktree metadata
echo "/nonexistent/path" > .git/worktrees/git-lab-12-worktree-api/gitdir

# 3. Delete the worktree directory for dashboard but leave stale metadata
rm -rf /tmp/git-lab-12-worktree-dashboard

echo ""
echo "============================================="
echo "🔧 Lab 12: Worktree Corruption"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  A developer had 3 worktrees (auth, api, dashboard) linked to"
echo "  3 feature branches. Through various accidents:"
echo "  - auth worktree directory was deleted manually (rm -rf)"
echo "  - api branch was deleted while worktree still existed"
echo "  - dashboard worktree directory was removed"
echo ""
echo "  Now 'git worktree list' shows stale/broken entries and"
echo "  normal git operations may fail."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Fix the worktree state so that:"
echo "  - Stale worktree entries are cleaned up"
echo "  - Remaining work is not lost"
echo "  - 'git worktree list' shows only valid entries"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git worktree list           # Shows broken entries"
echo "  ls .git/worktrees/          # Stale metadata"
echo "  git branch -a               # Some branches missing"
echo ""
