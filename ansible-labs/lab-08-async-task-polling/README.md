## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (sets up environment and runs broken playbook)
2. Read the Ansible error output carefully
3. Investigate: Check playbook.yml, inventory, roles, templates
4. Fix the broken configuration
5. Re-run: `ansible-playbook playbook.yml` to verify
6. Check `solution.md` if stuck

---

# Lab 08: Async Task Polling Issue

## Difficulty: ⭐⭐⭐ Hard

## Scenario
You're running a long-running package upgrade and database backup asynchronously (`async: 30`, `poll: 0`). The playbook fires and forgets these tasks but never uses `async_status` to check if they completed. The deployment reports success even if the async tasks fail silently in the background.

## Expected Error Output
```
PLAY [Run long-running tasks asynchronously] ***********************************

TASK [Start long-running package upgrade] **************************************
changed: [web1]

TASK [Start long-running database backup] **************************************
changed: [web1]

TASK [Perform other tasks while waiting] ***************************************
ok: [web1] => {"msg": "Doing other work while async jobs run..."}

TASK [Deploy application code] *************************************************
changed: [web1]

TASK [Final status message] ****************************************************
ok: [web1] => {"msg": "Deployment complete! (But did the async tasks finish?)"}

PLAY RECAP *********************************************************************
web1 : ok=5    changed=3    unreachable=0    failed=0
# NOTE: Playbook succeeds but async tasks may have FAILED silently!
```

## Hints
1. With `poll: 0`, Ansible fires the task and moves on — it never checks if it finished.
2. You need `async_status` with the registered job ID to check task completion.
3. Add a `until` loop with `async_status` to wait for each job and catch failures.

## Troubleshooting Commands
```bash
ansible-playbook playbook.yml --syntax-check
grep -n "async\|poll\|register\|async_status" playbook.yml
ansible-doc async_status
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml --check
```
