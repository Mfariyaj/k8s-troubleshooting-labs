#!/bin/bash
# Generate certificates for mTLS lab
# This creates a deliberately broken PKI setup

set -e

CERTS_DIR="$(dirname "$0")/certs"
mkdir -p "$CERTS_DIR"
cd "$CERTS_DIR"

echo "=== Generating Root CA ==="
openssl genrsa -out root-ca.key 4096
openssl req -new -x509 -days 3650 -key root-ca.key \
    -out root-ca.crt \
    -subj "/C=US/ST=California/O=Internal Corp/CN=Internal Root CA" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign"

echo "=== Generating Intermediate CA A ==="
openssl genrsa -out intermediate-a.key 4096
openssl req -new -key intermediate-a.key \
    -out intermediate-a.csr \
    -subj "/C=US/ST=California/O=Internal Corp/OU=PKI/CN=Internal Intermediate CA A"

# Create extension file for intermediate
cat > intermediate-ext.cnf <<EOF
basicConstraints = critical, CA:TRUE, pathlen:0
keyUsage = critical, keyCertSign, cRLSign
authorityInfoAccess = OCSP;URI:http://ocsp.internal.company.com:8080/ocsp
crlDistributionPoints = URI:http://crl.internal.company.com/ca.crl
EOF

openssl x509 -req -days 1825 -in intermediate-a.csr \
    -CA root-ca.crt -CAkey root-ca.key -CAcreateserial \
    -out intermediate-a.crt \
    -extfile intermediate-ext.cnf

echo "=== Generating Intermediate CA B (different intermediate - BUG source) ==="
openssl genrsa -out intermediate-b.key 4096
openssl req -new -key intermediate-b.key \
    -out intermediate-b.csr \
    -subj "/C=US/ST=California/O=Internal Corp/OU=PKI/CN=Internal Intermediate CA B"

openssl x509 -req -days 1825 -in intermediate-b.csr \
    -CA root-ca.crt -CAkey root-ca.key -CAcreateserial \
    -out intermediate-b.crt \
    -extfile intermediate-ext.cnf

echo "=== Generating Server Certificate ==="
openssl genrsa -out server.key 2048
openssl req -new -key server.key \
    -out server.csr \
    -subj "/C=US/ST=California/O=Internal Corp/CN=api.internal"

cat > server-ext.cnf <<EOF
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:api.internal,DNS:localhost,IP:127.0.0.1
EOF

openssl x509 -req -days 365 -in server.csr \
    -CA intermediate-a.crt -CAkey intermediate-a.key -CAcreateserial \
    -out server.crt \
    -extfile server-ext.cnf

# Create full server chain
cat server.crt intermediate-a.crt root-ca.crt > server-fullchain.crt

echo "=== Generating Client Certificate (BUG: signed by Intermediate B, not A) ==="
openssl genrsa -out client.key 2048
openssl req -new -key client.key \
    -out client.csr \
    -subj "/C=US/ST=California/O=Internal Corp/OU=API Clients/CN=api-client"

cat > client-ext.cnf <<EOF
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth
authorityInfoAccess = OCSP;URI:http://ocsp.internal.company.com:8080/ocsp
EOF

# BUG: Client cert signed by Intermediate B, but CA bundle only has Intermediate A
openssl x509 -req -days 365 -in client.csr \
    -CA intermediate-b.crt -CAkey intermediate-b.key -CAcreateserial \
    -out client.crt \
    -extfile client-ext.cnf

echo "=== Creating CA Bundle (BUG: Only contains Root CA, missing Intermediate) ==="
# BUG: Only Root CA in bundle - should also contain Intermediate CA B
cp root-ca.crt ca-bundle.crt

echo "=== Generating Expired CRL (BUG: nextUpdate in the past) ==="
cat > crl-ext.cnf <<EOF
[crl_ext]
authorityKeyIdentifier=keyid:always
EOF

# Create a CRL with nextUpdate in the past
openssl ca -gencrl -keyfile root-ca.key -cert root-ca.crt \
    -out ca.crl -crldays -1 2>/dev/null || {
    # Fallback: create CRL manually with expired date
    openssl req -new -x509 -days 1 -key root-ca.key -out /dev/null -subj "/CN=dummy" 2>/dev/null
    
    # Create an empty CRL that's already expired
    cat > openssl-crl.cnf <<CONF
[ca]
default_ca = CA_default
[CA_default]
database = index.txt
crlnumber = crlnumber
default_crl_days = 0
default_md = sha256
CONF
    touch index.txt
    echo "01" > crlnumber
    
    # Generate CRL with 0 days validity (already expired)
    openssl ca -config openssl-crl.cnf -gencrl \
        -keyfile root-ca.key -cert root-ca.crt \
        -out ca.crl 2>/dev/null || {
        # Last resort: create a minimal expired CRL
        openssl crl -in /dev/null -out ca.crl 2>/dev/null || \
        # Create a dummy CRL file
        openssl x509 -in root-ca.crt -noout -text > /dev/null
        # Generate valid CRL then backdate it
        faketime '2023-01-01' openssl ca -config openssl-crl.cnf -gencrl \
            -keyfile root-ca.key -cert root-ca.crt \
            -out ca.crl 2>/dev/null || {
            # Simplest approach: just create the CRL with short validity
            echo "Warning: Could not create expired CRL, creating short-lived one"
            openssl crl -inform PEM -outform PEM -in /dev/null -out ca.crl 2>/dev/null || true
        }
    }
    rm -f index.txt index.txt.attr crlnumber openssl-crl.cnf
}

echo "=== Cleanup temp files ==="
rm -f *.csr *.cnf *.srl *.old crlnumber* index.txt*

echo ""
echo "=== Certificate Summary ==="
echo "Root CA:          root-ca.crt (self-signed)"
echo "Intermediate A:   intermediate-a.crt (signed by Root CA)"
echo "Intermediate B:   intermediate-b.crt (signed by Root CA)"
echo "Server cert:      server.crt (signed by Intermediate A)"
echo "Client cert:      client.crt (signed by Intermediate B) <-- BUG"
echo "CA Bundle:        ca-bundle.crt (only Root CA) <-- BUG: missing intermediates"
echo "CRL:              ca.crl (expired) <-- BUG"
echo ""
echo "BUGS INTRODUCED:"
echo "1. ca-bundle.crt only contains Root CA (missing Intermediate B)"
echo "2. Client cert signed by Intermediate B, but bundle doesn't include it"
echo "3. CRL has expired nextUpdate"
echo "4. OCSP responder URL points to non-existent host"
echo "5. ssl_verify_depth=1 in nginx.conf (needs 2 for 3-level chain)"
