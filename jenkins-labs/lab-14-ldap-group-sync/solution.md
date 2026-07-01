## Solution: LDAP Group Sync

### Root Cause

1. `groupSearchFilter` is `(& (cn={0}) (objectclass=groupOfNames))` — searches by CN matching user DN, which never matches. Should search by `member` attribute.
2. `groupIdStrategy` is `caseSensitive` — LDAP returns "Developers" but role matrix has "developers"
3. Nested groups (team-leads → Jenkins-Admins) are not resolved — default strategy doesn't recurse
4. Authorization entries use full DN (`cn=Jenkins-Admins,ou=groups,...`) but plugin only populates CN

### Step-by-Step Fix

1. Fix `groupSearchFilter` to `(& (member={0}) (objectclass=groupOfNames))`
2. Change `groupIdStrategy` to `caseInsensitive`
3. Enable nested group resolution via `memberOf` overlay or recursive search
4. Use CN-only in authorization entries (e.g., `Jenkins-Admins` not full DN)

### Fixed CasC Security Configuration

```yaml
jenkins:
  securityRealm:
    ldap:
      configurations:
        - server: "ldaps://ldap.company.internal:636"
          rootDN: "dc=company,dc=internal"
          managerDN: "cn=jenkins-svc,ou=service-accounts,dc=company,dc=internal"
          managerPasswordSecret: "ldap-manager-password"
          userSearchBase: "ou=people"
          userSearch: "uid={0}"
          groupSearchBase: "ou=groups"
          # Fixed: search for groups where user is a member
          groupSearchFilter: "(& (member={0}) (objectclass=groupOfNames))"
          inhibitInferRootDN: false
      disableMailAddressResolver: false
      # Fixed: case-insensitive matching
      groupIdStrategy: "caseInsensitive"
      userIdStrategy: "caseInsensitive"

  authorizationStrategy:
    roleBased:
      roles:
        global:
          - name: "admin"
            permissions:
              - "Overall/Administer"
            entries:
              # Fixed: use CN only, not full DN
              - group: "Jenkins-Admins"
          - name: "developer"
            permissions:
              - "Overall/Read"
              - "Job/Build"
              - "Job/Read"
            entries:
              - group: "Developers"
              - group: "DevOps-Engineers"
```

### Enable Nested Groups (OpenLDAP memberOf overlay)

```bash
# On the LDAP server, enable memberOf overlay so user records include group membership
# This allows fromUserRecord strategy to resolve nested groups
ldapmodify -Y EXTERNAL -H ldapi:/// <<EOF
dn: cn=module,cn=config
changetype: add
objectClass: olcModuleList
olcModuleLoad: memberof.la
EOF
```

### Verification

```bash
# Test group resolution with correct filter
ldapsearch -x -H ldap://localhost -D "cn=admin,dc=company,dc=internal" -w admin-secret \
  -b "ou=groups,dc=company,dc=internal" "(member=uid=jsmith,ou=people,dc=company,dc=internal)"
# Should return: Developers, DevOps-Engineers

# Check /whoAmI/ page — authorities should list group names
curl -u jsmith:password123 http://localhost:8080/whoAmI/api/json | jq '.authorities'
# Expected: ["authenticated", "Developers", "DevOps-Engineers"]
```
