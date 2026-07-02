#!/bin/bash
# Lab 07: Cherry-pick Conflicts
# Creates a repo with interdependent commits for cherry-picking
set -e

LAB_DIR="/tmp/git-lab-07"

rm -rf "$LAB_DIR"
mkdir -p "$LAB_DIR"
cd "$LAB_DIR"

git init -b main
git config user.email "dev@example.com"
git config user.name "Lab User"

# Create initial main branch
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - base version."""

def get_users():
    return [{"id": 1, "name": "Alice"}]

def get_products():
    return [{"id": 1, "name": "Widget", "price": 9.99}]
EOF

git add api.py
git commit -m "Initial: basic API module"

# Create feature branch with 5 interdependent commits
git checkout -b feature/full-api

# Commit 1: Add authentication layer
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - with authentication."""

from auth import authenticate, get_token

def get_users(token):
    if not authenticate(token):
        raise PermissionError("Invalid token")
    return [{"id": 1, "name": "Alice"}]

def get_products():
    return [{"id": 1, "name": "Widget", "price": 9.99}]
EOF
cat > auth.py <<'EOF'
"""Authentication module."""
def authenticate(token):
    return token == "valid-token-123"

def get_token(user, password):
    if user == "admin" and password == "secret":
        return "valid-token-123"
    return None
EOF
git add .
git commit -m "feat(1/5): add authentication layer"

# Commit 2: Add pagination to users endpoint
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - with auth and pagination."""

from auth import authenticate, get_token
from pagination import paginate

def get_users(token, page=1, per_page=10):
    if not authenticate(token):
        raise PermissionError("Invalid token")
    users = [{"id": i, "name": f"User {i}"} for i in range(1, 101)]
    return paginate(users, page, per_page)

def get_products():
    return [{"id": 1, "name": "Widget", "price": 9.99}]
EOF
cat > pagination.py <<'EOF'
"""Pagination utility."""
def paginate(items, page, per_page):
    start = (page - 1) * per_page
    end = start + per_page
    return {
        "items": items[start:end],
        "total": len(items),
        "page": page,
        "per_page": per_page,
    }
EOF
git add .
git commit -m "feat(2/5): add pagination to users"

# Commit 3: Add caching layer (THIS is the one we'll cherry-pick)
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - with auth, pagination, and caching."""

from auth import authenticate, get_token
from pagination import paginate
from cache import cached, invalidate_cache

@cached(ttl=300)
def get_users(token, page=1, per_page=10):
    if not authenticate(token):
        raise PermissionError("Invalid token")
    users = [{"id": i, "name": f"User {i}"} for i in range(1, 101)]
    return paginate(users, page, per_page)

@cached(ttl=600)
def get_products():
    return [{"id": 1, "name": "Widget", "price": 9.99}]
EOF
cat > cache.py <<'EOF'
"""Caching module."""
_cache = {}

def cached(ttl=60):
    def decorator(func):
        def wrapper(*args, **kwargs):
            key = f"{func.__name__}:{args}:{kwargs}"
            if key in _cache:
                return _cache[key]
            result = func(*args, **kwargs)
            _cache[key] = result
            return result
        return wrapper
    return decorator

def invalidate_cache(prefix=None):
    global _cache
    if prefix:
        _cache = {k: v for k, v in _cache.items() if not k.startswith(prefix)}
    else:
        _cache = {}
EOF
git add .
git commit -m "feat(3/5): add caching layer with TTL"

