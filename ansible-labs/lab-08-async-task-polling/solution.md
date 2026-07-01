## Solution: Async Task Polling Failure

### Root Cause

When using `async` with `poll: 0` (fire-and-forget), the playbook never checks if
the async task completed. Without an `async_status` follow-up task with `register`
+ `until` loop, long-running tasks are launched but their results are lost.

### Step-by-Step Fix

1. **Register the async task result:**
```yaml
- name: Start long-running task
  command: /opt/scripts/long_task.sh
  async: 300
  poll: 0
  register: long_task_job
```

2. **Add async_status task to poll for completion:**
```yaml
- name: Wait for task to finish
  async_status:
    jid: "{{ long_task_job.ansible_job_id }}"
  register: job_result
  until: job_result.finished
  retries: 30
  delay: 10
```

### Fixed Configuration

**playbook.yml:**
```yaml
---
- name: Run async tasks properly
  hosts: webservers
  tasks:
    - name: Start long-running database migration
      command: /opt/scripts/migrate_db.sh
      async: 600
      poll: 0
      register: migration_job

    - name: Do other work in parallel
      command: echo "Other tasks while migration runs"

    - name: Wait for migration to complete
      async_status:
        jid: "{{ migration_job.ansible_job_id }}"
      register: migration_result
      until: migration_result.finished
      retries: 60
      delay: 10

    - name: Verify migration succeeded
      debug:
        msg: "Migration completed with rc={{ migration_result.rc }}"
```

### Verification

```bash
# Run the playbook
ansible-playbook playbook.yml -v

# Output should show:
# 1. Task fires asynchronously
# 2. Other tasks run
# 3. async_status polls until finished
# 4. Final status reported with "finished": 1
```

### Key Takeaway

`poll: 0` means "don't wait" — you MUST follow up with `async_status` to check
results. Always register the async task, then use `until: result.finished` with
appropriate `retries` and `delay`.
