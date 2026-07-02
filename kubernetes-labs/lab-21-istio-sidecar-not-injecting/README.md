## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 21: Istio Sidecar Not Injecting

## Difficulty: ⭐⭐⭐

## Scenario

Your team deployed a web application and expects Istio sidecar proxies to be automatically injected into all pods. However, after deployment, the pods only have 1/1 containers running instead of 2/2 (missing the istio-proxy sidecar). Without the sidecar, the application is outside the service mesh and can't benefit from mTLS, traffic management, or observability features.

## Expected Symptoms

- Pods show `1/1 Running` instead of `2/2 Running`
- `istioctl analyze` reports warnings about missing sidecars
- No Envoy proxy logs for the application pods
- Service not visible in Kiali service mesh visualization
- mTLS not enforced for the application traffic

## Your Task

Diagnose why the Istio sidecar is not being injected and fix the configuration.

## Hints

<details>
<summary>Hint 1</summary>
Check the namespace labels. Istio automatic injection requires a specific label on the namespace.
</details>

<details>
<summary>Hint 2</summary>
Look at the pod template annotations in the deployment. There's an annotation that can override namespace-level injection settings.
</details>

<details>
<summary>Hint 3</summary>
Use `kubectl get namespace <ns> --show-labels` and `kubectl get pods -o jsonpath='{.items[*].metadata.annotations}'` to inspect the current configuration.
</details>

## Useful Commands

```bash
# Check namespace labels
kubectl get namespace lab-21-sidecar --show-labels

# Check if sidecar is present
kubectl get pods -n lab-21-sidecar -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'

# Analyze Istio configuration
istioctl analyze -n lab-21-sidecar

# Check injection status
kubectl get pods -n lab-21-sidecar -o yaml | grep -A5 "annotations"

# Verify Istio webhook configuration
kubectl get mutatingwebhookconfigurations istio-sidecar-injector -o yaml
```
