## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 11: Notification Not Sending — Echo/Slack Broken

## Difficulty: 🟡 Intermediate

---

## 📚 What You'll Learn

**Echo** is Spinnaker's event and notification service. It handles:

- **Pipeline notifications**: Alerts on pipeline start/complete/fail
- **Stage notifications**: Per-stage success/failure alerts
- **Notification channels**: Slack, Email, PagerDuty, Microsoft Teams, custom webhooks
- **Event routing**: Routes events from triggers to pipeline matching

Notification types in Spinnaker:
1. **Pipeline-level notifications**: Configured in pipeline settings, fire on pipeline events
2. **Stage-level notifications**: Configured per stage, fire on stage events
3. **Webhook stage**: Explicit HTTP call (not technically Echo — goes through Orca)

Common notification failures:
- Slack bot token missing or invalid
- Channel name has `#` prefix when it shouldn't (or vice versa)
- Email SMTP configuration wrong
- Echo pod can't reach external APIs (network policy, proxy)
- Notification configured on wrong event type (e.g., `pipeline.complete` vs `stage.complete`)

---

## 🔧 Scenario

A pipeline should send Slack notifications on completion and failure, but no messages are delivered:

1. Echo's Slack configuration has a `botToken` that's expired/invalid (placeholder value)
2. The channel name in the pipeline notification is `#deployments` but Slack API expects just `deployments` (without `#`)
3. The notification is configured as a stage-level notification on the wrong stage (it's on a Wait stage that always succeeds, not on the Deploy stage that might fail)

---

## 💥 Expected Error Output

Echo logs:
```
ERROR c.n.s.echo.notification.SlackNotificationAgent -
  Failed to send Slack notification to channel '#deployments':
  com.slack.api.methods.SlackApiException: 
  {"ok":false,"error":"invalid_auth","response_metadata":{}}

WARN  c.n.s.echo.notification.SlackNotificationAgent -
  Slack API returned 'channel_not_found' for channel '#deployments'.
  Note: Channel names should not include the '#' prefix.
  
DEBUG c.n.s.echo.pipelinetriggers.PipelineNotificationHandler -
  Notification event: stage.complete for stage 'Wait for Stabilization'
  (expected: pipeline.failed for stage 'Deploy to Production')
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check Echo's Slack configuration. The `botToken` should be a valid Slack bot token starting with `xoxb-`. A placeholder or expired token will cause `invalid_auth`.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Slack API expects channel names without the `#` prefix. If your pipeline notification says `#deployments`, change it to `deployments`. Some older Spinnaker versions handled this automatically, newer ones don't.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Update `botToken` in echo-local.yml with a valid token, 2) Remove `#` from channel name in pipeline notifications, 3) Move the failure notification from the Wait stage to the Deploy stage (or make it a pipeline-level notification on `pipeline.failed`).
</details>

---

## 🛠️ Useful Commands

```bash
# Check Echo health and config
kubectl logs -n spinnaker spin-echo-xxx | grep -i "slack\|notification\|error"

# Test Slack token directly
curl -H "Authorization: Bearer xoxb-YOUR-TOKEN" \
  https://slack.com/api/auth.test

# List channels the bot can see
curl -H "Authorization: Bearer xoxb-YOUR-TOKEN" \
  "https://slack.com/api/conversations.list?limit=100"

# Check Echo configuration
kubectl exec -n spinnaker spin-echo-xxx -- cat /opt/spinnaker/config/echo.yml

# View notification events
kubectl logs -n spinnaker spin-echo-xxx | grep "NotificationHandler"
```

---

## 📖 References

- https://spinnaker.io/docs/setup/features/notifications/
- https://spinnaker.io/docs/setup/features/notifications/slack/
- https://spinnaker.io/docs/guides/user/pipeline/pipeline-notifications/
- https://api.slack.com/methods/chat.postMessage

---

## 🏁 Success Criteria

- Slack notifications are delivered on pipeline failure
- Echo logs show successful Slack API calls
- Notifications appear in the correct Slack channel
- Both pipeline-level and stage-level notifications work
