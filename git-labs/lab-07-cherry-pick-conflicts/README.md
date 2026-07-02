# Lab 07: Cherry-pick Conflicts

## Difficulty: 🟡 Intermediate

## Scenario

The `feature/full-api` branch has 5 commits that progressively add features:
1. Authentication layer
2. Pagination
3. Caching layer (this is what you want!)
4. Rate limiting
5. Logging

You're on `main` and only want the caching feature (commit 3). But when you cherry-pick it, it conflicts because commit 3's code references auth and pagination imports/functions from commits 1 and 2.

The cherry-pick is now stuck with conflicts.

## What You'll See

```bash
$ cd /tmp/git-lab-07
$ git status
On branch main
You are currently cherry-picking commit abc1234.
  (fix conflicts and run "git cherry-pick --continue")

Unmerged paths:
  both modified:   api.py

$ cat api.py
# Shows conflict markers between main's version and the cache commit
```

## Hints

1. **Hint 1**: You have three options: (a) abort and cherry-pick commits 1,2,3 in order, (b) resolve conflicts manually to adapt the cache code to main's API, (c) cherry-pick with `--no-commit` to stage changes for manual editing.

2. **Hint 2**: If cherry-picking commits 1,2,3 in order, use: `git cherry-pick --abort` first, then `git cherry-pick <sha1> <sha2> <sha3>` — git will apply them sequentially.

3. **Hint 3**: The cleanest approach for just the caching feature: abort the cherry-pick, then manually add `cache.py` and modify `api.py` to use the `@cached` decorator on main's existing function signatures.

## Useful Commands

```bash
git cherry-pick --abort             # Cancel current cherry-pick
git cherry-pick --continue          # Continue after resolving conflicts
git cherry-pick <sha1> <sha2>       # Cherry-pick multiple in order
git cherry-pick -x <sha>            # Add "cherry picked from" to message
git cherry-pick --no-commit <sha>   # Stage without committing
git log --oneline feature/full-api  # See feature branch commits
git show <sha>                      # See specific commit diff
git diff                            # View current conflicts
```

## Success Criteria

- Cherry-pick conflict is resolved (no more "cherry-picking in progress")
- Main branch has working caching functionality
- `cache.py` exists with the caching decorator
- `api.py` uses `@cached` decorators
- The code actually works (no missing imports/references)
