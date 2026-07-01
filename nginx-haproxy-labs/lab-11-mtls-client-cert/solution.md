# Solution: Lab 11 - mTLS Client Certificate Verification

## Problem

Client certificate authentication (mTLS) fails with "400 Bad Request - No required
SSL certificate was sent" or "certificate verify failed" even when clients present
valid certificates.

## Diagnosis

```bash
# Test with client certificate
curl --cert client.crt --key client.key --cacert ca.crt https://localhost/

# Check nginx error log
docker compose logs nginx | grep "SSL\|certificate\|verify"

# Verify certificate chain
openssl verify -CAfile ca.crt intermediate.crt
openssl verify -CAfile <(cat ca.crt intermediate.crt) client.crt

# Check nginx mTLS configuration
grep -A5 "ssl_client\|ssl_verify" nginx.conf
```

## Root Cause

Two issues:
1. The `ssl_client_certificate` file only contains the root CA, but client certs
   are signed by an intermediate CA. The full chain must be in the bundle.
2. `ssl_verify_depth` is too low (default 1) to validate the full chain
   (client → intermediate → root = depth 2).

## Fix

### Step 1: Add intermediate CA to the client certificate bundle

```bash
# Create the full CA chain bundle
cat intermediate-ca.crt root-ca.crt > /etc/nginx/ssl/client-ca-chain.crt
```

### Step 2: Update nginx.conf

```nginx
server {
    listen 443 ssl;

    ssl_certificate /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;

    # Use the full CA chain for client verification
    ssl_client_certificate /etc/nginx/ssl/client-ca-chain.crt;
    ssl_verify_client on;

    # BROKEN:  ssl_verify_depth 1;
    # FIXED:   Increase to cover intermediate CA
    ssl_verify_depth 3;
}
```

### Step 3: Reload nginx

```bash
sudo nginx -t && sudo nginx -s reload
```

## Verification

```bash
# Test mTLS connection with client cert
curl --cert client.crt --key client.key \
     --cacert server-ca.crt \
     https://localhost/

# Verify the chain depth
openssl s_client -connect localhost:443 \
  -cert client.crt -key client.key

# Check the verification output for "Verify return code: 0 (ok)"
```

## Key Takeaways

- `ssl_client_certificate` must include ALL CAs in the client cert chain
- `ssl_verify_depth` must be >= number of intermediate CAs + 1
- Order in the CA bundle: intermediate first, root last
- Test with `openssl s_client` to debug certificate chain issues
