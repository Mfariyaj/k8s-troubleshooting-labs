## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 07: Trigger Not Firing — Docker/Webhook Triggers Broken

## Difficulty: 🟡 Intermediate

---

## 📚 What You'll Learn

Spinnaker pipelines can be triggered automatically by various events:

- **Docker Registry triggers**: Igor polls Docker registries for new tags
- **Webhook triggers**: External systems POST to Gate's webhook endpoint
- **Git triggers**: Pushes/PRs to GitHub/GitLab/Bitbucket
- **Jenkins triggers**: Job completion in Jenkins
- **CRON triggers**: Time-based scheduling
- **Pipeline triggers**: One pipeline triggering another
- **Pub/Sub triggers**: Google Pub/Sub, AWS SNS/SQS

**Igor** is the microservice responsible for polling CI systems and Docker registries. It:
- Polls Docker registries at configurable intervals (default: 30s)
- Detects new image tags and sends events to Echo
- Echo routes events to matching pipeline triggers

Common trigger failures:
- Igor can't authenticate with the Docker registry
- Webhook payload format doesn't match Spinnaker's expected format
- Trigger constraints (artifact, branch, tag pattern) don't match incoming events
- Echo is down or can't reach Orca to start pipelines
- Registry account name in trigger doesn't match Igor's config

---

## 🔧 Scenario

A pipeline should trigger automatically when a new Docker image is pushed, and also supports manual webhook triggers. Neither works:

1. Igor's Docker Registry account name is `docker-hub` but the pipeline trigger references `dockerhub` (no hyphen)
2. The webhook trigger expects a `source` of `github-deploy` but the incoming webhook sends `source: github_deploy` (underscore vs hyphen)
3. The trigger's tag pattern regex is `v[0-9]+\\.[0-9]+\\.[0-9]+` but tags are formatted as `release-1.2.3` (wrong pattern)

---

## 💥 Expected Error Output

Igor logs:
```
INFO  c.n.s.igor.docker.DockerRegistryPollingMonitor - 
  Polling docker-hub for new images...
  Found new tag: myorg/myapp:release-1.2.3
  
WARN  c.n.s.igor.docker.DockerRegistryPollingMonitor -
  No pipeline triggers matched for image myorg/myapp:release-1.2.3
  in registry account 'docker-hub'
```

When sending webhook:
```
$ curl -X POST http://gate:8084/webhooks/webhook/github_deploy \
    -H "Content-Type: application/json" \
    -d '{"repository": "myapp", "tag": "release-1.2.3"}'

Response: {"eventProcessed": true, "eventId": "xxx"}
# But pipeline never starts
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Compare the Docker Registry account name in the pipeline trigger with what's configured in Igor. They must match exactly (case-sensitive, including hyphens).
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
For webhook triggers, the `source` field in the trigger config must match the URL path. If the trigger source is `github-deploy`, the webhook URL must be `/webhooks/webhook/github-deploy` (not `github_deploy`).
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Change pipeline trigger's `account` from `dockerhub` to `docker-hub`, 2) Change webhook source from `github-deploy` to `github_deploy` (to match incoming payload), or change the sender URL, 3) Change tag pattern from `v[0-9]+\.[0-9]+\.[0-9]+` to `release-[0-9]+\.[0-9]+\.[0-9]+`.
</details>

---

## 🛠️ Useful Commands

```bash
# Check Igor Docker Registry accounts
hal config provider docker-registry account list

# View Igor logs for polling activity
kubectl logs -n spinnaker spin-igor-xxx | grep -i "poll\|tag\|trigger"

# Test webhook manually
curl -X POST http://localhost:8084/webhooks/webhook/github-deploy \
  -H "Content-Type: application/json" \
  -d '{"repository": "myapp", "tag": "release-1.2.3"}'

# Check Echo logs for event routing
kubectl logs -n spinnaker spin-echo-xxx | grep -i "trigger\|webhook"

# List pipeline triggers
spin pipeline get --name "Auto Deploy" --application myapp | jq '.triggers'

# Check pipeline execution history
spin pipeline execution list --application myapp
```

---

## 📖 References

- https://spinnaker.io/docs/guides/user/pipeline/triggers/
- https://spinnaker.io/docs/guides/user/pipeline/triggers/webhooks/
- https://spinnaker.io/docs/setup/triggers/
- https://spinnaker.io/docs/setup/triggers/docker/

---

## 🏁 Success Criteria

- New Docker image tags trigger the pipeline automatically
- Webhook POST successfully starts a pipeline execution
- Igor logs show successful trigger matching
- Pipeline starts within 30 seconds of new image push
