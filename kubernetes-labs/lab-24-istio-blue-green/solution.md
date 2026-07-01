# Solution: Istio Blue-Green Deployment Broken

## Root Cause

Three issues prevent the blue-green switch:

1. **VirtualService still points to 'blue'**: The VirtualService route destination subset is `blue` with weight 100. It was never updated to `green` for the switch.

2. **DestinationRule green subset label is wrong**: The green subset uses `colour: green` (British spelling) but the pods have `color: green` (American spelling). No pods match the green subset.

3. **Service selector too broad**: The Kubernetes Service selector only uses `app: frontend`, which matches both blue and green pods. Without proper Istio subset routing, traffic round-robins across all pods.

## Fix Steps

### Step 1: Fix VirtualService to point to green

Change `subset: blue` to `subset: green`.

### Step 2: Fix DestinationRule green subset label

Change `colour: green` to `color: green` to match actual pod labels.

### Step 3: (Optional) Narrow the Service selector

While Istio subsets handle the routing, keeping the Service selector broad is fine for blue-green as long as Istio routing is correctly configured.

### Corrected Configuration

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-bluegreen
  namespace: lab-24-bluegreen
spec:
  hosts:
  - frontend
  http:
  - route:
    - destination:
        host: frontend
        subset: green
      weight: 100
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: frontend-destinationrule
  namespace: lab-24-bluegreen
spec:
  host: frontend
  subsets:
  - name: blue
    labels:
      color: blue
  - name: green
    labels:
      color: green
```

## Verification

```bash
# Verify routing points to green
kubectl get virtualservice frontend-bluegreen -n lab-24-bluegreen -o jsonpath='{.spec.http[0].route[0].destination.subset}'

# Verify green subset label matches pods
kubectl get pods -n lab-24-bluegreen -l color=green

# Test routing
kubectl exec deploy/frontend-blue -n lab-24-bluegreen -- curl -s http://frontend

# Verify only green pods receive traffic
istioctl proxy-config routes deploy/frontend-green -n lab-24-bluegreen

# Analyze
istioctl analyze -n lab-24-bluegreen
```
