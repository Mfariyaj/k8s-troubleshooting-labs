# Lab 34: Istio Multi-Cluster Connectivity Broken

## Difficulty: ⭐⭐⭐⭐⭐

## Scenario

Your organization runs a multi-cluster Istio mesh. Services in cluster A need to communicate with `backend.production.svc.cluster.local` running in cluster B. The remote service is registered via ServiceEntry, but requests from cluster A timeout. Cross-cluster connectivity is completely broken.

## Expected Symptoms

- Requests to the remote service timeout
- No connectivity between clusters despite ServiceEntry being configured
- Gateway not receiving cross-cluster traffic on expected port
- mTLS handshake failures between clusters
- Trust domain issues preventing identity verification

## Your Task

Diagnose the multi-cluster configuration issues and fix cross-cluster connectivity.

## Hints

<details>
<summary>Hint 1</summary>
Cross-cluster traffic in Istio typically uses port 15443 (the SNI-based routing port). Check if the ServiceEntry endpoints and Gateway are configured for the correct port.
</details>

<details>
<summary>Hint 2</summary>
Cross-cluster communication requires mTLS. If the DestinationRule for the remote service has TLS mode set to DISABLE, the proxy won't establish a secure connection to the remote gateway.
</details>

<details>
<summary>Hint 3</summary>
Verify the remote gateway endpoint address is reachable. Also check that trust domains are shared between clusters — if they differ, mTLS certificates won't be validated across clusters.
</details>

## Useful Commands

```bash
# Check ServiceEntry for remote cluster
kubectl get serviceentry -n lab-34-multicluster -o yaml

# Check DestinationRule TLS settings
kubectl get destinationrule -n lab-34-multicluster -o yaml

# Check Gateway port configuration
kubectl get gateway -n lab-34-multicluster -o yaml

# Check proxy clusters for remote endpoints
istioctl proxy-config clusters deploy/local-frontend -n lab-34-multicluster | grep backend

# Check endpoints
istioctl proxy-config endpoints deploy/local-frontend -n lab-34-multicluster | grep backend

# Test connectivity
kubectl exec deploy/local-frontend -n lab-34-multicluster -- curl -s http://backend.production.svc.cluster.local

# Analyze
istioctl analyze -n lab-34-multicluster
```
