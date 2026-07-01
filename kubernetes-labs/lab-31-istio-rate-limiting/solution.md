# Solution: Istio Rate Limiting Not Working

## Root Cause

Four configuration issues with the EnvoyFilter:

1. **`applyTo: CLUSTER` instead of `HTTP_FILTER`**: The rate limit filter is an HTTP filter and must be applied to the HTTP filter chain, not the cluster configuration. Using `CLUSTER` means the filter is never added to the HTTP processing pipeline.

2. **`operation: MERGE` instead of `INSERT_BEFORE`**: MERGE only updates an existing filter. Since the rate limit filter doesn't exist yet, MERGE does nothing. It should be `INSERT_BEFORE` to add the new filter before `envoy.filters.http.router`.

3. **Wrong rate limit service address**: The cluster_name references `ratelimit-wrong.lab-31-ratelimit.svc.cluster.local` instead of `ratelimit-service.lab-31-ratelimit.svc.cluster.local`.

4. **Wrong socket address**: The rate limit cluster endpoint address is `ratelimit-wrong` instead of `ratelimit-service.lab-31-ratelimit.svc.cluster.local`.

## Fix Steps

### Corrected EnvoyFilter

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: ratelimit-filter
  namespace: lab-31-ratelimit
spec:
  workloadSelector:
    labels:
      app: api-gateway
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: SIDECAR_INBOUND
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
            subFilter:
              name: "envoy.filters.http.router"
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.ratelimit
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.http.ratelimit.v3.RateLimit
          domain: api-ratelimit
          failure_mode_deny: false
          rate_limit_service:
            grpc_service:
              envoy_grpc:
                cluster_name: outbound|8081||ratelimit-service.lab-31-ratelimit.svc.cluster.local
            transport_api_version: V3
  - applyTo: CLUSTER
    match:
      context: SIDECAR_OUTBOUND
      cluster:
        service: ratelimit-service.lab-31-ratelimit.svc.cluster.local
    patch:
      operation: ADD
      value:
        name: rate_limit_cluster
        type: STRICT_DNS
        connect_timeout: 10s
        lb_policy: ROUND_ROBIN
        http2_protocol_options: {}
        load_assignment:
          cluster_name: rate_limit_cluster
          endpoints:
          - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: ratelimit-service.lab-31-ratelimit.svc.cluster.local
                    port_value: 8081
```

## Verification

```bash
# Apply corrected EnvoyFilter
kubectl apply -f corrected-envoyfilter.yaml

# Verify HTTP filter is in the chain
istioctl proxy-config listeners deploy/api-gateway -n lab-31-ratelimit -o json | jq '.[].filterChains[].filters[].typedConfig.httpFilters[].name' | grep ratelimit

# Test rate limiting (send 110 requests, last 10 should be 429)
for i in $(seq 1 110); do
  kubectl exec deploy/api-gateway -n lab-31-ratelimit -- curl -s -o /dev/null -w "%{http_code}\n" http://api-backend
done | sort | uniq -c

# Check rate limit service logs
kubectl logs deploy/ratelimit-service -n lab-31-ratelimit
```
