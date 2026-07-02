## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 02: Clouddriver K8s Account — Can't Connect to Kubernetes

## Difficulty: 🟢 Beginner

---

## 📚 What You'll Learn

**Clouddriver** is Spinnaker's cloud provider integration service. It's responsible for all communication between Spinnaker and your infrastructure — whether that's Kubernetes, AWS, GCP, or Azure. When you deploy a manifest, scale a server group, or check pod status in Spinnaker, Clouddriver is the service making those API calls.

For Kubernetes specifically, Clouddriver needs:
- A valid **kubeconfig** file with cluster connection details
- A valid **context** that exists in the kubeconfig
- A **service account** with sufficient RBAC permissions (or user credentials)
- Network connectivity from the Clouddriver pod to the K8s API server

Spinnaker uses the **V2 (manifest-based)** Kubernetes provider, which treats Kubernetes manifests as first-class objects. The older V1 provider (instance-based) is deprecated.

Common failure modes:
- Kubeconfig references a context that doesn't exist
- Service account token is expired or revoked
- ClusterRole/ClusterRoleBinding not created
- API server address is wrong or unreachable from Spinnaker's network

---

## 🔧 Scenario

Clouddriver is configured with a Kubernetes account, but it can't list or deploy resources. The Spinnaker UI shows "Error fetching server groups" and deployments fail with authentication errors. The issues are:

1. The kubeconfig references a context named `production-cluster` but only `prod-cluster` exists
2. The service account `spinnaker-deployer` doesn't have a ClusterRoleBinding
3. The cluster server URL has a typo in the port number

---

## 💥 Expected Error Output

In Clouddriver logs (`kubectl logs -n spinnaker spin-clouddriver-xxx`):
```
WARN  c.n.s.c.k.v2.caching.KubernetesV2ProviderSynchronizable -
  Could not load kubeconfig context 'production-cluster':
  context "production-cluster" does not exist

ERROR c.n.s.clouddriver.kubernetes.v2.op.KubernetesV2RequestHandler -
  Failed to list resources in account 'my-k8s-account':
  io.kubernetes.client.openapi.ApiException: Unauthorized (401)
  
ERROR c.n.s.c.k.v2.security.KubernetesV2Credentials -
  Connection refused: https://kubernetes.default.svc:64430/api/v1/namespaces
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check the kubeconfig file — do the context names match what's configured in Clouddriver? Use `kubectl config get-contexts` to see available contexts.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
The service account exists but has no ClusterRoleBinding. Without RBAC permissions, the service account token is valid but unauthorized. Check with `kubectl get clusterrolebinding | grep spinnaker`.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes needed: 1) In clouddriver-local.yml, change context from `production-cluster` to `prod-cluster`, 2) Apply the rbac.yaml to create the ClusterRoleBinding, 3) Fix the server URL port from 64430 to 6443 in the kubeconfig.
</details>

---

## 🛠️ Useful Commands

```bash
# Check Clouddriver pod status and logs
kubectl get pods -n spinnaker | grep clouddriver
kubectl logs -n spinnaker spin-clouddriver-xxx -f

# Inspect kubeconfig contexts
kubectl config get-contexts --kubeconfig=kubeconfig-broken.yaml

# Check service account and RBAC
kubectl get sa spinnaker-deployer -n spinnaker
kubectl get clusterrolebinding | grep spinnaker
kubectl auth can-i list pods --as=system:serviceaccount:spinnaker:spinnaker-deployer

# Halyard account inspection
hal config provider kubernetes account list
hal config provider kubernetes account get my-k8s-account

# Test API server connectivity from Clouddriver pod
kubectl exec -n spinnaker spin-clouddriver-xxx -- \
  curl -k https://kubernetes.default.svc:6443/healthz
```

---

## 📖 References

- https://spinnaker.io/docs/setup/install/providers/kubernetes-v2/
- https://spinnaker.io/docs/setup/install/providers/kubernetes-v2/aws-eks/
- https://spinnaker.io/docs/reference/providers/kubernetes-v2/
- https://kubernetes.io/docs/reference/access-authn-authz/rbac/

---

## 🏁 Success Criteria

- Clouddriver pod is running without authentication errors in logs
- `spin application list` returns results
- Spinnaker UI shows the Kubernetes cluster resources
- Deployments to the cluster succeed
