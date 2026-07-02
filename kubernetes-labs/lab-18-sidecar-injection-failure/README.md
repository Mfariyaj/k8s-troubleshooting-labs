## 🎯 How to Use This Lab

1. Deploy the broken state: `./deploy.sh`
2. Check pod status: `kubectl get pods -n <namespace>`
3. Investigate: `kubectl describe pod`, `kubectl logs`, `kubectl get events`
4. Identify the root cause from error messages
5. Fix the YAML and re-apply
6. Check `solution.md` if stuck

---

# Lab 18: Sidecar Injection Failure

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team is rolling out Istio service mesh to the "notifications" microservice as part of
a zero-trust networking initiative. After labeling the namespace for injection and deploying
the application, pods are stuck in Init:CrashLoopBackOff. The sidecar proxy isn't starting
correctly — the init container that sets up iptables rules is crashing, the proxy config has
wrong ports, and the injection annotation has a typo preventing proper sidecar configuration.
Three services are down and the release is blocked.

## Symptoms

```bash
$ kubectl get pods -n lab-18-sidecar
NAME                                    READY   STATUS                  RESTARTS      AGE
notification-svc-6f8a9b7c5d-xyz12       0/2     Init:CrashLoopBackOff   5 (30s ago)   3m
notification-svc-6f8a9b7c5d-abc34       0/2     Init:CrashLoopBackOff   5 (28s ago)   3m
notification-svc-6f8a9b7c5d-def56       0/2     Init:CrashLoopBackOff   4 (45s ago)   3m

$ kubectl describe pod notification-svc-6f8a9b7c5d-xyz12 -n lab-18-sidecar
...
Init Containers:
  istio-init:
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
    ...
Events:
  Warning  BackOff  30s (x5 over 2m)  kubelet  Back-off restarting failed container
```

## Error Output

```bash
$ kubectl logs notification-svc-6f8a9b7c5d-xyz12 -c istio-init -n lab-18-sidecar
iptables v1.8.9: unknown option "--to-ports"
Try `iptables -h` or 'iptables --help' for more information.
Error: failed to set up iptables rules for traffic redirection
Redirect port: 0 (invalid, must be > 0)
Exit status: 1

$ kubectl logs notification-svc-6f8a9b7c5d-xyz12 -c istio-proxy -n lab-18-sidecar
Error from server (BadRequest): container "istio-proxy" in pod "notification-svc-6f8a9b7c5d-xyz12" is waiting to start: PodInitializing
```

## Hints

<details>
<summary>Hint 1 (Conceptual)</summary>
The istio-init container runs iptables commands to redirect traffic through the sidecar proxy. If the redirect port is 0 or the iptables command syntax is wrong, the init container fails. Check the ConfigMap that provides the proxy configuration, particularly the port settings.
</details>

<details>
<summary>Hint 2 (Direction)</summary>
Multiple issues are stacked: (1) The annotation `sidecar.istio.io/inject` is misspelled as `sidecar.istio.io/injectt` — the extra 't' means injection config is partially broken. (2) The ConfigMap `istio-proxy-config` has REDIRECT_PORT set to "0" instead of "15001". (3) The init container command uses `--to-ports` (invalid for REDIRECT target) instead of `--to-port`. Fix all three.
</details>

<details>
<summary>Hint 3 (Solution Path)</summary>
(1) Fix the annotation typo in the deployment template: change `sidecar.istio.io/injectt` to `sidecar.istio.io/inject`. (2) Update the ConfigMap: set REDIRECT_PORT to "15001" and INBOUND_CAPTURE_PORT to "15006". (3) Fix the init container command: change `--to-ports` to `--to-port` in the iptables REDIRECT rule. After fixing, delete existing pods to force re-creation with the corrected config.
</details>

## Troubleshooting Commands

```bash
# Check pod status and init container state
kubectl get pods -n lab-18-sidecar

# Describe pod to see init container failures
kubectl describe pod -l app=notification-svc -n lab-18-sidecar

# Check init container logs
kubectl logs -l app=notification-svc -c istio-init -n lab-18-sidecar

# Check the deployment annotations for injection config
kubectl get deployment notification-svc -n lab-18-sidecar -o jsonpath='{.spec.template.metadata.annotations}' | jq .

# Look at the ConfigMap for proxy configuration
kubectl get configmap istio-proxy-config -n lab-18-sidecar -o yaml

# Check the namespace labels (istio injection enabled?)
kubectl get namespace lab-18-sidecar --show-labels

# Inspect the init container command in the pod spec
kubectl get pod -l app=notification-svc -n lab-18-sidecar -o jsonpath='{.items[0].spec.initContainers[0].command}' | jq .

# Check environment variables injected into init container
kubectl get pod -l app=notification-svc -n lab-18-sidecar -o jsonpath='{.items[0].spec.initContainers[0].env}' | jq .

# Check events in namespace
kubectl get events -n lab-18-sidecar --sort-by='.lastTimestamp'

# Look at the full pod spec to see all containers and init containers
kubectl get pod -l app=notification-svc -n lab-18-sidecar -o yaml | head -100

# Check for MutatingWebhookConfigurations related to sidecar injection
kubectl get mutatingwebhookconfigurations | grep -i istio

# Verify the deployment spec
kubectl get deployment notification-svc -n lab-18-sidecar -o yaml
```

## Expected Resolution Time: 20-30 minutes

## What You'll Learn

- How Istio-style sidecar injection works via init containers and proxy sidecars
- The role of iptables traffic redirection in service mesh
- How ConfigMaps drive sidecar proxy configuration
- Debugging multi-container pod initialization failures
- The critical difference between init container failures and main container failures
- How annotation typos can cause subtle injection issues
