## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 27: Istio Gateway TLS Termination Broken

## Difficulty: ⭐⭐⭐⭐⭐

## Scenario

Your team configured an Istio Gateway for TLS termination to serve `secure-app` over HTTPS. Users report 503 errors, certificate errors, and SNI mismatch warnings when trying to access the application through the ingress gateway.

## Expected Symptoms

- 503 Service Unavailable when accessing via HTTPS
- TLS handshake failures
- Certificate not found errors in gateway logs
- SNI mismatch between client request and gateway configuration
- `istioctl analyze` reports host mismatches

## Your Task

Diagnose the TLS/Gateway configuration issues and fix them to enable proper HTTPS access.

## Hints

<details>
<summary>Hint 1</summary>
Check the `credentialName` in the Gateway. This references a Kubernetes Secret that must exist in the `istio-system` namespace (where the ingress gateway runs), not in the application namespace.
</details>

<details>
<summary>Hint 2</summary>
The `hosts` field in the Gateway server must match or be a superset of the hosts in the VirtualService. If Gateway says `secure.example.com` but VirtualService says `app.example.com`, routing won't work.
</details>

<details>
<summary>Hint 3</summary>
Verify the TLS secret is properly formatted with both `tls.crt` and `tls.key`. Also ensure the secret name matches what the Gateway's `credentialName` references.
</details>

## Useful Commands

```bash
# Check Gateway config
kubectl get gateway -n lab-27-gateway-tls -o yaml

# Check VirtualService hosts
kubectl get virtualservice -n lab-27-gateway-tls -o yaml

# Check for secrets in istio-system
kubectl get secrets -n istio-system | grep tls

# Check secrets in app namespace
kubectl get secrets -n lab-27-gateway-tls

# Analyze configuration
istioctl analyze -n lab-27-gateway-tls

# Check gateway proxy logs
kubectl logs -n istio-system -l istio=ingressgateway --tail=50

# Check gateway listeners
istioctl proxy-config listeners -n istio-system deploy/istio-ingressgateway
```
