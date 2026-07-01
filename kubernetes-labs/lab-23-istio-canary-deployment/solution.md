# Solution: Istio Canary Deployment Broken

## Root Cause

Three issues prevent the canary traffic split from working:

1. **Weights don't sum to 100**: The VirtualService has weight:90 for v1 and weight:20 for v2 (total 110). Istio requires weights to sum to exactly 100.

2. **Pod labels mismatch for v2**: The v2 deployment uses `app-version: v2` as its label, but the DestinationRule subset expects `version: v2`. This means even if the subset were defined, no pods would match it.

3. **Missing v2 subset in DestinationRule**: The DestinationRule only defines the `v1` subset. The `v2` subset referenced in the VirtualService doesn't exist, causing 503 errors.

## Fix Steps

### Step 1: Fix the v2 deployment labels

Change `app-version: v2` to `version: v2` in the deployment pod template.

### Step 2: Add v2 subset to DestinationRule

Add the missing `v2` subset definition with the label `version: v2`.

### Step 3: Fix the weights

Change weights to 90 + 10 = 100.

### Corrected Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-api-v2
  namespace: lab-23-canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: product-api
      version: v2
  template:
    metadata:
      labels:
        app: product-api
        version: v2
    spec:
      containers:
      - name: product-api
        image: nginx:1.25
        ports:
        - containerPort: 80
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: product-api-canary
  namespace: lab-23-canary
spec:
  hosts:
  - product-api
  http:
  - route:
    - destination:
        host: product-api
        subset: v1
      weight: 90
    - destination:
        host: product-api
        subset: v2
      weight: 10
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: product-api-destinationrule
  namespace: lab-23-canary
spec:
  host: product-api
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
```

## Verification

```bash
# Verify weights sum to 100
kubectl get virtualservice product-api-canary -n lab-23-canary -o jsonpath='{.spec.http[0].route[*].weight}'

# Verify subsets exist
kubectl get destinationrule -n lab-23-canary -o jsonpath='{.items[0].spec.subsets[*].name}'

# Verify pod labels match subset selectors
kubectl get pods -n lab-23-canary --show-labels | grep v2

# Test traffic distribution (run multiple times)
for i in $(seq 1 20); do
  kubectl exec deploy/product-api-v1 -n lab-23-canary -- curl -s http://product-api
done

# Analyze for issues
istioctl analyze -n lab-23-canary
```
