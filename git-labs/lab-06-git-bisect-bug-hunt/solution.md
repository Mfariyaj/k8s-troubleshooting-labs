# Lab 06: Solution — Git Bisect Bug Hunt

## Root Cause

Commit 12 (message: "build 12: refactored tax calculation") changed `subtotal * 0.1` to `subtotal * 10` in the `calculate_total()` function. This causes a 1000% tax instead of 10%.

## Fix Commands

```bash
cd /tmp/git-lab-06

# Method 1: Automated bisect (fastest)
git bisect start
git bisect bad HEAD
git bisect good HEAD~19   # First build commit is good
git bisect run ./test.sh

# Git will output:
# "abc1234 is the first bad commit"
# commit message: "build 12: refactored tax calculation"

# View the offending change:
git show <bad-commit-sha>
# Shows: -    tax = subtotal * 0.1
#        +    tax = subtotal * 10

# End bisect
git bisect reset

# Method 2: Manual bisect
git bisect start
git bisect bad HEAD        # build 20 is bad
git bisect good HEAD~19    # build 1 is good
# Git checks out ~build 10
./test.sh                  # PASS → mark good
git bisect good
# Git checks out ~build 15
./test.sh                  # FAIL → mark bad
git bisect bad
# Git checks out ~build 12
./test.sh                  # FAIL → mark bad
git bisect bad
# Git checks out ~build 11
./test.sh                  # PASS → mark good
git bisect good
# Git announces: build 12 is the first bad commit!

git bisect reset

# Fix the bug:
sed -i 's/subtotal \* 10/subtotal * 0.1/' calculator.py
git add calculator.py
git commit -m "fix: correct tax rate from 10x to 0.1x (10%)"
```

## Git Internals Explained

### How Bisect Works

1. **Binary search**: Given N commits between good and bad, bisect tests the midpoint, halving the search space each time.
2. **Complexity**: O(log2(N)) — for 20 commits, needs ~4-5 tests.
3. **State stored in**: `.git/refs/bisect/` (good/bad refs) and `.git/BISECT_LOG`

### Bisect Internals

```
.git/refs/bisect/bad         # The known-bad commit
.git/refs/bisect/good-*      # All known-good commits
.git/BISECT_LOG              # Bisect operation log
.git/BISECT_NAMES            # Paths restriction (if any)
```

### Advanced Bisect Features

- `git bisect skip` — skip untestable commits (build broken for unrelated reasons)
- `git bisect start -- <path>` — restrict bisect to commits touching specific paths
- `git bisect run <script>` — exit 0=good, 1-124/126-127=bad, 125=skip
- `git bisect log | git bisect replay` — replay a bisect session
- `git bisect visualize` — open gitk showing remaining candidates

### When to Use Bisect

- Regression bugs (something that used to work stopped working)
- Performance regressions
- Any binary yes/no test condition
- When you have a reliable test script
