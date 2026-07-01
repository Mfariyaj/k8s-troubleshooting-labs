# Lab 26: Istio mTLS Strict Mode Breaking Communication

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your team enabled strict mTLS (mutual TLS) across the `lab-26-mtls` namespace to encrypt all service-to-service communication. However, the `api-backend` service can no longer reach the `database` service. Requests from the backend to the database timeout with connection refused errors.

## Expected Symptoms

- `api-backend` → `database` communication fails
- Connection timeout or reset errors
- Database pod shows `1/1` containers (no sidecar)
- `istioctl analyze` reports mTLS conflicts
- PeerAuthentication shows STRICT but some services can't comply

## Your Task

Diagnose the mTLS configuration conflict and fix it so all services can communicate securely.

## Hints

<details>
<summary>Hint 1</summary>
Check if all pods in the namespace have sidecars. A pod without a sidecar cannot participate in mTLS. Look for the `sidecar.istio.io/inject: "false"` annotation.
</details>

<details>
<summary>Hint 2</summary>
When PeerAuthentication is STRICT, all services MUST have sidecars. If a service can't have a sidecar, you need a port-level or workload-specific exception.
</details>

<details>
<summary>Hint 3</summary>
Check the DestinationRule for the database service. If `trafficPolicy.tls.mode` is DISABLE but PeerAuthentication is STRICT, there's a conflict — the client won't send mTLS but the server requires it (or vice versa).
</details>

## Useful Commands

```bash
# Check which pods have sidecars
kubectl get pods -n lab-26-mtls -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'

# Check PeerAuthentication
kubectl get peerauthentication -n lab-26-mtls -o yaml

# Check DestinationRule TLS settings
kubectl get destinationrule -n lab-26-mtls -o yaml

# Analyze mTLS issues
istioctl analyze -n lab-26-mtls

# Check mTLS status
istioctl authn tls-check deploy/api-backend -n lab-26-mtls

# Check proxy TLS configuration
istioctl proxy-config clusters deploy/api-backend -n lab-26-mtls | grep database
```
