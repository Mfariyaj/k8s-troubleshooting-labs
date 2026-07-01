#!/bin/bash
set -e

echo "============================================"
echo "  Lab 14: LDAP Group Sync Failures"
echo "  Difficulty: ⭐⭐⭐⭐⭐ Expert"
echo "============================================"
echo ""
echo "Scenario: Jenkins LDAP authentication works but authorization matrix"
echo "groups don't map correctly. Users can login but have no permissions."
echo ""

cd "$(dirname "$0")"

# Stop any existing instance
docker compose down -v 2>/dev/null || true

# Start services
echo "Starting OpenLDAP and Jenkins..."
docker compose up -d

echo ""
echo "Waiting for OpenLDAP to initialize..."
sleep 10

echo "Loading LDAP test data..."
# Add organizational units and groups
docker exec openldap-lab ldapadd -x -H ldap://localhost -D "cn=admin,dc=company,dc=internal" -w admin-secret << 'EOF' 2>/dev/null || true
dn: ou=people,dc=company,dc=internal
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=company,dc=internal
objectClass: organizationalUnit
ou: groups

dn: uid=jsmith,ou=people,dc=company,dc=internal
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: John Smith
sn: Smith
uid: jsmith
displayName: John Smith
mail: jsmith@company.internal
uidNumber: 1001
gidNumber: 1001
homeDirectory: /home/jsmith
userPassword: password123

dn: uid=mjones,ou=people,dc=company,dc=internal
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: Mary Jones
sn: Jones
uid: mjones
displayName: Mary Jones
mail: mjones@company.internal
uidNumber: 1002
gidNumber: 1002
homeDirectory: /home/mjones
userPassword: password123

dn: uid=admin_user,ou=people,dc=company,dc=internal
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
cn: Admin User
sn: User
uid: admin_user
displayName: Admin User
mail: admin@company.internal
uidNumber: 1003
gidNumber: 1003
homeDirectory: /home/admin_user
userPassword: password123

dn: cn=Jenkins-Admins,ou=groups,dc=company,dc=internal
objectClass: groupOfNames
cn: Jenkins-Admins
description: Jenkins Administrators
member: uid=admin_user,ou=people,dc=company,dc=internal
member: cn=team-leads,ou=groups,dc=company,dc=internal

dn: cn=Developers,ou=groups,dc=company,dc=internal
objectClass: groupOfNames
cn: Developers
description: Development Team
member: uid=jsmith,ou=people,dc=company,dc=internal
member: uid=mjones,ou=people,dc=company,dc=internal

dn: cn=DevOps-Engineers,ou=groups,dc=company,dc=internal
objectClass: groupOfNames
cn: DevOps-Engineers
description: DevOps Team
member: uid=jsmith,ou=people,dc=company,dc=internal

dn: cn=team-leads,ou=groups,dc=company,dc=internal
objectClass: groupOfNames
cn: team-leads
description: Team Leaders (nested in Jenkins-Admins)
member: uid=mjones,ou=people,dc=company,dc=internal

dn: cn=stakeholders,ou=groups,dc=company,dc=internal
objectClass: groupOfNames
cn: stakeholders
description: Project Stakeholders
member: uid=mjones,ou=people,dc=company,dc=internal
EOF

echo ""
echo "Waiting for Jenkins to start..."
sleep 20

echo ""
echo "============================================"
echo "  Lab deployed!"
echo "============================================"
echo ""
echo "Jenkins UI: http://localhost:8080"
echo "phpLDAPadmin: https://localhost:6443"
echo ""
echo "Test Users (all password: password123):"
echo "  jsmith  - member of: Developers, DevOps-Engineers"
echo "  mjones  - member of: Developers, team-leads, stakeholders"
echo "  admin_user - member of: Jenkins-Admins"
echo ""
echo "Your task: Fix the LDAP + authorization configuration so that:"
echo "  1. jsmith has developer permissions (build, read)"
echo "  2. mjones has admin permissions (via nested team-leads → Jenkins-Admins)"
echo "  3. admin_user has full admin access"
echo ""
echo "Current symptom: All users can LOG IN but have ZERO permissions"
echo "(not even Job/Read — they see 'Access Denied' everywhere)"
echo ""
