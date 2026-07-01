# Lab 08: Webhook Triggers

## Difficulty: ⭐⭐ Medium

## Scenario

A pipeline should trigger on GitHub pushes via webhook, but it only runs on a cron schedule or via SCM polling. The webhook endpoint receives payloads but builds don't start.

## Console Error Output

```
Started by an SCM change (polling)
[Poll SCM] Polling for changes...
No changes detected.

# Meanwhile, webhook delivery shows:
POST http://jenkins:8080/github-webhook/ → 404 Not Found
```

```
# When the build does run (via cron), it's not triggered by the push:
Started by timer
```

## Hints

1. `pollSCM` polls at intervals — it's not a real webhook trigger
2. For GitHub webhooks, use `githubPush()` trigger (requires GitHub plugin)
3. Or use Generic Webhook Trigger plugin with `GenericTrigger`
4. The Jenkins URL must be accessible from GitHub (not localhost)
5. Check webhook payload format in `webhook-payload.json`

## What to Fix

- Replace `pollSCM('* * * * *')` with `githubPush()` 
- Remove the `cron` trigger (it's not webhook-based)
- Configure GitHub webhook URL in the GitHub repo settings
- Install the GitHub Integration plugin if not present
