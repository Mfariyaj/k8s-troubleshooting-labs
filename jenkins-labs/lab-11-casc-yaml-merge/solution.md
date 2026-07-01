## Solution: JCasC YAML Merge Failures

### Root Cause

1. YAML anchors (`*ldap-server-config`) are file-scoped — cross-file references fail
2. After plugin upgrade, `securityRealm` belongs under `jenkins:` directly, not a `security:` block
3. Credential type `usernamePassword` renamed to `usernamePasswordCredentialsImpl`; `string` renamed to `secretText`
4. Duplicate `jenkins:` keys across files cause merge conflicts

### Step-by-Step Fix

1. Inline anchor values in each file (don't reference across files)
2. Move `securityRealm` and `authorizationStrategy` under `jenkins:` top-level key
3. Rename credential types: `usernamePassword` → `usernamePasswordCredentialsImpl`, `string` → `secretText`
4. Remove duplicate `jenkins:` blocks — consolidate into one file or use distinct keys

### Fixed casc/credentials.yaml

```yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          - usernamePasswordCredentialsImpl:
              scope: GLOBAL
              id: "docker-registry-creds"
              username: "deploy-bot"
              password: "${DOCKER_REGISTRY_PASSWORD}"
              description: "Docker Registry Credentials"
          - secretText:
              scope: GLOBAL
              id: "sonar-token"
              secret: "${SONARQUBE_TOKEN}"
              description: "SonarQube Analysis Token"
          - secretText:
              scope: GLOBAL
              id: "slack-webhook-token"
              secret: "${SLACK_WEBHOOK_URL}"
              description: "Slack Notification Webhook"
          - basicSSHUserPrivateKey:
              scope: GLOBAL
              id: "ssh-agent-key"
              username: "jenkins"
              passphrase: ""
              privateKeySource:
                directEntry:
                  privateKey: "${SSH_PRIVATE_KEY}"
          - usernamePasswordCredentialsImpl:
              scope: GLOBAL
              id: "ldap-bind-creds"
              username: "cn=jenkins-svc,ou=service-accounts,dc=company,dc=internal"
              password: "${LDAP_BIND_PASSWORD}"
```

### Fixed casc/security.yaml (merge into jenkins.yaml)

Remove the separate `security:` block. Place `securityRealm` and `authorizationStrategy` under `jenkins:` in `jenkins.yaml`. Remove the duplicate `jenkins:` section from security.yaml entirely.

### Verification

```bash
docker logs jenkins-casc-lab 2>&1 | grep -i "casc\|error"
# No "undefined alias" or "No configurator for type" errors
curl -s http://localhost:8080/configuration-as-code/export  # Should return full config
```
