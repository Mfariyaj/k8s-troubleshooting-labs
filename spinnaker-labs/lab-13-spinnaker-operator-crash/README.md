## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 13: Spinnaker Operator Crash — Services Not Starting

## Difficulty: 🔴 Advanced

---

## 📚 What You'll Learn

The **Spinnaker Operator** is a Kubernetes-native way to deploy and manage Spinnaker. Instead of using Halyard CLI, you define a `SpinnakerService` Custom Resource (CR) and the operator reconciles the desired state.

Operator vs Halyard:
| Aspect | Halyard | Operator |
|--------|---------|----------|
| Config | `~/.hal/config` | SpinnakerService CR |
| Deploy | `hal deploy apply` | `kubectl apply -f` |
| GitOps | Manual | Native (just apply YAML) |
| Upgrade | `hal version edit` | Change `spec.version` |
| Troubleshoot | `hal deploy details` | `kubectl describe` |

SpinnakerService CRD structure:
```yaml
apiVersion: spinnaker.io/v1alpha2
kind: SpinnakerService
metadata:
  name: spinnaker
spec:
  spinnakerConfig:
    config: {}          # Same as ~/.hal/config
    profiles: {}        # Per-service overrides
    service-settings: {} # Port/health settings
  expose:
    type: service       # How to expose Deck/Gate
```

Common Operator issues:
- Invalid CRD field names or indentation
- Redis not accessible (connection refused)
- Front50 can't reach storage backend
- Service profiles override with wrong format
- Version specified doesn't exist in the registry

---

## 🔧 Scenario

Spinnaker deployed via the Operator, but multiple services crash on startup:

1. Redis deployment has `replicas: 0` and no password set, but services expect password auth
2. Front50 storage config references a non-existent S3 bucket with wrong `pathStyleAccess` for MinIO
3. The SpinnakerService CR has the `spinnakerConfig.config` indented under wrong key (`spec.config` instead of `spec.spinnakerConfig.config`)

---

## 💥 Expected Error Output

```
$ kubectl get pods -n spinnaker
NAME                                READY   STATUS             RESTARTS   AGE
spin-clouddriver-6d4f8b9c7-x2k4l   0/1     CrashLoopBackOff   5          3m
spin-front50-7c5d6e8f9-m3n7p       0/1     CrashLoopBackOff   5          3m
spin-gate-8b7c6d5e4-q9w2r          0/1     CrashLoopBackOff   4          3m
spin-orca-9a8b7c6d5-t4u5v          0/1     CrashLoopBackOff   5          3m
spin-redis-0                        0/0     Pending            0          3m
spinnaker-operator-5f4e3d2c1-k8j7  1/1     Running            0          10m

$ kubectl logs -n spinnaker spin-front50-xxx:
  ERROR org.springframework.boot.SpringApplication - 
    Application run failed:
    redis.clients.jedis.exceptions.JedisConnectionException: 
    Could not get a resource from the pool
    Caused by: java.net.ConnectException: Connection refused 
    (Connection refused) - redis://spin-redis:6379
    
$ kubectl describe spinnakerservice spinnaker -n spinnaker:
  Status:
    Conditions:
      - Type: Error
        Message: "spec.config is not a valid field. Did you mean 
                  spec.spinnakerConfig.config?"
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check the Redis deployment — is it actually running? If `replicas: 0`, no Redis pods will start, and all services depending on Redis will fail with connection errors.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Look at the SpinnakerService CR structure. The configuration should be under `spec.spinnakerConfig.config`, not `spec.config`. The operator validates this and reports the error in conditions.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Change Redis replicas from 0 to 1 and set the correct password (or remove auth requirement), 2) Move configuration from `spec.config` to `spec.spinnakerConfig.config` in the CR, 3) Fix Front50 S3 config with existing bucket and set `pathStyleAccess: true` for MinIO.
</details>

---

## 🛠️ Useful Commands

```bash
# Check operator status
kubectl get spinnakerservice -n spinnaker -o yaml

# Check pod crash reasons
kubectl describe pod -n spinnaker spin-front50-xxx
kubectl logs -n spinnaker spin-front50-xxx --previous

# Check Redis
kubectl get pods -n spinnaker | grep redis
kubectl exec -n spinnaker spin-redis-0 -- redis-cli ping

# Check operator logs
kubectl logs -n spinnaker deployment/spinnaker-operator

# Validate CR
kubectl apply --dry-run=server -f spinnakerservice.yaml
```

---

## 📖 References

- https://spinnaker.io/docs/setup/install/operator/
- https://github.com/armory/spinnaker-operator
- https://spinnaker.io/docs/reference/architecture/
- https://spinnaker.io/docs/setup/productionize/persistence/

---

## 🏁 Success Criteria

- All Spinnaker pods reach Running/Ready state
- Redis is accessible and responding to PING
- Front50 connects to storage successfully
- SpinnakerService CR shows no error conditions
- Spinnaker UI (Deck) is accessible
