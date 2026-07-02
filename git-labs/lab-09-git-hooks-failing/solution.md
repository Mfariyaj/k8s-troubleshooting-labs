# Lab 09: Solution — Git Hooks Failing

## Root Cause

Three distinct bugs across two hooks:
1. **pre-commit**: Shebang line says `#!/bin/bsh` — there is no `/bin/bsh` interpreter
2. **pre-commit**: File lacks execute permission (git won't run it on some systems, error on others)
3. **pre-push**: Missing `; then` after `if [ -f "tests.py" ]` — bash syntax error

## Fix Commands

```bash
cd /tmp/git-lab-09/repo

# Fix 1: Correct the pre-commit shebang
sed -i '1s|#!/bin/bsh|#!/bin/bash|' .git/hooks/pre-commit

# Fix 2: Make pre-commit executable
chmod +x .git/hooks/pre-commit

# Fix 3: Fix pre-push syntax (add '; then' after the if condition)
sed -i 's/if \[ -f "tests.py" \]/if [ -f "tests.py" ]; then/' .git/hooks/pre-push

# Verify hooks are syntactically valid
bash -n .git/hooks/pre-commit && echo "pre-commit: OK"
bash -n .git/hooks/pre-push && echo "pre-push: OK"

# Now commit and push should work
git add feature.py
git commit -m "add feature"
git push origin main
```

## Git Internals Explained

### How Git Hooks Work

1. **Location**: `.git/hooks/` directory (local to each clone, not tracked)
2. **Execution**: Git looks for executable files with specific names
3. **Requirements**: Hook must be (a) executable, (b) have valid shebang, (c) exit 0 to allow the operation

### Hook Types and When They Fire

| Hook | Trigger | Block If Non-Zero |
|------|---------|-------------------|
| `pre-commit` | Before commit | Yes |
| `prepare-commit-msg` | After default message generated | Yes |
| `commit-msg` | After user enters message | Yes |
| `post-commit` | After commit complete | No |
| `pre-push` | Before push | Yes |
| `pre-rebase` | Before rebase | Yes |

### Common Hook Issues

| Problem | Symptom | Fix |
|---------|---------|-----|
| Not executable | "hook was ignored" | `chmod +x` |
| Wrong shebang | "bad interpreter" | Fix `#!` line |
| Syntax error | "unexpected token" | `bash -n` to check |
| Wrong path | Script exits with file-not-found | Use `$(git rev-parse --show-toplevel)` |
| Windows line endings | "^M" errors | `dos2unix` or `sed -i 's/\r$//'` |

### Shared Hooks (Team-wide)

Git hooks are NOT tracked in the repository by default. To share hooks:
- Store in a directory (e.g., `.githooks/`) and set: `git config core.hooksPath .githooks/`
- Or use a tool like `husky`, `pre-commit`, or `lefthook`
- Or symlink: `ln -sf ../../.githooks/pre-commit .git/hooks/pre-commit`

### Bypassing Hooks (Emergency Only)

```bash
git commit --no-verify -m "emergency fix"    # Skip pre-commit + commit-msg
git push --no-verify                         # Skip pre-push
```
