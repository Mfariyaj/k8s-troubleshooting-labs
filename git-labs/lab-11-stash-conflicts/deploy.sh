#!/bin/bash
# Lab 11: Stash Conflicts
# Creates a repo where git stash pop fails with conflicts
set -e

LAB_DIR="/tmp/git-lab-11"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Initial commit
cat > config.yaml <<'EOF'
# Server Configuration
server:
  host: localhost
  port: 8080
  workers: 4
  timeout: 30

database:
  host: localhost
  port: 5432
  name: myapp
  pool: 5

cache:
  enabled: false
  ttl: 60
  backend: memory
EOF

cat > server.py <<'EOF'
#!/usr/bin/env python3
"""Server module."""

def configure(config):
    """Configure server from YAML."""
    return {
        "bind": f"{config['server']['host']}:{config['server']['port']}",
        "workers": config['server']['workers'],
    }

def start(settings):
    """Start server."""
    print(f"Starting on {settings['bind']} with {settings['workers']} workers")
    return True
EOF

git add .
git commit -m "Initial: server and config"

# Developer starts working on config changes (on main)
cat > config.yaml <<'EOF'
# Server Configuration
server:
  host: localhost
  port: 8080
  workers: 4
  timeout: 30

database:
  host: localhost
  port: 5432
  name: myapp
  pool: 5

cache:
  enabled: false
  ttl: 60
  backend: memory
EOF

# Developer modifies server.py with WIP (work in progress)
cat > server.py <<'EOF'
#!/usr/bin/env python3
"""Server module - WIP: adding SSL support."""

def configure(config):
    """Configure server from YAML."""
    return {
        "bind": f"{config['server']['host']}:{config['server']['port']}",
        "workers": config['server']['workers'],
        "ssl": True,
        "ssl_cert": "/etc/ssl/cert.pem",
    }

def start(settings):
    """Start server."""
    proto = "https" if settings.get("ssl") else "http"
    print(f"Starting {proto}://{settings['bind']} with {settings['workers']} workers")
    return True
EOF

# Stash the WIP to work on an urgent bug fix
git stash push -m "WIP: SSL support in progress"

# Now, urgent bug fix requires changing the SAME files
cat > config.yaml <<'EOF'
# Server Configuration - PATCHED
server:
  host: 0.0.0.0
  port: 9090
  workers: 8
  timeout: 60

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

cat > server.py <<'EOF'
#!/usr/bin/env python3
"""Server module - PRODUCTION PATCH."""

def configure(config):
    """Configure server from YAML."""
    return {
        "bind": f"{config['server']['host']}:{config['server']['port']}",
        "workers": config['server']['workers'],
        "timeout": config['server']['timeout'],
    }

def start(settings):
    """Start server."""
    print(f"Starting on {settings['bind']} with {settings['workers']} workers")
    print(f"Timeout: {settings['timeout']}s")
    return True

def health_check():
    """New: health check endpoint."""
    return {"status": "ok", "uptime": 0}
EOF

git add .
git commit -m "hotfix: production config + health check endpoint"

# Now try to pop the stash — CONFLICT because same files were modified
git stash pop 2>/dev/null || true

echo ""
echo "============================================="
echo "🔧 Lab 11: Stash Conflicts"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  A developer was adding SSL support (WIP, stashed it), then"
echo "  made a production hotfix that changed the same files."
echo "  Now 'git stash pop' fails with merge conflicts in both"
echo "  config.yaml and server.py."
echo ""
echo "  The stash is NOT dropped (because of the conflict)."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Resolve the stash conflicts, keeping BOTH the hotfix changes"
echo "  AND the SSL support from the stash."
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git status                 # Shows conflicts"
echo "  git stash list             # Stash still exists!"
echo "  cat server.py              # See conflict markers"
echo ""
