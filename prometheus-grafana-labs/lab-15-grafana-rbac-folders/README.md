# Lab 15: Grafana RBAC & Folder Permissions — Teams Can't See Dashboards

## ⭐⭐⭐⭐⭐ Expert Level

### Scenario

Your organization has two engineering teams (Team A and Team B) sharing a single Grafana instance. Each team should only see their own dashboards organized in dedicated folders. The Platform team implemented Grafana's RBAC with folder-based permissions, but it's completely broken:

1. **Team A (Alice)** can't see ANY dashboards — not even her team's dashboards
2. **Team B (Bob)** can't see his team's dashboards either
3. **Anonymous users** can see EVERYTHING (including confidential revenue dashboards)
4. **Provisioned dashboards** ended up in the wrong folder (or no folder at all)
5. **Nested folders** don't inherit parent permissions

The security team flagged this as a P1 incident because confidential business metrics are exposed to unauthenticated users.

### Environment
- Grafana Enterprise v10.4.0 with RBAC enabled
- Folder-based access control with nested folders
- Dashboard provisioning via YAML
- Two teams with dedicated users
- Docker Compose orchestration

### Symptoms

```
# Alice (Team A member) logs in — sees no dashboards
$ curl -s -u alice:alice123 http://localhost:3000/api/search?type=dash-db | jq .
[]

# Bob (Team B member) — also sees nothing
$ curl -s -u bob:bob123 http://localhost:3000/api/search?type=dash-db | jq .
[]

# But anonymous access sees EVERYTHING (security violation!)
$ curl -s http://localhost:3000/api/search?type=dash-db | jq '.[].title'
"Team A Production Dashboard"

# Dashboard is provisioned to wrong folder (General instead of Team A)
$ curl -s -u admin:admin http://localhost:3000/api/search?type=dash-db | jq '.[0]'
{
  "id": 1,
  "uid": "team-a-prod-dashboard",
  "title": "Team A Production Dashboard",
  "uri": "db/team-a-production-dashboard",
  "url": "/d/team-a-prod-dashboard/team-a-production-dashboard",
  "type": "dash-db",
  "folderUid": "",
  "folderTitle": "General",
  "folderUrl": ""
}

# Folder exists but dashboard isn't in it
$ curl -s -u admin:admin http://localhost:3000/api/folders | jq '.[].title'
"Team A Dashboards"
"Team B Dashboards"
"Team A Production"

# Check folder permissions — Team A only has View (permission:1), not Edit
$ curl -s -u admin:admin http://localhost:3000/api/folders/team-a-folder/permissions | jq .
[
  {"role": "Viewer", "permission": 1},
  {"teamId": 1, "team": "Team A", "permission": 1}
]

# Nested folder doesn't inherit parent permissions
$ curl -s -u admin:admin http://localhost:3000/api/folders/team-a-prod/permissions | jq .
[]

# Users have Org Admin role (overrides folder RBAC)
$ curl -s -u admin:admin http://localhost:3000/api/org/users | jq '.[] | {login, role}'
{"login": "admin", "role": "Admin"}
{"login": "alice", "role": "Admin"}
{"login": "bob", "role": "Admin"}

# Grafana log shows provisioning warnings
$ docker logs grafana-rbac 2>&1 | grep -i "provision\|folder\|permission"
logger=provisioning.dashboard t=2024-03-15T12:00:01Z level=warn 
  msg="folder not found, creating" folder_uid=team-a-folder-WRONG-UID
logger=provisioning.dashboard t=2024-03-15T12:00:01Z level=error 
  msg="failed to provision dashboard to folder" 
  err="folder with UID team-a-folder-WRONG-UID not found" 
  dashboard="Team A Production Dashboard"

# Anonymous auth is enabled
$ curl -s http://localhost:3000/api/org | jq .
{"id":1,"name":"Main Org."}
```

### Your Task

1. Fix dashboard provisioning — correct the folder UID mismatch
2. Disable anonymous access to prevent unauthorized viewing
3. Fix user org roles — change from Admin to Viewer/Editor as appropriate
4. Fix folder permissions — Team A should be Editor on their folder
5. Enable nested folder permission inheritance
6. Verify: Alice sees only Team A dashboards, Bob sees only Team B, anonymous gets login page

