#!/bin/bash
# Clean up all Git troubleshooting labs
set -e

echo "🧹 Cleaning up all Git troubleshooting labs..."
echo "============================================="

for dir in /tmp/git-lab-*/; do
    if [ -d "$dir" ]; then
        echo "  Removing: $dir"
        rm -rf "$dir"
    fi
done

# Also clean up any worktree directories
for dir in /tmp/git-lab-*-worktree*/; do
    if [ -d "$dir" ]; then
        echo "  Removing: $dir"
        rm -rf "$dir"
    fi
done

echo ""
echo "✅ All lab directories removed."
