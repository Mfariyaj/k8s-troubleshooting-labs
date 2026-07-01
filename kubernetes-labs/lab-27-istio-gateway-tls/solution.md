# Solution: Istio Gateway TLS Termination Broken

## Root Cause

Four issues prevent TLS termination from working:

1. **Secret in wrong namespace**: The TLS secret `secure-app-tls-cert` is in `lab-27-gateway-tls` namespace, but the ingress gateway runs in `istio-system`. Gateway TLS credentials must be in the same namespace as the gateway pod.

2. **`credentialName` references non-existent secret**: The Gateway uses `credentialName: tls-secret-missing`, but the actual secret is named `secure-app-tls-cert`. Even if it were in the right namespace, the name doesn't match.

3. **Host mismatch between Gateway and VirtualService**: Gateway hosts `secure.example.com` but VirtualService hosts `app.example.com`. The VirtualService host must be a subset of the Gateway's hosts for the route to bind.

4. **TLS mode SIMPLE requires both cert and key**: While the secret has both, the credential name mismatch means the gateway finds no certificate, causing TLS handshake failures.

## Fix Steps

### Step 1: Create the secret in istio-system namespace

```bash
kubectl create secret tls secure-app-tls-cert \
  --cert=path/to/tls.crt \
  --key=path/to/tls.key \
  -n istio-system
```

### Step 2: Fix credentialName to match the secret

### Step 3: Align hosts between Gateway and VirtualService

### Corrected Configuration

```yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: secure-gateway
  namespace: lab-27-gateway-tls
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: secure-app-tls-cert
    hosts:
    - "secure.example.com"
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: secure-app-vs
  namespace: lab-27-gateway-tls
spec:
  hosts:
  - "secure.example.com"
  gateways:
  - secure-gateway
  http:
  - route:
    - destination:
        host: secure-app
        port:
          number: 80
```

And move the secret to istio-system:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secure-app-tls-cert
  namespace: istio-system
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>
```

## Verification

```bash
# Verify secret in istio-system
kubectl get secret secure-app-tls-cert -n istio-system

# Check gateway status
istioctl proxy-config listeners -n istio-system deploy/istio-ingressgateway

# Test TLS connection
curl -k -H "Host: secure.example.com" https://<INGRESS_IP>

# Analyze for issues
istioctl analyze -n lab-27-gateway-tls

# Check gateway logs for certificate errors
kubectl logs -n istio-system -l istio=ingressgateway | grep -i "tls\|cert\|error"
```
