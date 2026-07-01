-- router.lua
-- Dynamic routing module for OpenResty
-- Contains multiple intentional bugs

local _M = {}
local cjson = require "cjson"

-- Route definitions (would normally come from service registry)
local routes = {
    { pattern = "^/api/v1/users", target = "http://user-service:8080" },
    { pattern = "^/api/v1/orders", target = "http://order-service:8080" },
    { pattern = "^/api/v1/products", target = "http://product-service:8080" },
    { pattern = "^/api/v2/(.*)", target = "http://v2-gateway:8080" },
    { pattern = "^/internal/(.*)", target = "http://internal-service:8080" },
}

-- BUG: Using ngx.re.match with 'j' (JIT) flag but lua_code_cache is off
-- When lua_code_cache is off, PCRE JIT compiled patterns are discarded every request
-- This causes massive performance degradation and potential regex compilation errors
function _M.resolve(uri)
    if not uri or uri == "" then
        return nil, "empty URI"
    end

    for _, route in ipairs(routes) do
        -- 'jo' flags: j=JIT compile, o=compile-once (useless with code_cache off)
        local m, err = ngx.re.match(uri, route.pattern, "jo")
        if err then
            ngx.log(ngx.ERR, "regex error: ", err, " pattern: ", route.pattern)
            return nil, "regex compilation failed: " .. err
        end
        if m then
            return route.target
        end
    end

    -- Default backend
    return "http://backend:8080"
end

-- Background refresh function
-- BUG: This function uses ngx.socket.tcp() which works in timer context
-- BUT errors from this function are swallowed silently by ngx.timer.at
function _M.refresh()
    local rate_limit = ngx.shared.rate_limit
    
    -- Try to connect to consul for service discovery
    local sock = ngx.socket.tcp()
    sock:settimeout(1000)
    
    local ok, err = sock:connect("consul", 8500)
    if not ok then
        -- This error is swallowed when called from ngx.timer.at callback
        error("Cannot connect to consul: " .. (err or "unknown"))
    end
    
    -- Simulate fetching routes from consul
    local request = "GET /v1/catalog/services HTTP/1.1\r\nHost: consul\r\nConnection: close\r\n\r\n"
    local bytes, err = sock:send(request)
    if not bytes then
        sock:close()
        error("Failed to send to consul: " .. (err or "unknown"))
    end
    
    local data, err = sock:receive("*a")
    sock:close()
    
    if not data then
        error("Failed to read from consul: " .. (err or "unknown"))
    end
    
    -- Parse and update routes
    -- (This would normally parse JSON response)
    ngx.log(ngx.INFO, "Routes refreshed from consul")
    
    -- Try to update shared dict - BUG: will fail with "no memory" if dict is full
    local route_cache = ngx.shared.route_cache
    local ok, err = route_cache:set("_last_refresh", ngx.time())
    if not ok then
        ngx.log(ngx.ERR, "Cannot update refresh timestamp: ", err)
    end
end

-- Rate limiting function using shared dict
function _M.check_rate_limit(key, limit, window)
    local rate_limit = ngx.shared.rate_limit
    
    local current, err = rate_limit:incr(key, 1, 0, window)
    if not current then
        -- BUG: "no memory" error when shared dict (1k) is full
        ngx.log(ngx.ERR, "Rate limit incr failed: ", err)
        return true -- Allow on error (fail-open)
    end
    
    if current > limit then
        return false, current
    end
    
    return true
end

return _M