# Commit 4: Add rate limiting
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - with auth, pagination, caching, and rate limiting."""

from auth import authenticate, get_token
from pagination import paginate
from cache import cached, invalidate_cache
from ratelimit import rate_limit

@rate_limit(calls=100, period=60)
@cached(ttl=300)
def get_users(token, page=1, per_page=10):
    if not authenticate(token):
        raise PermissionError("Invalid token")
    users = [{"id": i, "name": f"User {i}"} for i in range(1, 101)]
    return paginate(users, page, per_page)

@rate_limit(calls=200, period=60)
@cached(ttl=600)
def get_products():
    return [{"id": 1, "name": "Widget", "price": 9.99}]
EOF
cat > ratelimit.py <<'EOF'
"""Rate limiting module."""
import time

_calls = {}

def rate_limit(calls=100, period=60):
    def decorator(func):
        def wrapper(*args, **kwargs):
            key = func.__name__
            now = time.time()
            if key not in _calls:
                _calls[key] = []
            _calls[key] = [t for t in _calls[key] if t > now - period]
            if len(_calls[key]) >= calls:
                raise RuntimeError("Rate limit exceeded")
            _calls[key].append(now)
            return func(*args, **kwargs)
        return wrapper
    return decorator
EOF
git add .
git commit -m "feat(4/5): add rate limiting"

# Commit 5: Add logging
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - full featured."""

import logging
from auth import authenticate, get_token
from pagination import paginate
from cache import cached, invalidate_cache
from ratelimit import rate_limit

logger = logging.getLogger(__name__)

@rate_limit(calls=100, period=60)
@cached(ttl=300)
def get_users(token, page=1, per_page=10):
    logger.info(f"get_users called: page={page}")
    if not authenticate(token):
        logger.warning("Authentication failed")
        raise PermissionError("Invalid token")
    users = [{"id": i, "name": f"User {i}"} for i in range(1, 101)]
    return paginate(users, page, per_page)

@rate_limit(calls=200, period=60)
@cached(ttl=600)
def get_products():
    logger.info("get_products called")
    return [{"id": 1, "name": "Widget", "price": 9.99}]
EOF
git add .
git commit -m "feat(5/5): add logging"

# Go back to main and make some parallel development
git checkout main

# main has been updated but doesn't have auth/pagination
cat > api.py <<'EOF'
#!/usr/bin/env python3
"""API module - updated main."""

def get_users():
    """Get users from database."""
    return [
        {"id": 1, "name": "Alice", "role": "admin"},
        {"id": 2, "name": "Bob", "role": "user"},
    ]

def get_products():
    """Get products catalog."""
    return [
        {"id": 1, "name": "Widget", "price": 9.99},
        {"id": 2, "name": "Gadget", "price": 19.99},
    ]

def get_orders():
    """New endpoint: get orders."""
    return [{"id": 1, "user_id": 1, "product_id": 1}]
EOF
git add api.py
git commit -m "main: add roles to users, new get_orders endpoint"

# Now try to cherry-pick commit 3 (caching) — it will fail because
# it depends on commits 1 (auth) and 2 (pagination) which aren't on main
FEATURE_COMMITS=$(git log --oneline feature/full-api | head -5 | tail -1 | awk '{print $1}')
CACHE_COMMIT=$(git log --oneline feature/full-api --reverse | head -4 | tail -1 | awk '{print $1}')

# Attempt cherry-pick that causes conflict
git cherry-pick "$CACHE_COMMIT" 2>/dev/null || true

echo ""
echo "============================================="
echo "🔧 Lab 07: Cherry-pick Conflicts"
echo "============================================="
echo ""
echo "📁 Lab directory: $LAB_DIR"
echo ""
echo "SCENARIO:"
echo "  You're on 'main' branch and want to cherry-pick ONLY the"
echo "  caching feature (commit 3/5) from 'feature/full-api' branch."
echo ""
echo "  However, commit 3 depends on commits 1 (auth) and 2 (pagination)."
echo "  The cherry-pick has failed with conflicts because the caching"
echo "  commit references imports and functions that don't exist on main."
echo ""
echo "YOUR TASK:"
echo "  cd $LAB_DIR"
echo "  Either:"
echo "  a) Resolve the cherry-pick conflict to add caching on main"
echo "  b) Or cherry-pick commits 1, 2, AND 3 in order"
echo ""
echo "COMMANDS TO START:"
echo "  cd $LAB_DIR"
echo "  git status            # Mid cherry-pick"
echo "  cat api.py            # See conflicts"
echo "  git log --oneline feature/full-api  # See all feature commits"
echo ""
