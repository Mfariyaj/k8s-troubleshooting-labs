# 🔧 Git & GitHub Troubleshooting Labs

## 15 Real-World Broken Git Scenarios for DevOps Engineers

---

## Overview

These labs simulate the exact Git disasters you'll encounter in production teams: force-push catastrophes, rebase nightmares, lost commits, broken submodules, and more. Each lab creates an isolated, broken Git repository that you must diagnose and fix using only the Git CLI.

No network access required. Every lab runs purely with local Git operations.

---

## 🎯 What These Labs Cover

| Topic | Labs |
|-------|------|
| **Merge Conflicts** | Multi-branch conflicts, recursive strategies, conflict markers |
| **Rebase & History** | Interactive rebase, rebase conflicts, history rewriting |
| **Cherry-pick** | Dependent commits, partial cherry-picks, conflict resolution |
| **Bisect** | Binary search for bugs, automated bisect with test scripts |
| **Reflog** | Time travel, recovering lost commits, reset recovery |
| **Submodules** | Broken references, detached HEAD, path mismatches |
| **Worktrees** | Stale branches, corruption recovery, concurrent development |
| **Hooks** | Pre-commit/pre-push failures, shebang issues, permissions |
| **Large Files** | History rewriting, git-filter-branch, BFG, git-lfs |
| **GPG Signing** | Key configuration, expired keys, agent issues |
| **Sparse Checkout** | Cone mode, pattern files, partial clones |
| **Branching Strategies** | Detached HEAD, force-push recovery, stash conflicts |

---

## 📋 Prerequisites

| Requirement | Minimum Version | Check Command |
|-------------|----------------|---------------|
| Git | 2.30+ | `git --version` |
| Bash | 4.0+ | `bash --version` |
| coreutils | Standard | `ls --version` |
| Python 3 (Lab 06 only) | 3.6+ | `python3 --version` |

**No network access, no GitHub account, no remote repositories needed.**

All labs create isolated repositories in `/tmp/git-lab-XX/` directories.

---

## 🚀 Quick Start

### Deploy a single lab:
```bash
cd git-labs/lab-01-merge-conflict-resolution
./deploy.sh
cd /tmp/git-lab-01
# Now diagnose and fix!
```

### Deploy all labs:
```bash
cd git-labs
./deploy-all.sh
```

### Clean up a single lab:
```bash
cd git-labs/lab-01-merge-conflict-resolution
./cleanup.sh
```

### Clean up all labs:
```bash
cd git-labs
./cleanup-all.sh
```

---

## 📊 Lab Index

| # | Lab | Difficulty | Topic | Key Skills |
|---|-----|-----------|-------|------------|
| 01 | [Merge Conflict Resolution](lab-01-merge-conflict-resolution/) | 🟢 Beginner | Branching | `git merge`, conflict markers, `--ours`/`--theirs` |
| 02 | [Detached HEAD Recovery](lab-02-detached-head-recovery/) | 🟢 Beginner | HEAD/refs | `git reflog`, `git branch`, `git checkout` |
| 03 | [Rebase Gone Wrong](lab-03-rebase-gone-wrong/) | 🟡 Intermediate | Rebase | `git rebase --abort`, `git reflog`, `ORIG_HEAD` |
| 04 | [Force Push Recovery](lab-04-force-push-recovery/) | 🟡 Intermediate | History | `git reflog`, `git reset`, bare repos |
| 05 | [Submodule Sync Broken](lab-05-submodule-sync-broken/) | 🟡 Intermediate | Submodules | `git submodule`, `.gitmodules`, `git config` |
| 06 | [Git Bisect Bug Hunt](lab-06-git-bisect-bug-hunt/) | 🟡 Intermediate | Bisect | `git bisect`, automated testing, `git bisect run` |
| 07 | [Cherry-pick Conflicts](lab-07-cherry-pick-conflicts/) | 🟡 Intermediate | Cherry-pick | `git cherry-pick`, `-x`, `--no-commit` |
| 08 | [Large File History Rewrite](lab-08-large-file-history-rewrite/) | 🔴 Advanced | History | `git filter-branch`, `git filter-repo`, BFG |
| 09 | [Git Hooks Failing](lab-09-git-hooks-failing/) | 🟡 Intermediate | Hooks | `.git/hooks/`, shebang, permissions |
| 10 | [Reflog Time Travel](lab-10-reflog-time-travel/) | 🟡 Intermediate | Reflog | `git reflog`, `git reset`, SHA recovery |
| 11 | [Stash Conflicts](lab-11-stash-conflicts/) | 🟡 Intermediate | Stash | `git stash`, `git stash branch`, conflict resolution |
| 12 | [Worktree Corruption](lab-12-worktree-corruption/) | 🔴 Advanced | Worktrees | `git worktree`, `.git/worktrees/`, `git worktree prune` |
| 13 | [GPG Signing Failure](lab-13-gpg-signing-failure/) | 🔴 Advanced | Signing | `git config`, GPG keys, `gpg --list-keys` |
| 14 | [Sparse Checkout Broken](lab-14-sparse-checkout-broken/) | 🔴 Advanced | Sparse | `git sparse-checkout`, cone mode, patterns |
| 15 | [Git LFS Failures](lab-15-git-lfs-failures/) | 🔴 Advanced | LFS | `git lfs`, `.gitattributes`, pointer files |

