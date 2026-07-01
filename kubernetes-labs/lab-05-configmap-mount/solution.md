## Solution: ConfigMap Mount Failure

### Root Cause

The pod references ConfigMaps named `app-configuration` and `application-props` in its volume definitions, but the actual ConfigMap created is named `app-config`. The pod cannot mount non-existent ConfigMaps, causing `CreateContainerConfigError`.

### Diagnosis

```bash
kubectl get pods -n lab-05
kubectl describe pod -n lab-05 -l app=config-app
kubectl get configmaps -n lab-05
```

Events will show: `configmaps "app-configuration" not found`

### Fix

Update the volume references to use the correct ConfigMap name `app-config`:

```bash
kubectl edit deployment config-app -n lab-05
```

Change both volume configMap names from `app-configuration` and `application-props` to `app-config`.

### Fixed YAML

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-app
  namespace: lab-05
spec:
  replicas: 2
  selector:
    matchLabels:
      app: config-app
  template:
    metadata:
      labels:
        app: config-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d
        - name: app-properties
          mountPath: /etc/app
      volumes:
      - name: config-volume
        configMap:
          name: app-config
      - name: app-properties
        configMap:
          name: app-config
```

### Verification

```bash
kubectl get pods -n lab-05
# Pods should be Running
kubectl exec -n lab-05 deploy/config-app -- ls /etc/nginx/conf.d/
# Should show nginx.conf and app.properties
kubectl exec -n lab-05 deploy/config-app -- cat /etc/app/app.properties
```
