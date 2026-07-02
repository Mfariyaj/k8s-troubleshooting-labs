## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 17: Pod Disruption Budget Blocking Node Drain

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your organization is performing a Kubernetes cluster upgrade from 1.27 to 1.28. The upgrade
process requires draining each node one at a time. However, `kubectl drain` hangs indefinitely
on the first worker node. The SRE team notices that PodDisruptionBudgets are blocking all
evictions. Two critical services — order-processor and inventory-service — have PDBs that
make it mathematically impossible to evict any pods. The upgrade window closes in 2 hours.

## Symptoms

```bash
$ kubectl drain worker-node-1 --ignore-daemonsets --delete-emptydir-data
node/worker-node-1 cordoned
evicting pod lab-17-pdb/order-processor-7f8b9c6d4f-abc12
evicting pod lab-17-pdb/inventory-service-5d4c3b2a1f-def34
error when evicting pods/"order-processor-7f8b9c6d4f-abc12" -n "lab-17-pdb" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
error when evicting pods/"inventory-service-5d4c3b2a1f-def34" -n "lab-17-pdb" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
^C  (hangs forever)

$ kubectl get pdb -n lab-17-pdb
NAME                    MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
order-processor-pdb     3               N/A               0                     10m
inventory-service-pdb   N/A             0                 0                     10m

$ kubectl get pods -n lab-17-pdb
NAME                                READY   STATUS    RESTARTS   AGE
order-processor-7f8b9c6d4f-abc12    1/1     Running   0          10m
order-processor-7f8b9c6d4f-ghi56    1/1     Running   0          10m
order-processor-7f8b9c6d4f-jkl78    1/1     Running   0          10m
inventory-service-5d4c3b2a1f-def34  1/1     Running   0          10m
inventory-service-5d4c3b2a1f-mno90  1/1     Running   0          10m
```

## Error Output

```bash
$ kubectl evict pod order-processor-7f8b9c6d4f-abc12 -n lab-17-pdb
Error from server: Cannot evict pod as it would violate the pod's disruption budget.

$ kubectl get events -n lab-17-pdb --field-selector reason=FailedEviction
LAST SEEN   TYPE      REASON           OBJECT                                  MESSAGE
30s         Warning   FailedEviction   pod/order-processor-7f8b9c6d4f-abc12    Cannot evict pod as it would violate the pod's disruption budget.
```

## Hints

<details>
<summary>Hint 1 (Conceptual)</summary>
A PodDisruptionBudget with minAvailable equal to the total number of replicas means zero disruptions are allowed — no pod can ever be evicted voluntarily. Similarly, maxUnavailable: 0 means the same thing. Check the ALLOWED DISRUPTIONS column in `kubectl get pdb`.
</details>

<details>
<summary>Hint 2 (Direction)</summary>
The order-processor has 3 replicas and minAvailable: 3, giving 0 allowed disruptions. The inventory-service has maxUnavailable: 0, also giving 0 allowed disruptions. You need to relax these constraints while maintaining some level of availability guarantee during the drain operation.
</details>

<details>
<summary>Hint 3 (Solution Path)</summary>
Fix by: (1) For order-processor, change minAvailable to 2 (or use a percentage like "66%") — this allows 1 disruption at a time. (2) For inventory-service, change maxUnavailable to 1. (3) Alternatively, temporarily scale up order-processor to 4 replicas so that minAvailable: 3 allows 1 disruption. After the drain, restore original PDB settings.
</details>

## Troubleshooting Commands

```bash
# List all PDBs in the namespace
kubectl get pdb -n lab-17-pdb

# Describe PDBs to see current vs allowed disruptions
kubectl describe pdb order-processor-pdb -n lab-17-pdb
kubectl describe pdb inventory-service-pdb -n lab-17-pdb

# Check how many replicas each deployment has
kubectl get deployments -n lab-17-pdb

# Check pod distribution across nodes
kubectl get pods -n lab-17-pdb -o wide

# View PDB spec in YAML
kubectl get pdb order-processor-pdb -n lab-17-pdb -o yaml

# Check allowed disruptions (0 means no eviction possible)
kubectl get pdb -n lab-17-pdb -o jsonpath='{range .items[*]}{.metadata.name}: allowed={.status.disruptionsAllowed}, current={.status.currentHealthy}, desired={.status.desiredHealthy}{"\n"}{end}'

# Try to evict a pod manually (will fail)
kubectl evict pod $(kubectl get pods -n lab-17-pdb -l app=order-processor -o jsonpath='{.items[0].metadata.name}') -n lab-17-pdb

# Check node status
kubectl get nodes

# Check if any nodes are already cordoned
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# View the deployment strategy (maxUnavailable: 0 compounds the issue)
kubectl get deployment order-processor -n lab-17-pdb -o jsonpath='{.spec.strategy}'

# Simulate drain in dry-run mode
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --dry-run=client
```

## Expected Resolution Time: 15-30 minutes

## What You'll Learn

- How PodDisruptionBudgets interact with voluntary disruptions (drain, eviction)
- Mathematical relationship between replicas, minAvailable, and allowed disruptions
- The difference between minAvailable and maxUnavailable
- Strategies for handling PDBs during cluster upgrades
- How to safely relax PDBs without causing downtime
- The relationship between deployment strategy and PDB constraints
