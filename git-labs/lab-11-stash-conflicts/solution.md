# Lab 11: Solution — Stash Conflicts

## Root Cause

The stash was created before the hotfix commit. When popping, git tries to apply the stash diff against the current (modified) working tree, causing conflicts because the same lines were changed by the hotfix.

## Fix Commands

### Approach A: Resolve In-Place

```bash
cd /tmp/git-lab-11

# Edit server.py to combine both changes (SSL + hotfix)
cat > server.py <<'EOF'
#!/usr/bin/env python3
"""Server module - PRODUCTION PATCH + SSL support."""

def configure(config):
    """Configure server from YAML."""
    return {
        "bind": f"{config['server']['host']}:{config['server']['port']}",
        "workers": config['server']['workers'],
        "timeout": config['server']['timeout'],
        "ssl": True,
        "ssl_cert": "/etc/ssl/cert.pem",
    }

def start(settings):
    """Start server."""
    proto = "https" if settings.get("ssl") else "http"
    print(f"Starting {proto}://{settings['bind']} with {settings['workers']} workers")
    print(f"Timeout: {settings['timeout']}s")
    return True

def health_check():
    """Health check endpoint."""
    return {"status": "ok", "uptime": 0}
EOF

# Edit config.yaml (keep production settings, that's what we want)
cat > config.yaml <<'EOF'
# Server Configuration - PRODUCTION + SSL
server:
  host: 0.0.0.0
  port: 9090
  workers: 8
  timeout: 60
  ssl: true
  ssl_cert: /etc/ssl/cert.pem

database:
  host: db.internal
  port: 5432
  name: myapp_prod
  pool: 20

cache:
  enabled: true
  ttl: 300
  backend: redis
EOF

# Mark conflicts resolved
git add config.yaml server.py

# The stash was NOT dropped due to conflict — drop it manually
git stash drop

# Commit the combined changes
git commit -m "feat: integrate SSL support with production config"
```

### Approach B: Use `git stash branch` (Alternative)

```bash
cd /tmp/git-lab-11

# Reset working tree (conflicts from failed pop)
git checkout -- .

# Create a branch from where stash was originally created
git stash branch ssl-feature

# This: (1) checks out the commit where stash was created,
#        (2) applies the stash, (3) drops the stash
# Now we're on 'ssl-feature' with the SSL changes applied cleanly

# Go back to main and merge
git checkout main
git merge ssl-feature
# Resolve the single merge conflict (simpler than stash conflict)
```

## Git Internals Explained

### How Stash Works

A stash is actually TWO or THREE commits on a special ref:
```
stash@{0} → stash commit (working tree changes)
           ├── parent 1: HEAD at stash time
           ├── parent 2: index commit (staged changes)
           └── parent 3: untracked files (if -u flag used)
```

Stored at: `.git/refs/stash` (stack stored via reflog: `.git/logs/refs/stash`)

### Why Pop Doesn't Drop on Conflict

- `git stash pop` = `git stash apply` + `git stash drop`
- If `apply` causes conflicts, `drop` is NOT executed
- This is a safety feature — you can try again or use a different approach
- Always `git stash drop` manually after resolving a conflicted pop

### Stash Tips

- `git stash push -m "description"` — always add a message
- `git stash push -p` — stash specific hunks interactively
- `git stash show -p stash@{0}` — preview stash content before applying
- `git stash branch <name>` — safest way to apply complex stashes
- Multiple stashes stack: `stash@{0}` is newest, `stash@{n}` is older
