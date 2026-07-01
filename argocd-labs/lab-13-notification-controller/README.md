# Lab 13: Notification Controller — Notifications Never Send

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team has configured ArgoCD Notifications to send Slack alerts when applications sync or go unhealthy. The configuration includes:
- A Slack service integration
- Custom templates with Go template syntax
- Triggers for sync success, failure, and health degradation
- Applications annotated with notification triggers

Despite applications syncing and health changing, **no notifications are ever delivered**. The Notifications controller logs show it's running but never matches any trigger conditions.

## Observed Behavior

```
$ kubectl get cm argocd-notifications-cm -n argocd
NAME                      DATA   AGE
argocd-notifications-cm   4      15m

$ kubectl get secret argocd-notifications-secret -n argocd
NAME                            TYPE     DATA   AGE
argocd-notifications-secret     Opaque   1      15m

$ argocd app get notification-test-app
Name:               argocd/notification-test-app
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          notification-test
Sync Status:        Synced to main (f4a8b2c)
Health Status:      Healthy

$ kubectl get app notification-test-app -n argocd -o jsonpath='{.metadata.annotations}'
{"notifications.argoproj.io/subscribe.on-sync-succeeded.slack":"platform-alerts","notifications.argoproj.io/subscribe.on-health-degraded.slack":"platform-alerts"}

$ kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=30
time="2024-01-15T15:00:00Z" level=info msg="Processing app" app="argocd/notification-test-app"
time="2024-01-15T15:00:00Z" level=info msg="Trigger on-sync-succeeded result: []"
time="2024-01-15T15:00:00Z" level=info msg="Trigger on-health-degraded result: []"
time="2024-01-15T15:00:01Z" level=error msg="Failed to execute template notification-template-sync" err="template: notification-template-sync:1: function \"timeFormat\" not defined"
time="2024-01-15T15:00:01Z" level=warning msg="notification service slack: error sending message" err="channel \"platform-alerts\": token is invalid"

$ argocd admin notifications trigger get --config-map argocd-notifications-cm --secret argocd-notifications-secret
NAME                    ENABLED   TEMPLATE
on-sync-succeeded       true      notification-template-sync
on-health-degraded      true      notification-template-health
```

## Your Task

1. Identify why notifications are never sent
2. Find ALL bugs in the notification configuration (there are 4)
3. Fix the ConfigMap, Secret, and validate notifications would fire

## Files

- `application.yaml` — ArgoCD Application with notification annotations
- `argocd-notifications-cm.yaml` — Broken notification triggers and templates
- `argocd-notifications-secret.yaml` — Broken secret with service credentials
- `deploy.sh` / `cleanup.sh` — Lab lifecycle scripts

## Hints

<details>
<summary>Hint 1</summary>
Trigger conditions reference application fields. The correct field for sync status is `app.status.sync.status` (not `app.status.operationState.syncResult.status`). The operationState field exists but has different semantics — it tracks the operation, not the current sync state.
</details>

<details>
<summary>Hint 2</summary>
Go templates in ArgoCD Notifications have specific built-in functions. `timeFormat` is not one of them — the correct function is `time.Format` or you should use the built-in `time.Now` with method syntax. Also check that template references use the correct delimiters and don't have quoting issues in YAML.
</details>

<details>
<summary>Hint 3</summary>
The notification secret must have a key that matches exactly what the service configuration expects. If your `argocd-notifications-cm` references `$slack-token` but the secret has a key `slack_token` (underscore vs dash), the token resolution will fail silently or show an "invalid token" error.
</details>

## Useful Commands

```bash
# Check notification ConfigMap
kubectl get cm argocd-notifications-cm -n argocd -o yaml

# Check notification secret keys (not values)
kubectl get secret argocd-notifications-secret -n argocd -o jsonpath='{.data}' | jq 'keys'

# View notification controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=100
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=100 | grep -i error

# Check application annotations
kubectl get application notification-test-app -n argocd -o jsonpath='{.metadata.annotations}' | jq

# Test trigger evaluation
argocd admin notifications trigger run on-sync-succeeded notification-test-app --config-map argocd-notifications-cm --secret argocd-notifications-secret

# Test template rendering
argocd admin notifications template get notification-template-sync --config-map argocd-notifications-cm --secret argocd-notifications-secret

# Verify service configuration
argocd admin notifications service get slack --config-map argocd-notifications-cm --secret argocd-notifications-secret

# Check app sync status fields
kubectl get application notification-test-app -n argocd -o jsonpath='{.status.sync.status}'
kubectl get application notification-test-app -n argocd -o jsonpath='{.status.operationState}'

# Restart notification controller
kubectl rollout restart deployment argocd-notifications-controller -n argocd

# Decode secret value to check format
kubectl get secret argocd-notifications-secret -n argocd -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'
```

## What You'll Learn

- ArgoCD Notifications trigger condition field paths and evaluation
- Go template function availability in notification templates
- Secret key naming conventions and variable interpolation (`$secret-key`)
- YAML indentation sensitivity in service configuration blocks
- Debugging notification delivery pipeline (trigger → template → service)
