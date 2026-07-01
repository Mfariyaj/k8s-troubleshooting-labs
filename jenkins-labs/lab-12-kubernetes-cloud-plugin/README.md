# Lab 12: Kubernetes Cloud Plugin — Pod Templates Not Working

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your Jenkins master runs inside a Kubernetes cluster and uses the Kubernetes plugin to dynamically spin up agent pods for pipeline execution. After a recent migration from Docker Compose agents to Kubernetes-based dynamic agents, pipelines hang indefinitely waiting for an agent. Pods are either never created, get stuck in Pending state, or start but the JNLP container can't connect back to the Jenkins master.

The setup involves:
- Jenkins master running as a Deployment with service `jenkins-master`
- Pod templates defined both inline (Jenkinsfile) and in system config
- A workspace PVC that should persist between builds
- RBAC for the agent ServiceAccount

## What You'll Observe

Pipeline hangs with:
```
Started by user admin
[Pipeline] podTemplate
[Pipeline] {
[Pipeline] node
Still waiting to schedule task
'jenkins-k8s-agent-xxxxx-xxxxx' is offline

Waiting for next available executor on 'k8s-agent'

Agent k8s-agent-xxxxx provisioning failed.
io.fabric8.kubernetes.client.KubernetesClientException: 
  pods "jenkins-agent-xxxxx" is forbidden: 
  User "system:serviceaccount:jenkins:jenkins-agent" cannot create resource "pods" in API group "" in namespace "jenkins"
```

If RBAC is fixed, pod starts but agent never connects:
```
INFO: Waiting for agent to connect (120/200): k8s-agent-xxxxx
WARNING: Agent k8s-agent-xxxxx failed to connect after 200 seconds
java.net.ConnectException: Connection refused (Connection refused)
    at java.net.PlainSocketImpl.socketConnect(Native Method)
    ...
    Caused by: Failed to connect to jenkins:50000
```

If connectivity is fixed, workspace errors:
```
ERROR: Unable to create /home/jenkins/agent/workspace/my-pipeline
java.io.IOException: Permission denied
    pod "jenkins-agent-xxxxx" volume "workspace-pvc" mount failed: 
    persistentvolumeclaim "jenkins-workspace-pvc" not found
```

## Your Task

Fix all issues preventing Kubernetes-based agent pods from running pipelines:
1. Correct the Jenkins URL/service name mismatch
2. Expose and configure the JNLP port for agent connectivity
3. Fix the container naming conflict (don't override 'jnlp')
4. Create proper RBAC permissions for the ServiceAccount
5. Fix PVC mounting issues or replace with emptyDir

## Hints

<details>
<summary>Hint 1</summary>
The Kubernetes plugin automatically injects a container named `jnlp` that runs the Jenkins remoting agent. If you define your OWN container named `jnlp`, it overrides the built-in one, and your container (maven) doesn't have the remoting JAR. Rename your container to something like `maven` or `build`.
</details>

<details>
<summary>Hint 2</summary>
In Kubernetes, service DNS is `<service-name>.<namespace>.svc.cluster.local`. If your Jenkins master Service is named `jenkins-master`, the URL must be `http://jenkins-master:8080`. The JNLP tunnel must also use `jenkins-master:50000`. Check both the Jenkinsfile env vars AND the Jenkins system configuration (Manage Jenkins → Configure Clouds).
</details>

<details>
<summary>Hint 3</summary>
The ServiceAccount needs a Role (not ClusterRole for namespace-scoped) with permissions: `pods` (create, get, list, watch, delete), `pods/exec` (create), and `pods/log` (get). Also, the PVC referenced in the pod template must actually exist in the namespace — or switch to `emptyDir` volumes.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Check Jenkins master logs
docker logs jenkins-k8s-lab 2>&1 | grep -i "kubernetes\|jnlp\|agent\|error"

# Check pod status in the namespace
kubectl get pods -n jenkins -w
kubectl describe pod -n jenkins -l jenkins/label=k8s-agent

# Check events for scheduling failures
kubectl get events -n jenkins --sort-by='.lastTimestamp' | tail -20

# Verify ServiceAccount and RBAC
kubectl get sa -n jenkins
kubectl auth can-i create pods --as=system:serviceaccount:jenkins:jenkins-agent -n jenkins
kubectl get rolebindings,clusterrolebindings -n jenkins -o wide

# Check PVC status
kubectl get pvc -n jenkins
kubectl describe pvc jenkins-workspace-pvc -n jenkins

# Test JNLP connectivity from inside the cluster
kubectl run test-conn --image=busybox --rm -it --restart=Never -- nc -vz jenkins-master 50000

# Check Jenkins cloud configuration via API
curl -s http://localhost:8080/computer/api/json
curl -s http://localhost:8080/cloud/kubernetes/api/json

# View the effective pod template
kubectl get pod -n jenkins -l jenkins/label=k8s-agent -o yaml

# Check Jenkins master service endpoints
kubectl get svc -n jenkins
kubectl get endpoints jenkins-master -n jenkins
```

## Clean Up

```bash
./cleanup.sh
```
