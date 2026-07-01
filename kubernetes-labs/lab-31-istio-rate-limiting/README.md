# Lab 31: Istio Rate Limiting Not Working

## Difficulty: ⭐⭐⭐⭐⭐

## Scenario

Your team has configured Istio rate limiting using an EnvoyFilter and an external rate limit service. The goal is to limit API requests to 100 requests per minute per client. However, rate limiting is not functioning:
- Either no requests are being rate-limited (unlimited throughput)
- Or all requests are immediately blocked (429 for every request)

## Expected Symptoms

- No 429 (Too Many Requests) responses even at high traffic
- OR every request returns 429 immediately
- Rate limit service logs show no incoming requests
- EnvoyFilter appears applied but has no effect
- Proxy configuration doesn't show rate limit filter

## Your Task

Diagnose the EnvoyFilter configuration issues and fix rate limiting.

## Hints

<details>
<summary>Hint 1</summary>
Check the EnvoyFilter `applyTo` field. For HTTP-level rate limiting, it should be `HTTP_FILTER`, not `CLUSTER` or `NETWORK_FILTER`. Also check the `context` field.
</details>

<details>
<summary>Hint 2</summary>
Look at the patch `operation`. For adding a new filter to the chain, use `INSERT_BEFORE` (inserts before the reference filter). `MERGE` only updates existing filters and won't add a new one.
</details>

<details>
<summary>Hint 3</summary>
Check the rate limit service address in the EnvoyFilter. If it points to the wrong service name or port, the envoy proxy can't reach the rate limit service. Also verify descriptor entries match the rate limit config.
</details>

## Useful Commands

```bash
# Check EnvoyFilter
kubectl get envoyfilter -n lab-31-ratelimit -o yaml

# Check rate limit service
kubectl get pods -n lab-31-ratelimit -l app=ratelimit

# Check proxy HTTP filters
istioctl proxy-config listeners deploy/api-gateway -n lab-31-ratelimit -o json | jq '.[].filterChains[].filters[].typedConfig.httpFilters[].name'

# Check rate limit configmap
kubectl get configmap ratelimit-config -n lab-31-ratelimit -o yaml

# Test rate limiting
for i in $(seq 1 110); do
  kubectl exec deploy/api-gateway -n lab-31-ratelimit -- curl -s -o /dev/null -w "%{http_code}\n" http://api-backend
done
```
