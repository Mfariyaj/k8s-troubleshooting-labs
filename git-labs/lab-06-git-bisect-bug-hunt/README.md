# Lab 06: Git Bisect Bug Hunt

## Difficulty: 🟡 Intermediate

## Scenario

Your team's `calculator.py` module has a bug in the `calculate_total()` function. It should apply 10% tax (`subtotal * 0.1`) but instead it's multiplying by 10 (1000% tax!). This was noticed after 20 builds/commits.

Build 1 is known-good. The current HEAD (build 20) is broken. You need to find the exact commit that introduced the bug using `git bisect`.

## What You'll See

```bash
$ cd /tmp/git-lab-06
$ ./test.sh
FAIL: expected 110.0, got 1100.0

$ git log --oneline | head -5
abc1234 build 20: feature update 20
def5678 build 19: feature update 19
...

$ git log --oneline | wc -l
21    # 20 builds + 1 test script commit
```

## Hints

1. **Hint 1**: Start with `git bisect start`, mark `HEAD` as bad and `HEAD~19` (the first build commit) as good. Git will binary search through the 20 commits.

2. **Hint 2**: For automated bisect, use `git bisect run ./test.sh`. Git will automatically test each commit and find the broken one in ~4-5 steps (log2(20) ≈ 4.3).

3. **Hint 3**: The bug is in one specific commit that says "refactored tax calculation" — look for `subtotal * 10` instead of `subtotal * 0.1`. After bisect finds it, verify with `git show <sha>`.

## Useful Commands

```bash
git bisect start                    # Start bisect session
git bisect bad [<sha>]              # Mark commit as broken
git bisect good [<sha>]             # Mark commit as working
git bisect run <script>             # Automated bisect with test
git bisect log                      # Show bisect progress
git bisect visualize                # Show remaining candidates
git bisect reset                    # End bisect session
git show <sha>                      # Show specific commit diff
git log --oneline                   # Quick history overview
```

## Success Criteria

- Identify the exact commit that introduced the bug
- Be able to explain what changed (0.1 → 10 in tax calculation)
- Complete the bisect in 5 or fewer manual steps (or use automated `run`)
- Use `git bisect reset` to return to normal state after finding the bug
