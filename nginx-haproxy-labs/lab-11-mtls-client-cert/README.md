# Lab 11: Mutual TLS Client Certificate Authentication Failure

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your organization has implemented mutual TLS (mTLS) for a critical internal API gateway. Clients authenticate using X.509 certificates issued by an internal PKI with a 3-level certificate chain (Root CA → Intermediate CA → Client Cert). After a recent PKI rotation, clients are getting `400 Bad Request - No required SSL certificate was sent` or `SSL certificate error` despite having valid certificates.

The security team confirms the certificates are valid, the OCSP responder should be running, and CRL checks are enabled. Multiple issues are compounding to make debugging extremely difficult.

## Architecture

```
Client (with client cert) → Nginx (mTLS termination) → Backend API (port 8080)
                                    |
                                    ├── ssl_client_certificate (CA bundle)
                                    ├── ssl_crl (Certificate Revocation List)
                                    ├── ssl_verify_client on
                                    └── OCSP stapling enabled
```

## What You'll Observe

### nginx -t output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

### Client connection attempt:
```bash
$ curl --cert client.crt --key client.key --cacert ca-bundle.crt https://api.internal:8443/health
curl: (35) error:14094412:SSL routines:ssl3_read_bytes:sslv3 alert bad certificate
```

### Nginx error.log:
```
2024/03/15 10:23:45 [error] 7#7: *1 client SSL certificate verify error: (20:unable to get local issuer certificate) while reading client request headers
2024/03/15 10:23:46 [error] 7#7: *2 OCSP responder timed out (110: Connection timed out) while requesting certificate status, responder: ocsp.internal.company.com
2024/03/15 10:23:47 [error] 7#7: *3 client SSL certificate verify error: (12:CRL has expired) while reading client request headers
2024/03/15 10:23:48 [warn] 7#7: *4 verify depth exceeded, client certificate verification failed
```

### OpenSSL verification:
```bash
$ openssl verify -CAfile ca-bundle.crt client.crt
client.crt: CN = api-client
error 20 at 1 depth lookup: unable to get local issuer certificate
```

## Hints

<details>
<summary>Hint 1</summary>
Check the ssl_client_certificate file - does it contain ALL certificates in the chain needed to verify the client cert? A 3-level chain (Root → Intermediate → Client) requires both the Root CA AND Intermediate CA in the verification bundle.
</details>

<details>
<summary>Hint 2</summary>
The ssl_verify_depth directive controls how many intermediate CAs Nginx will traverse. A 3-level chain needs a verify depth of at least 2 (Root → Intermediate → Client = 2 levels to traverse). A depth of 1 means only direct CA-issued certs are accepted.
</details>

<details>
<summary>Hint 3</summary>
Multiple issues compound here: the CRL has an expired nextUpdate field, the OCSP responder URL is unreachable from the container network, and the client cert was signed by a different intermediate than what's in the trust bundle. Check which intermediate CA actually signed the client certificate.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Check Nginx configuration
docker exec mtls-nginx nginx -t

# View Nginx error logs
docker exec mtls-nginx tail -f /var/log/nginx/error.log

# Test client cert connection
docker exec mtls-nginx curl --cert /certs/client.crt --key /certs/client.key --cacert /certs/ca-bundle.crt -k https://localhost:8443/health

# Verify certificate chain
docker exec mtls-nginx openssl verify -CAfile /certs/ca-bundle.crt -untrusted /certs/intermediate.crt /certs/client.crt

# Inspect the CA bundle
docker exec mtls-nginx openssl x509 -in /certs/ca-bundle.crt -text -noout

# Check certificate issuer
openssl x509 -in certs/client.crt -issuer -noout

# Check CRL validity
openssl crl -in certs/ca.crl -text -noout | grep -A2 "Last Update"

# Verify ssl_verify_depth setting
grep -n "ssl_verify_depth" nginx.conf

# Check OCSP responder accessibility
docker exec mtls-nginx curl -v http://ocsp.internal.company.com:8080/ocsp

# View full certificate chain details
openssl crl2pkcs7 -nocrl -certfile certs/ca-bundle.crt | openssl pkcs7 -print_certs -noout

# Check what intermediate signed the client cert
openssl x509 -in certs/client.crt -text -noout | grep -A1 "Issuer"

# Test with explicit chain
openssl s_client -connect localhost:8443 -cert certs/client.crt -key certs/client.key -CAfile certs/ca-bundle.crt

# Clean up
./cleanup.sh
```

## Root Causes

There are **5 compounding issues** in this lab:

1. **Intermediate CA missing from ssl_client_certificate** — The CA bundle only contains the Root CA, not the Intermediate CA that signed the client cert
2. **ssl_verify_depth=1** — Too shallow for a 3-level chain (needs at least 2)
3. **OCSP responder unreachable** — The OCSP URL points to a non-existent host
4. **CRL expired** — The CRL's nextUpdate has passed, causing rejection
5. **Client cert signed by wrong intermediate** — The client cert was signed by `Intermediate-CA-B` but only `Intermediate-CA-A` is in the trust bundle
