# Lab 14: Solution — Sparse Checkout Broken

## Root Cause

Multiple configuration conflicts:
1. `.git/info/sparse-checkout` has non-cone patterns (`**/*.yaml`, negations) mixed with cone-mode paths
2. `core.sparseCheckoutCone` was set to `false` but cone-mode directory patterns are present
3. Git can't resolve conflicting include/exclude patterns

## Fix Commands

### Approach A: Clean Restart (Recommended)

```bash
cd /tmp/git-lab-14/workspace

# Step 1: Disable sparse checkout entirely
git sparse-checkout disable

# Step 2: Verify all files are restored
ls services/    # Should show auth/ api/ dashboard/
ls libs/        # Should show common/ utils/ crypto/

# Step 3: Re-enable with cone mode and correct directories
git sparse-checkout init --cone
git sparse-checkout set services/api libs/common

# Step 4: Verify
ls services/    # Should show ONLY api/
ls libs/        # Should show ONLY common/
git sparse-checkout list
# Should show:
# services/api
# libs/common
```

### Approach B: Manual Fix (If disable fails)

```bash
cd /tmp/git-lab-14/workspace

# Fix config
git config core.sparseCheckout true
git config core.sparseCheckoutCone true

# Write correct cone-mode sparse file
cat > .git/info/sparse-checkout <<'EOF'
/*
!/*/
/services/
!/services/*/
/services/api/
/libs/
!/libs/*/
/libs/common/
EOF

# Re-apply
git read-tree -mu HEAD

# Verify
ls services/    # Only api/
ls libs/        # Only common/
```

## Git Internals Explained

### Sparse Checkout Modes

#### Cone Mode (Recommended, Git 2.25+)
- Faster performance (uses prefix matching)
- Patterns auto-generated from directory list
- Cannot use arbitrary glob patterns
- Format: directory entries with `/*` prefix patterns

#### Non-Cone Mode (Legacy)
- Supports arbitrary `.gitignore`-style patterns
- Slower (checks every file against every pattern)
- Pattern file is like inverse `.gitignore` (included, not excluded)

### Cone Mode Pattern File Format

```
# Auto-generated prefix: include all root files
/*
# Exclude all root directories
!/*/
# Then selectively include directory trees:
/services/
!/services/*/
/services/api/
/libs/
!/libs/*/
/libs/common/
```

Logic: Include root files → exclude all dirs → include parent dir → exclude subdirs → include target subdir

### The Skip-Worktree Bit

Sparse checkout works by setting the "skip-worktree" bit on index entries:
```bash
git ls-files -v | grep "^S"    # 'S' = skip-worktree (not in working tree)
git ls-files -v | grep "^H"    # 'H' = normal (in working tree)
```

### Common Issues

| Problem | Cause | Fix |
|---------|-------|-----|
| Wrong files visible | Pattern conflict | `sparse-checkout disable` + restart |
| Glob patterns in cone mode | Incompatible mode | Remove globs or switch to non-cone |
| Files reappear after checkout | Skip-worktree bit lost | `git read-tree -mu HEAD` |
| Status shows deleted files | sparse-checkout not applied | `git sparse-checkout reapply` |
