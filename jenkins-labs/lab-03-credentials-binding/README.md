# Lab 03: Credentials Binding

## Difficulty: ⭐⭐ Medium

## Scenario

A pipeline uses Jenkins credentials for AWS and Docker registry access but fails at the credentials binding step with mismatched IDs and types.

## Console Error Output

```
ERROR: Could not find credentials entry with ID 'aws-secret-key'
[Pipeline] End of Pipeline
ERROR: Credentials 'docker-registry-token' is of type 'StringCredentialsImpl' 
but 'usernamePassword' binding requires 'UsernamePasswordCredentialsImpl'

hudson.AbortException: Could not find credentials entry with ID 'aws-secret-key'
    at com.cloudbees.plugins.credentials.CredentialsProvider.findCredentialById(...)
```

## Hints

1. Check `Manage Jenkins → Credentials` for actual credential IDs
2. `credentials()` in the `environment` block auto-detects type — but the ID must exist
3. `usernamePassword()` binding only works with Username/Password credentials, not Secret Text
4. For Secret Text, use `string(credentialsId: '...', variable: '...')`

## What to Fix

- Correct the credential ID from `aws-secret-key` to the actual configured ID
- Change `usernamePassword()` to `string()` if the credential is Secret Text type
- Or reconfigure the credential in Jenkins to match the expected type
