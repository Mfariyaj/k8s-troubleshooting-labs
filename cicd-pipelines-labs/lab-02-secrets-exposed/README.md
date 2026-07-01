# Lab 02: Secrets Exposed in Logs

## 🎯 Scenario

A developer configured a CI/CD pipeline that handles sensitive credentials. The pipeline works but during a security audit, the team discovered that secrets are being leaked into the workflow logs. Multiple secrets are exposed through various mechanisms — direct echo, environment variable dumps, and conditional expressions.

## 🔴 Difficulty: Medium

## 📋 Error Output

The workflow runs successfully, but the logs show:

```
Run echo "=== Debug Info ==="
=== Debug Info ===
API Key: ***
DB Password: FAKE-KEY-a8f3k2j5n9m1x4p7
All env vars:
API_KEY=FAKE-KEY-a8f3k2j5n9m1x4p7
DB_PASSWORD=super-secret-password-123
GITHUB_TOKEN=***
HOME=/home/runner
...
=== End Debug ===

Run echo "Setting up API with key: FAKE-KEY-a8f3k2j5n9m1x4p7"
Setting up API with key: FAKE-KEY-a8f3k2j5n9m1x4p7

WARNING: Secret value leaked in workflow logs!
GitHub Actions masks secrets that are directly referenced with ${{ secrets.* }}
but NOT when they are assigned to environment variables and then printed.

Run curl -X POST https://fake-webhook.example.com/services/TXXXX/BXXXX/placeholder
```

**Security Alert**: Secrets are visible in plain text in the Actions log output.

## 🐛 Debugging Steps

1. Review the workflow for direct secret usage in `echo`/`run` commands:
   ```bash
   grep -n "secrets\." .github/workflows/broken-build.yml
   ```

2. Check for environment variable dumps:
   ```bash
   grep -n "env |" .github/workflows/broken-build.yml
   ```

3. Look for secrets used in `if:` conditions (these get logged in debug mode):
   ```bash
   grep -n "if:.*secrets" .github/workflows/broken-build.yml
   ```

4. Check if secrets are assigned to env vars and then echoed

5. Review notification steps for credential exposure in message bodies

## 💡 Hints

<details>
<summary>Hint 1</summary>
GitHub Actions masks `${{ secrets.X }}` in logs with `***`, but if you assign a secret to an environment variable and then `echo` that variable, the value is exposed in plain text.
</details>

<details>
<summary>Hint 2</summary>
The `env | sort` command dumps ALL environment variables including those set from secrets. The `DB_PASSWORD` env var contains the raw secret value.
</details>

<details>
<summary>Hint 3</summary>
Using secrets in `if:` conditions is problematic — in debug mode the condition evaluation is logged. Also, secrets should never appear in notification message bodies or curl commands that get logged.
</details>

## 🔧 Issues to Fix

1. `echo "${{ secrets.API_KEY }}"` — directly printing secret (GitHub masks this but it's bad practice)
2. `echo "${DB_PASSWORD}"` — env var from secret printed in plain text (NOT masked)
3. `env | sort` — dumps all environment variables including secrets
4. `echo "Setting up API with key: $API_KEY"` — leaks secret via env var
5. `if: ${{ secrets.DEPLOY_TOKEN != '' }}` — secrets in conditions can leak in debug mode
6. Slack notification includes `${{ secrets.API_KEY }}` in the message body
7. Slack webhook URL exposed directly in curl command
