# Solution: Lab 02 - SSL Certificate Errors

## Problem

Nginx fails to start or clients get SSL errors when connecting. The TLS handshake
fails with certificate/key mismatch errors.

## Diagnosis

```bash
# Check nginx error log
nginx -t 2>&1
docker compose logs nginx

# Verify the certificate and key match
openssl x509 -noout -modulus -in /etc/nginx/ssl/server.crt | md5sum
openssl rsa -noout -modulus -in /etc/nginx/ssl/server.key | md5sum

# Check certificate details
openssl x509 -noout -text -in /etc/nginx/ssl/server.crt | grep -A1 "Subject:"

# Test TLS connection
openssl s_client -connect localhost:443 -servername example.com
```

## Root Cause

The SSL certificate and private key were generated with different parameters or
belong to different key pairs. The modulus of the certificate doesn't match the
modulus of the private key — nginx refuses to start or TLS handshakes fail.

## Fix

### Generate a matching certificate/key pair with the same CN

```bash
# Generate a new private key and self-signed certificate
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/server.key \
  -out /etc/nginx/ssl/server.crt \
  -subj "/CN=example.com/O=Lab/C=US" \
  -addext "subjectAltName=DNS:example.com,DNS:*.example.com"

# Set proper permissions
chmod 600 /etc/nginx/ssl/server.key
chmod 644 /etc/nginx/ssl/server.crt
```

### Restart nginx

```bash
sudo nginx -t && sudo nginx -s reload
# Or with docker:
docker compose restart nginx
```

## Verification

```bash
# Verify key/cert match
openssl x509 -noout -modulus -in /etc/nginx/ssl/server.crt | md5sum
openssl rsa -noout -modulus -in /etc/nginx/ssl/server.key | md5sum
# Both should output the same hash

# Test TLS connection
curl -k https://localhost/

# Test with openssl
openssl s_client -connect localhost:443 </dev/null 2>/dev/null | grep "Verify"
```

## Key Takeaways

- Certificate and key must be from the same key pair (matching modulus)
- Always test with `nginx -t` before reloading
- Use SAN (Subject Alternative Name) for modern certificate compatibility
- `openssl s_client` is essential for debugging TLS issues
