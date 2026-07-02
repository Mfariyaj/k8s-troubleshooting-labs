## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (starts Nginx/HAProxy via docker-compose)
2. Test: `curl -v http://localhost:<port>/` to see the error
3. Check: `docker logs <nginx-container>`, look at error.log
4. Validate: `docker exec <container> nginx -t`
5. Fix nginx.conf/haproxy.cfg and restart
6. Check `solution.md` if stuck

---

# Lab 02: SSL Certificate Errors

## 🎯 Scenario

You've configured Nginx with SSL/TLS to serve HTTPS traffic. However, Nginx refuses to start or immediately drops connections. The SSL certificate and private key files both exist on disk, but something is wrong with the SSL configuration.

**Difficulty:** ⭐⭐ Medium

---

## 🚀 Deploy

```bash
./deploy.sh
```

## 🔍 Observe the Problem

```bash
# Test HTTPS connection
curl -vk https://localhost:8443/

# Check with openssl
openssl s_client -connect localhost:8443

# Expected: Valid SSL handshake and JSON response
# Actual: SSL handshake failure or Nginx won't start
```

### Error Log Output:
```
nginx: [emerg] SSL_CTX_use_PrivateKey_file("/etc/nginx/ssl/wrong-server.key") failed
(SSL: error:0B080074:x509 certificate routines:X509_check_private_key:key values mismatch)
```

### nginx -t Output:
```
nginx: [emerg] SSL_CTX_use_PrivateKey_file("/etc/nginx/ssl/wrong-server.key") failed
nginx: configuration file /etc/nginx/nginx.conf test failed
```

---

## 💡 Hints

<details>
<summary>Hint 1</summary>
An SSL certificate and its private key must be a matching pair. They are cryptographically linked. Check if they match.
</details>

<details>
<summary>Hint 2</summary>
You can verify if a cert and key match by comparing their modulus:
`openssl x509 -noout -modulus -in cert.crt | openssl md5`
`openssl rsa -noout -modulus -in key.key | openssl md5`
</details>

<details>
<summary>Hint 3</summary>
Look at the filenames carefully. Is the key file the correct one? Check what other key files exist in the ssl/ directory.
</details>

---

## 🛠️ Useful Commands

```bash
# Check nginx config
docker-compose logs nginx

# Verify certificate details
openssl x509 -noout -text -in ssl/server.crt

# Compare cert and key modulus
openssl x509 -noout -modulus -in ssl/server.crt | openssl md5
openssl rsa -noout -modulus -in ssl/wrong-server.key | openssl md5

# List all files in ssl directory
ls -la ssl/

# Test SSL connection
openssl s_client -connect localhost:8443 -servername localhost
```

---

## 🧹 Cleanup

```bash
./cleanup.sh
```
