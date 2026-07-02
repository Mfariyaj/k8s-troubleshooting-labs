## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 33: Istio ServiceEntry for External Services Not Working

## Difficulty: ⭐⭐⭐⭐

## Scenario

Your application needs to call an external REST API at `api.external-service.com` over HTTPS (port 443). You've configured a ServiceEntry to register this external service with Istio, but pods can't reach the external API. Requests timeout or fail with connection errors.

## Expected Symptoms

- Requests to `api.external-service.com` timeout or fail immediately
- DNS resolution errors for external hostname
- `curl https://api.external-service.com` from pods returns connection refused
- Outbound traffic is silently dropped
- No upstream cluster found in Envoy

## Your Task

Fix the ServiceEntry and related configurations to allow egress traffic to the external API.

## Hints

<details>
<summary>Hint 1</summary>
Check the `location` field. An external service (not part of your mesh) should be `MESH_EXTERNAL`, not `MESH_INTERNAL`. Setting it as internal tells Istio to expect a pod backing this service within the mesh.
</details>

<details>
<summary>Hint 2</summary>
Look at the `ports.protocol` field. Port 443 with HTTPS traffic should have protocol `TLS` or `HTTPS`, not `HTTP`. Protocol mismatch causes the proxy to handle the connection incorrectly.
</details>

<details>
<summary>Hint 3</summary>
When `outboundTrafficPolicy.mode` is `REGISTRY_ONLY`, only services registered in the mesh (including ServiceEntries) can be accessed. Also check the Sidecar's egress hosts - if it doesn't include the external namespace, the ServiceEntry won't be visible.
</details>

## Useful Commands

```bash
# Check ServiceEntry
kubectl get serviceentry -n lab-33-serviceentry -o yaml

# Check Sidecar config
kubectl get sidecar -n lab-33-serviceentry -o yaml

# Test external connectivity
kubectl exec deploy/app-service -n lab-33-serviceentry -- curl -s -o /dev/null -w "%{http_code}" https://api.external-service.com

# Check proxy clusters for external service
istioctl proxy-config clusters deploy/app-service -n lab-33-serviceentry | grep external

# Check listeners
istioctl proxy-config listeners deploy/app-service -n lab-33-serviceentry | grep 443

# Analyze
istioctl analyze -n lab-33-serviceentry
```
