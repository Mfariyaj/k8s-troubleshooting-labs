## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 14: LDAP Group Sync — Authentication Works, Authorization Broken

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your organization uses OpenLDAP for centralized authentication. Jenkins is configured with the LDAP security realm and the Role-Based Authorization Strategy plugin. Users can successfully authenticate (login works), but once logged in they have ZERO permissions — not even `Overall/Read`. They see "Access Denied" on every page after login.

The LDAP directory has nested groups (team-leads is a member of Jenkins-Admins), mixed-case group names, and uses `groupOfNames` object class with `member` attributes.

LDAP Structure:
```
dc=company,dc=internal
├── ou=people
│   ├── uid=jsmith (member of: Developers, DevOps-Engineers)
│   ├── uid=mjones (member of: Developers, team-leads, stakeholders)
│   └── uid=admin_user (member of: Jenkins-Admins)
└── ou=groups
    ├── cn=Jenkins-Admins (members: admin_user, cn=team-leads)
    ├── cn=Developers (members: jsmith, mjones)
    ├── cn=DevOps-Engineers (members: jsmith)
    ├── cn=team-leads (members: mjones) ← nested in Jenkins-Admins
    └── cn=stakeholders (members: mjones)
```

## What You'll Observe

Login succeeds:
```
2026-07-01 14:30:22.100+0000 [id=45] INFO hudson.security.LDAPSecurityRealm#authenticate:
  Successfully authenticated user 'jsmith' against LDAP server ldap://openldap:389
```

But immediately after:
```
2026-07-01 14:30:22.150+0000 [id=45] WARNING hudson.security.ACL#hasPermission:
  User 'jsmith' has no permissions. Groups resolved: []
  
2026-07-01 14:30:22.155+0000 [id=45] FINE org.jenkinsci.plugins.rolestrategy.RoleMap#hasPermission:
  Checking permissions for user 'jsmith' with authorities: [authenticated]
  No role entries match user or their groups.
  
Access Denied: jsmith is missing the Overall/Read permission
```

When checking /whoAmI/ page:
```
User: jsmith
Authorities:
  - authenticated
  (No groups listed!)
```

Expected authorities:
```
Authorities:
  - authenticated
  - Developers
  - DevOps-Engineers
```

## Your Task

Fix all 4 LDAP/authorization issues:
1. Fix `groupSearchFilter` — currently finds groups by CN, should find groups by member DN
2. Fix group name case sensitivity — LDAP returns "Developers" but matrix has "developers"
3. Enable nested group resolution for "team-leads" → "Jenkins-Admins" 
4. Fix DN vs CN format in the authorization matrix entries

## Hints

<details>
<summary>Hint 1</summary>
The `groupSearchFilter` `(& (cn={0}) (objectclass=groupOfNames))` is wrong. `{0}` here gets substituted with the user's DN. You're searching for a group whose CN equals the user's DN — which will never match. For `groupOfNames` with `member` attribute, use: `(& (member={0}) (objectclass=groupOfNames))` — this finds groups where the user's DN is listed as a member.
</details>

<details>
<summary>Hint 2</summary>
Check the `groupIdStrategy` setting. It's set to `caseSensitive`, which means "Developers" (from LDAP) will NOT match "developers" (in the role matrix). Change it to `caseInsensitive`, OR update the role entries to match the exact case from LDAP. Also, the authorization entries use full DN format (`cn=Jenkins-Admins,ou=groups,...`) but the LDAP plugin only populates the CN as the group name (just "Jenkins-Admins").
</details>

<details>
<summary>Hint 3</summary>
For nested group resolution, the default `fromGroupSearch` strategy doesn't recurse. You need either: (a) set `groupMembershipStrategy` to `fromUserRecord` with the `memberOf` overlay enabled on LDAP, or (b) use a recursive filter like `(member:1.2.840.113556.1.4.1941:={0})` (AD-style, not available in OpenLDAP), or (c) configure the LDAP server with the `memberOf` overlay and use `fromUserRecord` strategy.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Test LDAP connectivity directly
docker exec openldap-lab ldapsearch -x -H ldap://localhost -D "cn=admin,dc=company,dc=internal" -w admin-secret -b "dc=company,dc=internal"

# Search for user's groups
docker exec openldap-lab ldapsearch -x -H ldap://localhost -D "cn=admin,dc=company,dc=internal" -w admin-secret -b "ou=groups,dc=company,dc=internal" "(member=uid=jsmith,ou=people,dc=company,dc=internal)"

# Test with the WRONG filter (what Jenkins is using)
docker exec openldap-lab ldapsearch -x -H ldap://localhost -D "cn=admin,dc=company,dc=internal" -w admin-secret -b "ou=groups,dc=company,dc=internal" "(cn=uid=jsmith,ou=people,dc=company,dc=internal)"

# Check user entry
docker exec openldap-lab ldapsearch -x -H ldap://localhost -D "cn=admin,dc=company,dc=internal" -w admin-secret -b "ou=people,dc=company,dc=internal" "(uid=jsmith)"

# Check Jenkins whoAmI page for group resolution
curl -u jsmith:password123 -s http://localhost:8080/whoAmI/api/json | jq

# View Jenkins security configuration
curl -u admin:admin -s http://localhost:8080/configuration-as-code/export 2>/dev/null | grep -A 20 "ldap"

# Test LDAP authentication via Jenkins API
curl -u jsmith:password123 -s http://localhost:8080/api/json

# Check role-strategy assignments
curl -u admin:admin -s http://localhost:8080/role-strategy/api/json

# View phpLDAPadmin for visual LDAP inspection
echo "phpLDAPadmin: https://localhost:6443 (login: cn=admin,dc=company,dc=internal / admin-secret)"

# Verbose LDAP debug in Jenkins
docker exec jenkins-ldap-lab cat /var/jenkins_home/logs/ldap*.log 2>/dev/null
# Enable LDAP debug: Manage Jenkins → System Log → Add Logger: hudson.security.LDAPSecurityRealm = FINEST
```

## Clean Up

```bash
./cleanup.sh
```
