## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 06: Blue-Green Rollback — Red/Black Deployment Rollback Fails

## Difficulty: 🟡 Intermediate

---

## 📚 What You'll Learn

In Spinnaker, **Red/Black** deployment (also called Blue-Green) works by:
1. Deploying a new **Server Group** (the "Red" or new version)
2. Enabling the new server group (adding it to the load balancer)
3. Disabling the old server group (removing from load balancer, but keeping instances alive)

The key benefit: **instant rollback** by re-enabling the old server group and disabling the new one.

However, rollback fails when:
- The old server group was **destroyed** instead of disabled (Highlander strategy was used accidentally)
- The rollback stage targets the wrong cluster name
- `maxRemainingAsgs` or shrink rules deleted the previous version
- The rollback stage uses `explicit` mode but references a non-existent server group

Spinnaker's rollback mechanisms:
- **Automatic rollback** (on pipeline failure): Configured at the Deploy stage level
- **Manual rollback**: Via the Clusters view in the UI
- **Rollback stage**: Explicit pipeline stage that rolls back to N-1 version

---

## 🔧 Scenario

A Red/Black deployment pipeline succeeds, but when a problem is detected post-deployment and the Rollback stage is triggered, it fails. The issues are:

1. The pipeline's `shrinkCluster` stage has `allowDeleteActive: true` and `retainLargerOverNewer: false`, which deleted the previous server group
2. The Rollback stage references the cluster as `myapp-prod` but the actual cluster name is `myapp-production` (Spinnaker uses app-stack-detail naming)
3. The rollback `targetHealthyRollbackPercentage` is set to 100 but the previous ASG was scaled to 0 before deletion

---

## 💥 Expected Error Output

```
Stage: Rollback Production
Status: TERMINAL (Failed)

Error:
  - Could not find cluster 'myapp-prod' in account 'my-k8s-account'
    Available clusters: [myapp-production]
    
  - Cannot rollback: no previous server group found for cluster 
    'myapp-production'. The previous server group may have been 
    deleted by a shrink/cleanup stage.
    
  - Rollback target server group 'myapp-production-v001' not found.
    Only active server group is 'myapp-production-v002'.
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check the Rollback stage's `cluster` parameter. Does it match the exact Spinnaker cluster name (app-stack-detail format)?
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Look at the Shrink Cluster stage that runs before rollback becomes possible. With `allowDeleteActive: true` and `shrinkToSize: 1`, it destroys older server groups. Remove the shrink stage or change settings.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Fixes: 1) Change cluster name from `myapp-prod` to `myapp-production`, 2) Either remove the Shrink Cluster stage or set `retainLargerOverNewer: true` and increase `shrinkToSize` to 2 (keep at least one old version), 3) Add `maxRemainingAsgs: 2` to the deploy stage to preserve rollback targets.
</details>

---

## 🛠️ Useful Commands

```bash
# List server groups in a cluster
curl http://localhost:8084/applications/myapp/serverGroups | jq '.[].name'

# Check cluster configuration
curl http://localhost:8084/applications/myapp/clusters | jq .

# View pipeline execution for the deploy
spin pipeline execution list --application myapp

# Check what server groups exist
kubectl get replicasets -n production -l app=myapp

# View Orca logs for rollback failures
kubectl logs -n spinnaker spin-orca-xxx | grep -i "rollback\|shrink"
```

---

## 📖 References

- https://spinnaker.io/docs/guides/user/kubernetes-v2/rollback/
- https://spinnaker.io/docs/reference/pipeline/stages/#rollback-cluster
- https://spinnaker.io/docs/guides/user/deploying-applications/

---

## 🏁 Success Criteria

- Previous server group is preserved after deployment
- Rollback stage can find and re-enable the old server group
- Rollback completes and traffic shifts back to the previous version
