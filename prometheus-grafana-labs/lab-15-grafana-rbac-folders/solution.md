# Lab 15 - Grafana RBAC and Folders

## Root Cause

The Grafana folder provisioning and RBAC configuration has three issues:
1. Folder UIDs in dashboard provisioning do not match actual folder UIDs
2. Nested folder inheritance is not enabled (required for cascading permissions)
3. Anonymous access is enabled, bypassing all RBAC controls

## Symptoms

- Dashboards appear in "General" folder instead of designated folders
- Users can see dashboards they should not have access to
- Folder permissions are not inherited by sub-folders
- Provisioning logs show "folder not found" warnings

## Fix Steps

1. Fix folder UIDs in provisioning config to match actual folder UIDs
2. Enable nested folder permission inheritance in `grafana.ini`
3. Disable anonymous access in `grafana.ini`

## Corrected Configurations

`grafana.ini`:
```ini
[auth.anonymous]
enabled = false

[feature_toggles]
enable = nestedFolders

[rbac]
permission_inheritance = true
```

Dashboard provisioning (`provisioning/dashboards/dashboards.yml`):
```yaml
apiVersion: 1
providers:
  - name: 'default'
    orgId: 1
    folder: 'Infrastructure'
    folderUid: 'infrastructure'
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /var/lib/grafana/dashboards
      foldersFromFilesStructure: false
```

## Verification

```bash
# Restart Grafana
docker-compose restart grafana

# Verify anonymous access is disabled (should return 401)
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/dashboards/home

# Verify folders exist with correct UIDs
curl -s -u admin:admin http://localhost:3000/api/folders | jq '.[].uid'

# Verify dashboards are in correct folders
curl -s -u admin:admin http://localhost:3000/api/search?type=dash-db | jq '.[].folderUid'
```

## Key Takeaways

- Folder UIDs must be consistent between provisioning files and dashboard JSON
- Enable `nestedFolders` feature toggle for hierarchical permissions
- Always disable anonymous access when using RBAC
- Test with non-admin users to verify permission boundaries
