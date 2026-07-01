## Solution: Kubernetes Cloud Plugin

### Root Cause

1. Jenkins URL is `http://jenkins:8080` but service name is `jenkins-master` — JNLP can't connect back
2. Container named `jnlp` overrides the auto-injected JNLP remoting container
3. ServiceAccount `jenkins-agent` lacks RBAC (pods create/exec/log)
4. PVC `jenkins-workspace-pvc` doesn't exist; broken `subPath`
5. Port 50000 not exposed on Jenkins master Service

### Step-by-Step Fix

1. Fix Jenkins URL to `http://jenkins-master:8080`, tunnel to `jenkins-master:50000`
2. Rename container from `jnlp` to `maven` — never override the built-in JNLP container
3. Create Role/RoleBinding granting pods create/get/list/watch/delete, pods/exec, pods/log
4. Replace PVC with `emptyDir` or create the PVC; remove broken `subPath`
5. Expose port 50000 on Jenkins master Service

### Fixed Pod Template

```yaml
spec:
  serviceAccountName: jenkins-agent
  containers:
  - name: maven  # Fixed: was 'jnlp' which overrides remoting container
    image: maven:3.9-eclipse-temurin-17
    command: ['cat']
    tty: true
  - name: docker
    image: docker:24-dind
    securityContext:
      privileged: true
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket
```

### RBAC Fix

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-agent-role
  namespace: jenkins
rules:
- apiGroups: [""]
  resources: ["pods", "pods/exec", "pods/log"]
  verbs: ["create", "get", "list", "watch", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-agent-binding
  namespace: jenkins
subjects:
- kind: ServiceAccount
  name: jenkins-agent
roleRef:
  kind: Role
  name: jenkins-agent-role
  apiGroup: rbac.authorization.k8s.io
```

### Verification

```bash
kubectl auth can-i create pods --as=system:serviceaccount:jenkins:jenkins-agent -n jenkins
# Returns "yes". Pipeline pod starts, JNLP connects, stages run in maven/docker containers.
```
