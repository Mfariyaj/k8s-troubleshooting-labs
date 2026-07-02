# Lab 07: Solution — Cherry-pick Conflicts

## Root Cause

Commit 3 (caching) imports `from auth import authenticate, get_token` and `from pagination import paginate` — these only exist because of commits 1 and 2. Cherry-picking commit 3 alone brings code that references non-existent dependencies.

## Fix Commands

### Approach A: Cherry-pick All Dependencies (Recommended)

```bash
cd /tmp/git-lab-07

# Abort the failed cherry-pick
git cherry-pick --abort

# Identify commits 1, 2, 3 on the feature branch
git log --oneline feature/full-api

# Cherry-pick them in order (oldest first)
# Get the SHAs of commits 1, 2, 3 (reverse order from log)
COMMITS=$(git log --oneline --reverse feature/full-api | head -3 | awk '{print $1}')
git cherry-pick $COMMITS

# Note: commit 1 should apply cleanly since main has similar structure
# Commits 2 and 3 may need minor conflict resolution
```

### Approach B: Standalone Cache (Clean, No Dependencies)

```bash
cd /tmp/git-lab-07

# Abort the failed cherry-pick
git cherry-pick --abort

# Manually add cache.py (copy from feature branch)
git show feature/full-api~2:cache.py > cache.py

# Add caching to main's api.py without auth/pagination dependencies
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - updated main with caching."""

from cache import cached, invalidate_cache

@cached(ttl=300)
def get_users():
    """Get users from database."""
    return [
        {"id": 1, "name": "Alice", "role": "admin"},
        {"id": 2, "name": "Bob", "role": "user"},
    ]

@cached(ttl=600)
def get_products():
    """Get products catalog."""
    return [
        {"id": 1, "name": "Widget", "price": 9.99},
        {"id": 2, "name": "Gadget", "price": 19.99},
    ]

def get_orders():
    """New endpoint: get orders."""
    return [{"id": 1, "user_id": 1, "product_id": 1}]
EOF

git add .
git commit -m "feat: add caching layer (adapted from feature/full-api)"
```

## Git Internals Explained

### How Cherry-pick Works

1. Git computes the diff of the target commit against its parent
2. It applies that diff as a patch to the current HEAD
3. If the patch doesn't apply cleanly (context lines don't match), conflict occurs
4. Cherry-pick creates a NEW commit (different SHA) with the same changes

### Why Dependencies Cause Conflicts

- Commit 3's diff adds `from cache import cached` on the same line where commits 1 and 2 added auth/pagination imports
- The context lines around the changes (function signatures, etc.) are different between main and the feature branch
- Git can't match the patch hunks to the right locations

### Cherry-pick vs. Merge vs. Rebase

| Method | Creates New Commits | Preserves History | Dependencies |
|--------|-------------------|------------------|--------------|
| Cherry-pick | Yes (new SHA) | No (duplicates) | Manual |
| Merge | Yes (merge commit) | Yes | Automatic |
| Rebase | Yes (new SHAs) | Rewrites | Sequential |

### Best Practices

- Cherry-pick atomic, self-contained commits
- Use `git cherry-pick -x` to annotate the source
- If a commit has dependencies, cherry-pick all dependencies in order
- Consider `git merge --no-ff` if you need many commits from a branch
