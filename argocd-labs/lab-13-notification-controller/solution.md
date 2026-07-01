## Solution: Notification Controller — Notifications Never Send

### Root Cause
Four bugs prevent notifications from being delivered:
1. **Wrong trigger condition field**: Uses `app.status.operationState.syncResult.status` — should be `app.status.sync.status`
2. **Undefined template function**: `timeFormat` doesn't exist — use `time.Format` or remove the call
3. **Secret key mismatch**: ConfigMap references `$slack-token` (dash) but secret has key `slack_token` (underscore)
4. **Malformed service config**: YAML indentation is wrong — `apiURL`, `username`, `icon` are nested under `token:` value instead of being sibling keys

### Step-by-Step Fix

1. Check notification controller logs:
   ```bash
   kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=50
   ```
2. Fix all four issues in the ConfigMap and Secret

### Fixed YAML — argocd-notifications-cm.yaml (key sections)
```yaml
data:
  service.slack: |
    token: $slack-token
    apiURL: https://slack.com/api
    username: argocd-bot
    icon: ":argocd:"
  trigger.on-sync-succeeded: |
    - when: app.status.sync.status == 'Synced'
      send:
        - notification-template-sync
  trigger.on-health-degraded: |
    - when: app.status.health.status == 'Degraded'
      send:
        - notification-template-health
  template.notification-template-sync: |
    message: |
      Application {{.app.metadata.name}} synced successfully!
      Revision: {{.app.status.sync.revision}}
      Project: {{.app.spec.project}}
    slack:
      attachments: |
        [{"color":"#18be52","title":"{{ .app.metadata.name }}"}]
  template.notification-template-health: |
    message: |
      Application {{.app.metadata.name}} health is {{.app.status.health.status}}!
```

### Fixed YAML — argocd-notifications-secret.yaml
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
  namespace: argocd
type: Opaque
stringData:
  slack-token: "xoxb-YOUR-VALID-SLACK-BOT-TOKEN"
```

### Verification
```bash
kubectl apply -f argocd-notifications-cm.yaml
kubectl apply -f argocd-notifications-secret.yaml
kubectl rollout restart deployment argocd-notifications-controller -n argocd
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=20
# No errors, triggers should match
```
