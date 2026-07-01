# Lab 05: Environment Protection Rules

## 🎯 Scenario

The team configured a production deployment pipeline with environment protection rules. However, the deployment either gets stuck waiting for approval that never comes, fails due to invalid configuration, or bypasses protections entirely. The rollback mechanism also has issues with environment gates.

## 🔴 Difficulty: Hard

## 📋 Error Output

GitHub Actions shows:

```
Job 'deploy-production' is waiting for deployment review.
Environment: production
Required reviewers: (none configured)
Status: Stuck — no reviewers to approve

Warning: environment.wait-timer value '-1' is invalid.
Valid range: 0-43200 (minutes). Using default: 0.

Job 'deploy-production' configuration issues:
  - Environment 'production' has no protection rules configured
  - Branch 'feature/deploy-fix' is not in the deployment branch policy
  - cancel-in-progress: true on production deployments may cancel active deploys

Job 'rollback' blocked:
  - Environment 'production' requires approval but rollback is time-sensitive
  - wait-timer: 30 adds 30-minute delay to rollback (dangerous!)
  - Rollback should not require the same approval gate as deployment
```

## 🐛 Debugging Steps

1. Check environment protection configuration:
   ```
   Settings → Environments → production
   - Required reviewers: (none) ← Need to add reviewers
   - Deployment branches: All branches ← Should restrict to main
   ```

2. Verify wait-timer values:
   ```
   wait-timer: -1 → Invalid (must be 0-43200)
   wait-timer: 30 on rollback → 30 min delay on rollback is dangerous
   ```

3. Review concurrency settings for production:
   ```
   cancel-in-progress: true → Could cancel an active production deploy!
   ```

4. Check deployment ordering:
   ```
   deploy-production needs: [build] ← Should need staging first!
   ```

5. Verify branch protection policies match workflow triggers

## 💡 Hints

<details>
<summary>Hint 1</summary>
The `wait-timer: -1` is invalid. Valid values are 0-43200 minutes. Also, `deploy-production` skips the staging step — it only needs `[build]` instead of `[deploy-staging]`.
</details>

<details>
<summary>Hint 2</summary>
`cancel-in-progress: true` on a production deployment concurrency group means a new push could cancel an in-progress production deploy. This should be `false` for production.
</details>

<details>
<summary>Hint 3</summary>
The rollback job has `environment: production` with `wait-timer: 30`, meaning a rollback would wait 30 minutes before executing. Rollbacks should be immediate with a separate environment or no wait-timer.
</details>

## 🔧 Issues to Fix

1. `wait-timer: -1` is invalid — must be 0 to 43200
2. `deploy-production` needs `[build]` but should need `[deploy-staging]` to enforce stage ordering
3. `cancel-in-progress: true` is dangerous for production — could cancel active deployments
4. Environment `production` has no reviewers configured (GitHub Settings issue)
5. Rollback job uses `environment: production` with `wait-timer: 30` — rollbacks need immediate execution
6. No branch restriction on the production environment — any branch can deploy
