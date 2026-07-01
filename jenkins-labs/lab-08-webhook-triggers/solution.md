## Solution: Webhook Triggers

### Root Cause

1. `pollSCM('* * * * *')` polls the repo but doesn't respond to incoming webhooks
2. A `cron` trigger fires on schedule regardless of code changes
3. The webhook URL `/github-webhook/` returns 404 because `githubPush()` trigger isn't configured

### Step-by-Step Fix

1. Replace `pollSCM` with `githubPush()` trigger (requires GitHub plugin)
2. Remove the `cron` trigger entirely
3. Ensure Jenkins URL is reachable from GitHub (not localhost)
4. Add CRUMB token header when testing webhooks manually

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/example/my-repo.git',
                    branch: 'main',
                    credentialsId: 'github-token'
            }
        }
        stage('Build') {
            steps {
                sh 'echo "Building on commit: ${GIT_COMMIT}"'
                sh 'make build'
            }
        }
        stage('Notify') {
            steps {
                sh 'echo "Build triggered by: webhook push"'
            }
        }
    }
}
```

### Testing Webhook Manually

```bash
CRUMB=$(curl -s -u admin:admin http://localhost:8080/crumbIssuer/api/json | jq -r '.crumb')
curl -X POST http://localhost:8080/github-webhook/ \
  -H "Content-Type: application/json" \
  -H "X-GitHub-Event: push" \
  -H "Jenkins-Crumb: ${CRUMB}" \
  -d @webhook-payload.json
```

### Verification

```bash
# Webhook delivery in GitHub returns 200 (not 404)
# Build log shows: "Started by GitHub push by <user>"
# No more cron or poll-triggered builds
```
