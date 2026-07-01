# Solution: Lab 14 - Nginx Lua Scripting Issues

## Problem

Nginx with Lua module (OpenResty) fails with errors like "no cosocket available",
shared dictionary overflow, or extremely poor performance.

## Diagnosis

```bash
# Check nginx error log
docker compose logs nginx | grep "lua\|cosocket\|shared_dict"

# Common errors:
# "API disabled in the context of init_by_lua"
# "no memory" in shared_dict
# "lua_code_cache is off" (development setting left in production)

# Check configuration
grep -A5 "lua\|shared_dict\|content_by_lua\|init_by_lua" nginx.conf
```

## Root Cause

Three issues:
1. **Cosocket in wrong phase**: HTTP cosocket API (used for redis/http calls) is used
   in `init_by_lua` or `log_by_lua` where it's not available. Must use `access_by_lua`
   or `content_by_lua`.
2. **Shared dict too small**: The `lua_shared_dict` is sized too small, causing "no
   memory" errors when it fills up.
3. **`lua_code_cache off`**: Disables Lua code caching — every request re-compiles
   Lua code, causing massive performance degradation.

## Fix

Edit `nginx.conf`:

```nginx
http {
    # BROKEN:  lua_shared_dict my_cache 1m;
    # FIXED:   Increase shared dict size
    lua_shared_dict my_cache 64m;

    # BROKEN:  lua_code_cache off;
    # FIXED:   Enable code caching (MUST be on in production)
    lua_code_cache on;

    server {
        # BROKEN: Using cosocket in init_by_lua
        # init_by_lua_block {
        #     local redis = require "resty.redis"
        #     local red = redis:new()
        #     red:connect("127.0.0.1", 6379)  -- ERROR: no cosocket here!
        # }

        # FIXED: Move cosocket operations to access_by_lua
        location / {
            access_by_lua_block {
                local redis = require "resty.redis"
                local red = redis:new()
                red:connect("127.0.0.1", 6379)
                -- perform auth check here
            }
            proxy_pass http://backend;
        }
    }
}
```

Then reload:

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Test requests work without Lua errors
curl http://localhost/

# Check error log for Lua issues
docker compose logs nginx | grep -i "lua\|error" | tail -10

# Performance test (should be fast with code_cache on)
ab -n 1000 -c 50 http://localhost/
```

## Key Takeaways

- Cosocket API only works in: `rewrite_by_lua`, `access_by_lua`, `content_by_lua`
- Never use `lua_code_cache off` in production — causes 100x slowdown
- Size `lua_shared_dict` for your expected data volume
- Use `init_by_lua` only for pure-Lua setup (no I/O, no cosocket)
