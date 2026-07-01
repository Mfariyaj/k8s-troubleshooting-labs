# Lab 10: Deployment Gates & Rollback

## 🎯 Scenario

The team implemented a progressive deployment pipeline with canary releases, health checks, full rollout, and automatic rollback. However, several critical issues prevent this from working correctly: the health check uses the wrong URL, the rollback never executes, concurrency settings cancel active deployments, and the notification job has incorrect conditions.

## 🔴 Difficulty: Expert

## 📋 Error Output

GitHub Actions shows:

```
Workflow 'Progressive Deployment' triggered on push to main.

Job 'deploy-canary' started:
  ✓ Downloaded artifact 'app-build'
  ✓ Deployed canary with 10% traffic
  
Job 'health-check' FAILED:
  Run curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health
  Health check failed! Status: 000
  Error: connect ECONNREFUSED 127.0.0.1:8080
  
  The health check is hitting localhost on the GitHub Actions runner,
  NOT the actual canary deployment URL!
  Should be: https://canary.example.com/health

Job 'deploy-full' SKIPPED:
  Skipped because dependency 'health-check' failed.

Job 'rollback' SKIPPED:
  Condition: if: ${{ failure() }}
  'rollback' needs: [deploy-full]
  But deploy-full was SKIPPED (not failed) → failure() is false for skipped jobs!
  Rollback never executes when health-check fails because deploy-full never ran.

Concurrency issue detected:
  Group: production-deploy (cancel-in-progress: true)
  Jobs 'deploy-canary' and 'deploy-full' share the same concurrency group!
  If deploy-full starts while canary is finishing, it could cancel the canary.
  In a fast pipeline, a new push cancels the entire in-progress deployment.

Job 'post-deploy-verification' uses wrong URL:
  http://internal-service:3000/api/health — this DNS name doesn't resolve
  in GitHub Actions runners. Should use the actual deployment URL.

Job 'notify-failure' skipped:
  Condition: if: failure()
  needs: [deploy-canary, health-check, deploy-full]
  When health-check fails and deploy-full is skipped,
  the job condition evaluates differently than expected.
  Should use: if: ${{ always() && (needs.health-check.result == 'failure' || needs.deploy-full.result == 'failure') }}
```

## 🐛 Debugging Steps

1. Check health check URL:
   ```
   http://localhost:8080/health → Runner's localhost, NOT the deployed app!
   Should be: https://canary.example.com/health
   ```

2. Understand rollback trigger conditions:
   ```
   rollback needs: [deploy-full] + if: failure()
   But if health-check fails → deploy-full is SKIPPED → rollback doesn't trigger
   Rollback should need: [health-check, deploy-full] with proper condition
   ```

3. Review concurrency groups:
   ```
   deploy-canary: group: production-deploy, cancel-in-progress: true
   deploy-full: group: production-deploy, cancel-in-progress: true
   SAME GROUP! They could cancel each other or be cancelled by new pushes
   ```

4. Check workflow-level concurrency:
   ```
   Top-level: group: ${{ github.ref }}, cancel-in-progress: true
   A new push to main cancels the ENTIRE in-progress deployment!
   ```

5. Verify post-deploy URLs resolve from the runner

## 💡 Hints

<details>
<summary>Hint 1</summary>
The health check curls `http://localhost:8080/health` which is the GitHub Actions runner's localhost — there's nothing running there! It should hit the actual canary URL (https://canary.example.com/health).
</details>

<details>
<summary>Hint 2</summary>
The rollback job has `needs: [deploy-full]` and `if: failure()`. But when health-check fails, deploy-full is SKIPPED (not failed). `failure()` only returns true when a needed job actually FAILED, not when it was skipped. The rollback should also depend on health-check.
</details>

<details>
<summary>Hint 3</summary>
Both deploy-canary and deploy-full use `concurrency: group: production-deploy` with `cancel-in-progress: true`. This means they're in the same queue and could cancel each other. Additionally, the workflow-level concurrency cancels the entire pipeline on new pushes — dangerous for a deployment in progress!
</details>

## 🔧 Issues to Fix

1. Health check uses `http://localhost:8080/health` — should use actual canary URL
2. Rollback never triggers: `needs: [deploy-full]` + `if: failure()` doesn't catch health-check failures
3. Workflow-level `cancel-in-progress: true` cancels in-progress deployments on new push
4. `deploy-canary` and `deploy-full` share same concurrency group with cancel-in-progress
5. `post-deploy-verification` uses `http://internal-service:3000` — unresolvable from runner
6. `notify-failure` condition doesn't account for skipped jobs properly
7. `cancel-in-progress: true` on production deploy jobs is dangerous — could leave partial deploys