---

## 🛠️ Useful Git Debugging Commands Reference

### Inspecting State
```bash
git status                          # Current state
git log --oneline --graph --all     # Visual history
git reflog                          # All HEAD movements
git show-ref                        # All references
git rev-parse HEAD                  # Current commit SHA
git cat-file -t <sha>               # Object type
git cat-file -p <sha>               # Object contents
```

### Investigating Problems
```bash
git diff --name-only HEAD~1         # Changed files in last commit
git log --diff-filter=D -- <file>   # Find when file was deleted
git log -S "string" --all           # Find commit that added/removed string
git blame <file>                    # Line-by-line authorship
git fsck --full                     # Check repository integrity
git count-objects -vH               # Repository size
```

### Recovery Commands
```bash
git reflog expire --expire=now --all  # DON'T run this (destroys reflog)
git reflog show <branch>            # Branch-specific reflog
git cherry-pick <sha>               # Apply specific commit
git reset --hard <sha>              # Reset to specific state (DANGEROUS)
git stash list                      # Show all stashes
git worktree list                   # Show all worktrees
```

### Submodule Commands
```bash
git submodule status                # Submodule state
git submodule sync                  # Sync URLs from .gitmodules
git submodule update --init         # Initialize and update
git submodule foreach <cmd>         # Run command in each submodule
```

### Configuration Debugging
```bash
git config --list --show-origin     # All config with source files
git config --list --show-scope      # All config with scope
git var -l                          # Git variables
```

---

## 📈 Difficulty Progression

**Recommended order for beginners:**
1. Lab 01 → Lab 02 → Lab 10 → Lab 11 → Lab 06

**For intermediate users:**
1. Lab 03 → Lab 04 → Lab 07 → Lab 05 → Lab 09

**For advanced users:**
1. Lab 08 → Lab 12 → Lab 13 → Lab 14 → Lab 15

---

## 🏗️ How Labs Work

Each lab's `deploy.sh` script:
1. Creates an isolated git repository at `/tmp/git-lab-XX/`
2. Sets up the broken scenario using only local git commands
3. Leaves the repo in a state that simulates a real failure
4. Prints instructions on what to investigate

Each lab's `cleanup.sh` script:
1. Removes the `/tmp/git-lab-XX/` directory
2. Cleans up any additional temp files

**All labs are stateless and repeatable** — deploy, break things further, clean up, redeploy.

---

## ⚔️ Rules of Engagement

1. Run `deploy.sh` first, then `cd /tmp/git-lab-XX/`
2. Use ONLY git CLI commands to diagnose and fix
3. Don't read `solution.md` until you've spent at least 10 minutes
4. Time yourself — track improvement across attempts
5. Document your thought process and commands used

---

## 📜 License

MIT License — break things freely, fix them wisely.
