## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 09: RBAC Fiat Denied — Authorization Blocking Access

## Difficulty: 🔴 Advanced

---

## 📚 What You'll Learn

**Fiat** is Spinnaker's authorization (AuthZ) service. It controls who can do what:

- **Application permissions**: READ, WRITE, EXECUTE per application
- **Account permissions**: Which cloud accounts users can deploy to
- **Pipeline permissions**: Who can trigger/modify pipelines
- **Service accounts**: Machine identities for automated pipelines

How Fiat works:
1. User authenticates (via Gate → OAuth/SAML/LDAP)
2. Fiat maps user to **roles** (from LDAP groups, GitHub teams, etc.)
3. Roles are checked against application/account permissions
4. If no matching role has required permission → 403 Forbidden

Key gotchas:
- Fiat caches role memberships — changes aren't immediate
- Service accounts need explicit roles for automated triggers
- If `fiat.enabled=true` but no permissions are set, apps become inaccessible
- Admin accounts bypass Fiat checks — easy to miss issues during testing
- Role names are case-sensitive and must exactly match the identity provider

---

## 🔧 Scenario

Users in the `dev-team` group can't access the `myapp` application or execute its pipelines, despite being configured. The issues are:

1. Fiat's role provider is configured for LDAP but the `groupSearchBase` has a typo (`ou=Gruops` instead of `ou=Groups`)
2. Application permissions in Front50 grant access to `developers` role but the LDAP group is `dev-team`
3. The pipeline's `runAsUser` service account doesn't have EXECUTE permission on the application

---

## 💥 Expected Error Output

In Spinnaker UI:
```
403 Forbidden
Access denied to application 'myapp'
User 'john.doe' with roles [dev-team] does not have permission 
to access application 'myapp'.
Required roles: [developers]

Pipeline trigger failed:
  Service account 'spinnaker-pipeline-svc' does not have 
  EXECUTE permission on application 'myapp'.
  
Fiat sync log:
  WARN UserRolesSyncer - Could not resolve roles for user john.doe
  from LDAP. GroupSearchBase: ou=Gruops,dc=example,dc=com returned 
  0 results.
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Check Fiat's configuration for the LDAP group search base. A typo in the LDAP path means Fiat can't find any groups, so users appear to have no roles.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Even with correct LDAP groups, the application permissions must reference the actual group name. If the LDAP group is `dev-team`, the application WRITE permission must list `dev-team`, not `developers`.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Fix typo in fiat-local.yml: `ou=Gruops` → `ou=Groups`, 2) Change application permissions from `developers` to `dev-team` in application-permissions.json, 3) Add `dev-team` role to the service account or grant the service account EXECUTE permission.
</details>

---

## 🛠️ Useful Commands

```bash
# Check Fiat service health and sync status
kubectl logs -n spinnaker spin-fiat-xxx | grep -i "sync\|role\|error"

# Force Fiat to re-sync roles
curl -X POST http://localhost:7003/roles/sync

# Check a user's resolved roles
curl http://localhost:7003/authorize/john.doe | jq .

# List service accounts
curl http://localhost:8084/serviceAccounts | jq '.[].name'

# Check application permissions
curl http://localhost:8084/applications/myapp | jq '.attributes.permissions'

# Fiat admin: check all users
curl http://localhost:7003/authorize | jq .
```

---

## 📖 References

- https://spinnaker.io/docs/setup/security/authorization/
- https://spinnaker.io/docs/setup/security/authorization/ldap/
- https://spinnaker.io/docs/reference/architecture/authz/
- https://spinnaker.io/docs/setup/security/authorization/service-accounts/

---

## 🏁 Success Criteria

- Users in `dev-team` can access the `myapp` application
- Pipeline triggers execute successfully with the service account
- Fiat sync resolves LDAP groups correctly
- No 403 errors for authorized users