### Useful Commands

```bash
# Check all services
docker compose ps

# View Grafana logs
docker logs grafana-rbac --tail 50

# List folders
curl -s -u admin:admin http://localhost:3000/api/folders | jq .

# Search dashboards (as admin)
curl -s -u admin:admin http://localhost:3000/api/search?type=dash-db | jq .

# Search dashboards (as Alice — Team A)
curl -s -u alice:alice123 http://localhost:3000/api/search?type=dash-db | jq .

# Search dashboards (as Bob — Team B)
curl -s -u bob:bob123 http://localhost:3000/api/search?type=dash-db | jq .

# Search dashboards (anonymous)
curl -s http://localhost:3000/api/search?type=dash-db | jq .

# Check folder permissions
curl -s -u admin:admin http://localhost:3000/api/folders/team-a-folder/permissions | jq .
curl -s -u admin:admin http://localhost:3000/api/folders/team-b-folder/permissions | jq .

# Check user org roles
curl -s -u admin:admin http://localhost:3000/api/org/users | jq .

# Update user org role
curl -s -X PATCH -u admin:admin http://localhost:3000/api/org/users/2 \
  -H "Content-Type: application/json" \
  -d '{"role":"Viewer"}'

# Check teams and members
curl -s -u admin:admin http://localhost:3000/api/teams/search | jq .
curl -s -u admin:admin http://localhost:3000/api/teams/1/members | jq .
curl -s -u admin:admin http://localhost:3000/api/teams/2/members | jq .

# Check Grafana settings
curl -s -u admin:admin http://localhost:3000/api/admin/settings | jq '.auth'
curl -s -u admin:admin http://localhost:3000/api/admin/settings | jq '."auth.anonymous"'

# Update folder permissions (set Editor for team)
curl -s -X POST -u admin:admin http://localhost:3000/api/folders/team-a-folder/permissions \
  -H "Content-Type: application/json" \
  -d '{"items":[{"teamId":1,"permission":2}]}'

# Check provisioning status
curl -s -u admin:admin http://localhost:3000/api/admin/provisioning/dashboards/reload -X POST

# Restart Grafana after config changes
docker compose restart grafana
```

### Hints

<details>
<summary>Hint 1</summary>
The dashboard provisioning file uses `folderUid: 'team-a-folder-WRONG-UID'` but the actual folder created by the setup script has UID `team-a-folder`. Fix the `dashboards.yml` provisioning file to use the correct UID. After fixing, either restart Grafana or call the provisioning reload API. Also check that nested folder `team-a-prod` is being used correctly.
</details>

<details>
<summary>Hint 2</summary>
Multiple RBAC issues conspire here: (1) `auto_assign_org_role = Admin` in grafana.ini means Alice and Bob are org Admins — they bypass folder permissions entirely, but the folder permission itself gives only View (permission:1) instead of Edit (permission:2). (2) Anonymous access (`auth.anonymous.enabled = true`) lets anyone see all content. (3) Change org role to Viewer for both users, disable anonymous auth, and set folder permissions to Editor (permission:2) for each team.
</details>

<details>
<summary>Hint 3</summary>
For nested folders: `grafana.ini` has `nested_folder_permissions_inheritance = false`. This means Team A having access to "Team A Dashboards" folder does NOT automatically grant access to "Team A Production" subfolder. Either: (1) Set `nested_folder_permissions_inheritance = true` and restart, or (2) Explicitly set permissions on each nested folder. Also ensure `nestedFolders` feature toggle is enabled (it is) and that the Grafana version supports it (10.4 does).
</details>

---

**Category:** Grafana / RBAC & Access Control  
**Difficulty:** ⭐⭐⭐⭐⭐ Expert  
**Time Estimate:** 20-35 minutes  
**Skills Tested:** Grafana RBAC model, folder permissions, dashboard provisioning, nested folders, anonymous auth, org roles vs folder roles, security incident response
