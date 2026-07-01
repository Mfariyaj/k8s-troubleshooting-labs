# Lab 13: Strategy Plugin Deadlock & Race Condition ⭐⭐⭐⭐⭐

## Difficulty: Expert

## Scenario

Your infrastructure team is deploying cluster configuration across 20 nodes. For speed, they've configured `strategy: free` so tasks don't have to wait for slow hosts. They also set `serial: 1` thinking it would serialize shared resource access.

**The problem is multi-layered:**
- `serial` is completely ignored when `strategy: free` is set — all 20 hosts execute simultaneously
- Multiple hosts write to the same shared files without any locking mechanism
- The SSH connection configuration causes pool exhaustion under high parallelism
- A read-modify-write shell pattern introduces a classic race condition on the node counter
- The final verification task uses `run_once` which behaves unpredictably with `strategy: free`

The result: intermittent failures, corrupted shared state, missing node registrations, and incorrect counters. The failure is non-deterministic — sometimes it works, sometimes it doesn't.

## What You'll Observe

```
$ ansible-playbook playbook.yml -v

[WARNING]: While constructing a mapping from /tmp/ansible-lab13/shared/cluster-config.yml...

PLAY [Distributed configuration deployment] ************************************

TASK [Create node working directory] ********************************************
ok: [node-01]
ok: [node-05]
ok: [node-03]
ok: [node-02]
...

TASK [Register node in shared cluster configuration] ****************************
changed: [node-01]
changed: [node-07]
changed: [node-03]
...

TASK [Update shared node counter] ***********************************************
changed: [node-01]
changed: [node-02]
changed: [node-15]
changed: [node-03]
...

TASK [Final node count verification] ********************************************
fatal: [node-01]: FAILED! => {"changed": true, "msg": "non-zero return code", "rc": 1, 
"stdout": "RACE CONDITION: Expected 20 nodes, got 7"}
```

Intermittent symptoms:
- Node count is always less than 20 (race condition on increment)
- Some nodes missing from cluster-config.yml (lineinfile race)
- Certificate requests file has interleaved/corrupted lines
- Occasional SSH connection failures under load

## Environment

- Ansible 2.15+ with `strategy: free`
- 20 simulated hosts (local connection)
- Shared filesystem (simulated with `/tmp`)
- High fork count (50)

## Files to Investigate

| File | Purpose |
|------|---------|
| `playbook.yml` | Playbook with strategy:free and serial conflict |
| `inventory.ini` | 20-host inventory |
| `ansible.cfg` | Configuration with high forks, no SSH multiplexing |

## Hints

<details>
<summary>Hint 1</summary>
`serial` and `strategy: free` are fundamentally incompatible. When strategy is 'free', the `serial` keyword is silently ignored. You need to either switch to `strategy: linear` with `serial: 1`, or use the `throttle` keyword on individual tasks that access shared resources.
</details>

<details>
<summary>Hint 2</summary>
The `throttle` keyword (Ansible 2.9+) can be set at the task level to limit how many hosts execute that specific task simultaneously. Set `throttle: 1` on tasks that modify shared files. This works WITH strategy:free — other tasks remain parallel while throttled tasks serialize.
</details>

<details>
<summary>Hint 3</summary>
The SSH configuration disables ControlMaster multiplexing, meaning every single task opens a brand new SSH connection. With 20 hosts × 7 tasks = 140 connections without reuse. Enable `ControlMaster=auto` and `ControlPersist=60s`, and reduce forks to a reasonable number (5-10) to prevent connection pool exhaustion.
</details>

## Useful Commands

```bash
# Run and observe the race condition
ansible-playbook playbook.yml -v

# Run multiple times to see non-deterministic behavior
for i in {1..5}; do
  rm -f /tmp/ansible-lab13/shared/node_count
  echo 0 > /tmp/ansible-lab13/shared/node_count
  ansible-playbook playbook.yml 2>&1 | tail -5
  echo "Run $i: node_count=$(cat /tmp/ansible-lab13/shared/node_count)"
done

# Check what serial does with strategy:free
ansible-playbook playbook.yml -vvv 2>&1 | grep -i "serial\|strategy\|throttle"

# Monitor shared file writes in real-time
watch -n 0.1 'wc -l /tmp/ansible-lab13/shared/cluster-config.yml; cat /tmp/ansible-lab13/shared/node_count'

# Check for SSH connection issues
ansible-playbook playbook.yml -vvvv 2>&1 | grep -i "ssh\|connection\|timeout\|refused"

# Test with different fork counts
ansible-playbook playbook.yml -f 1 -v   # serial - should work
ansible-playbook playbook.yml -f 20 -v  # parallel - race condition

# Verify strategy behavior
ansible-config dump | grep -i strategy

# Check if throttle keyword is supported
ansible-doc -t keyword throttle 2>&1 || ansible-doc lineinfile | grep -i throttle

# Inspect the corrupted shared files
cat /tmp/ansible-lab13/shared/cluster-config.yml
cat /tmp/ansible-lab13/shared/node_count
cat /tmp/ansible-lab13/shared/cert-requests.txt | sort | uniq -c | sort -rn

# Simulate the race condition in shell
for i in $(seq 1 20); do
  (current=$(cat /tmp/test_race 2>/dev/null || echo 0); echo $((current+1)) > /tmp/test_race) &
done; wait; cat /tmp/test_race
```

## What You Need to Fix

1. **strategy:free + serial incompatibility** — Either use linear strategy or remove serial and use throttle
2. **No throttle on shared resource tasks** — Tasks writing to shared files need `throttle: 1`
3. **SSH configuration** — Enable SSH multiplexing, reduce forks to reasonable number
4. **Shell race condition** — read-modify-write without atomic operation or locking
5. **run_once behavior** — Understand and fix run_once with strategy:free

## Success Criteria

- [ ] All 20 nodes are registered in cluster-config.yml
- [ ] Node count accurately shows 20 after playbook completion
- [ ] Certificate requests file has exactly 20 non-corrupted entries
- [ ] Playbook produces consistent results across multiple runs
- [ ] No SSH connection errors or timeouts
- [ ] Shared resource access is properly serialized
