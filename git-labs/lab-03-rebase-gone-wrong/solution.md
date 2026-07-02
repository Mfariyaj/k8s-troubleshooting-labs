# Lab 03: Solution — Rebase Gone Wrong

## Root Cause

The feature branch was created from the first commit, while main had 3 subsequent commits that heavily modified `app.py`. Every feature branch commit conflicts with main because they all modify the same function (`main()`) and the file structure.

## Fix Commands

### Approach A: Abort and Merge Instead (Simpler)

```bash
cd /tmp/git-lab-03

# Abort the rebase — go back to clean feature branch
git rebase --abort

# Verify we're back on feature with clean state
git status
git log --oneline

# Merge main INTO feature instead (simpler conflict resolution)
git merge main

# Resolve the single merge conflict — combine both sets of functions
cat > app.py <<'EOF'
def main():
    print("App v4 - Complete")
    setup_logging()
    validate_env()
    config = load_config()
    db = connect_db(config)
    server = start_server(config, db)
    cache = init_cache()
    return 0

def setup_logging():
    return "logging enabled"

def validate_env():
    import os
    return os.getenv("APP_ENV", "development")

def load_config():
    return {"debug": False, "db_host": "localhost", "port": 8080}

def connect_db(config):
    return f"connected to {config['db_host']}"

def start_server(config, db):
    return f"server on port {config['port']}"

def init_cache():
    return {"ttl": 300}
EOF

git add app.py
git commit -m "Merge main into feature: combined all functionality"
```

### Approach B: Complete the Rebase (Harder but Linear History)

```bash
cd /tmp/git-lab-03

# Resolve the first conflict (add setup_logging to main's version)
cat > app.py <<'EOF'
def main():
    print("Hello World v4 - Production")
    setup_logging()
    config = load_config()
    db = connect_db(config)
    server = start_server(config, db)
    return 0

def load_config():
    return {"debug": False, "db_host": "localhost", "port": 8080}

def connect_db(config):
    return f"connected to {config['db_host']}"

def start_server(config, db):
    return f"server on port {config['port']}"

def setup_logging():
    return "logging enabled"
EOF

git add app.py
git rebase --continue

# Resolve second conflict (add validate_env)
# ... similar process, add validate_env function

git add app.py
git rebase --continue

# Resolve third conflict (add init_cache)
# ... similar process, add init_cache function

git add app.py
git rebase --continue
```

## Git Internals Explained

### What Happens During Rebase

1. Git finds the merge-base between your branch and the target
2. For each commit on your branch (oldest first), git tries to apply it as a patch on top of the target
3. If the patch doesn't apply cleanly, you get a conflict
4. After resolving, `--continue` applies the next patch

### Why Rebase Causes More Conflicts Than Merge

- **Merge**: Resolves conflicts once (comparing two endpoints)
- **Rebase**: Resolves conflicts N times (once per commit being replayed)
- Each rebased commit might conflict differently because the base keeps changing

### Key Files During Rebase

- `.git/rebase-merge/done` — completed steps
- `.git/rebase-merge/git-rebase-todo` — remaining steps
- `.git/rebase-merge/head-name` — original branch
- `.git/rebase-merge/onto` — target commit
- `ORIG_HEAD` — pre-rebase HEAD (safety bookmark)

### When to Use Merge vs. Rebase

- **Rebase**: Small feature branches with few commits, when linear history matters
- **Merge**: Long-lived branches, when many files are heavily modified in both branches
- **Rule of thumb**: If rebase causes conflicts on every commit, merge is probably better
