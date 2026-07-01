# Lab 14: OpenResty/Nginx Lua Module Errors

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your platform team built a dynamic routing layer using OpenResty's Lua modules. The system uses:
- `lua_shared_dict` for route caching and rate limiting
- `set_by_lua_block` for dynamic upstream resolution  
- `access_by_lua_block` for request routing
- `ngx.timer.at` for background route refresh from Consul
- `init_by_lua_block` for startup initialization

After deploying the latest changes, the service either fails to start or crashes with cryptic Lua errors. Some errors are logged, others are silently swallowed.

## Architecture

```
Client → OpenResty (Lua routing) → Backend Services
              │
              ├── init_by_lua_block (startup config)
              ├── set_by_lua_block (upstream resolution)
              ├── access_by_lua_block (routing + rate limit)
              ├── lua_shared_dict (route cache: 1k)
              ├── lua_shared_dict (rate limit: 1k)
              └── ngx.timer.at (background refresh → Consul)
```

## What You'll Observe

### OpenResty fails to start or shows errors:
```
2024/03/15 15:00:01 [error] init_by_lua:4: no request found
```

### Or if it starts, request-time errors:
```
2024/03/15 15:00:05 [error] 7#7: *1 lua entry thread aborted: runtime error: 
  set_by_lua:2: API disabled in the context of set_by_lua*
```

### Shared dict full errors:
```
2024/03/15 15:01:00 [error] 7#7: *45 [lua] access_by_lua:15: Failed to cache route: no memory
2024/03/15 15:01:01 [error] 7#7: *46 [lua] router.lua:78: Rate limit incr failed: no memory
```

### Silent timer callback failures:
```
# These errors DON'T appear in logs - callbacks fail silently!
# Only visible if you add explicit pcall() error handling
# The background route refresh silently dies
```

### curl output:
```bash
$ curl -v http://localhost:8080/api/v1/users
< HTTP/1.1 500 Internal Server Error
< Content-Type: text/html
< 
<html><body><h1>500 Internal Server Error</h1></body></html>
```

## Hints

<details>
<summary>Hint 1</summary>
OpenResty's Lua has strict context limitations. `set_by_lua_block` runs in a "light thread" context where cosocket APIs (ngx.socket.tcp, ngx.socket.udp) are FORBIDDEN. The ngx.socket.tcp() call in set_by_lua must be moved to rewrite_by_lua, access_by_lua, or content_by_lua context. Also, `init_by_lua_block` has NO request context — you cannot access ngx.var, ngx.req, or any request-specific APIs.
</details>

<details>
<summary>Hint 2</summary>
`lua_shared_dict route_cache 1k` is absurdly small. 1 kilobyte fills up after ~10 route entries. When it's full, `set()` returns nil + "no memory". Increase to at least `10m` for route caching and `50m` for rate limiting. Also, `lua_code_cache off` disables LuaJIT compilation, making `ngx.re.match` with the 'j' flag useless.
</details>

<details>
<summary>Hint 3</summary>
`ngx.timer.at` callbacks swallow errors silently — if your callback throws an unhandled error, it simply stops executing with no log entry. Wrap timer callbacks in `pcall()` to catch and log errors. The background route refresh dies silently because the consul connection fails and `error()` is called without pcall protection.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Check if OpenResty started
docker ps | grep lua-nginx
docker logs lua-nginx

# View error logs in detail
docker exec lua-nginx tail -100 /usr/local/openresty/nginx/logs/error.log

# Test basic request
curl -v http://localhost:8080/api/v1/users

# Test health endpoint (may show shared dict stats)
curl -s http://localhost:8080/health | jq .

# Check shared dict memory usage
docker exec lua-nginx curl -s http://localhost/health 2>/dev/null

# Start background refresh (triggers timer bugs)
curl http://localhost:8080/init-workers

# Generate load to exhaust shared dict
for i in $(seq 1 100); do curl -s http://localhost:8080/api/v1/path$i > /dev/null; done

# Check Lua package path
docker exec lua-nginx env | grep LUA

# Verify Lua file is accessible
docker exec lua-nginx ls -la /usr/local/openresty/nginx/lua/

# Test nginx config syntax
docker exec lua-nginx openresty -t

# Check OpenResty version and modules
docker exec lua-nginx openresty -V 2>&1

# Reload after fix
docker exec lua-nginx openresty -s reload

# Monitor error log in real-time
docker exec lua-nginx tail -f /usr/local/openresty/nginx/logs/error.log

# Clean up
./cleanup.sh
```

## Root Causes

There are **5 compounding issues** in this lab:

1. **Cosocket in set_by_lua** — `ngx.socket.tcp()` is forbidden in `set_by_lua_block` context (only available in rewrite/access/content phases)
2. **lua_shared_dict 1k** — Both shared dictionaries are 1KB, far too small; fills up immediately causing "no memory" errors
3. **lua_code_cache off** — Disables LuaJIT compilation, making PCRE JIT (`jo` flag) useless and causing massive performance issues
4. **ngx.timer.at swallows errors** — Background timer callbacks fail silently when `error()` is called without pcall protection
5. **init_by_lua accessing ngx.var** — `ngx.var` is not available in init context (no request exists at startup time)
