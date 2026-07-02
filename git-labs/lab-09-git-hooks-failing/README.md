## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (creates a local git repo with the broken state)
2. Navigate: `cd /tmp/git-lab-XX/`
3. Investigate: `git status`, `git log --oneline`, `git reflog`
4. Fix the issue using git commands
5. Verify your fix resolves the problem
6. Check `solution.md` if stuck. Cleanup: `./cleanup.sh`

---

# Lab 09: Git Hooks Failing

## Difficulty: 🟡 Intermediate

## Scenario

Your team's repository has pre-commit and pre-push hooks installed, but both are broken. The hooks are blocking ALL commits and pushes:

1. **pre-commit hook**: Has TWO bugs — wrong shebang (`/bin/bsh` doesn't exist) AND the file is not executable
2. **pre-push hook**: Has a bash syntax error (`if` without `then`)

## What You'll See

```bash
$ cd /tmp/git-lab-09/repo
$ git add feature.py
$ git commit -m "add feature"
hint: The '.git/hooks/pre-commit' hook was ignored because it's not set as executable.
# OR if permissions are fixed but shebang is wrong:
.git/hooks/pre-commit: /bin/bsh: bad interpreter: No such file or directory

$ git push origin main
.git/hooks/pre-push: line 8: syntax error near unexpected token `echo'
```

## Hints

1. **Hint 1**: Hooks live in `.git/hooks/`. Check their permissions with `ls -la .git/hooks/` and their shebang with `head -1 .git/hooks/pre-commit`.

2. **Hint 2**: For the pre-commit hook: (a) fix the shebang from `/bin/bsh` to `/bin/bash`, and (b) make it executable with `chmod +x .git/hooks/pre-commit`.

3. **Hint 3**: For the pre-push hook: the `if [ -f "tests.py" ]` is missing `; then` at the end. Bash `if` statements require `then` after the condition.

## Useful Commands

```bash
ls -la .git/hooks/                  # Check hook permissions
head -1 .git/hooks/pre-commit      # Check shebang
chmod +x .git/hooks/pre-commit     # Make executable
bash -n .git/hooks/pre-push        # Syntax check without executing
cat .git/hooks/pre-commit          # View hook source
git commit --no-verify             # Skip hooks (emergency bypass)
git push --no-verify               # Skip pre-push hook
```

## Success Criteria

- `pre-commit` hook: correct shebang (`#!/bin/bash`), executable, passes on clean code
- `pre-push` hook: no syntax errors, runs without crashing
- `git add feature.py && git commit -m "add feature"` succeeds
- `git push origin main` succeeds
- Both hooks actually run (not just bypassed with `--no-verify`)
