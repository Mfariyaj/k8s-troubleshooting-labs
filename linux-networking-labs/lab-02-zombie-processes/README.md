# Lab 02: Zombie Processes

## Difficulty: 🟢 Easy

## Scenario

Your monitoring system is alerting on an increasing number of zombie processes. The system isn't running out of PIDs yet, but the count keeps growing. You need to identify what's creating the zombies and resolve the issue.

---

## What You'll See

### `ps aux | grep -w Z`
```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root     14201  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14203  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14205  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14207  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14209  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14211  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14213  0.0  0.0      0     0 pts/0    Z    10:23   0:00 [bash] <defunct>
root     14215  0.0  0.0      0     0 pts/0    Z    10:24   0:00 [bash] <defunct>
```

### `ps -eo ppid,pid,stat,cmd | grep -w Z`
```
  14200  14201 Z    [bash] <defunct>
  14200  14203 Z    [bash] <defunct>
  14200  14205 Z    [bash] <defunct>
  14200  14207 Z    [bash] <defunct>
```
*(All zombies share the same parent PID)*

### `ps -p <PPID> -o pid,cmd`
```
  PID CMD
14200 bash /path/to/zombie-creator.sh
```

---

## Hints

<details>
<summary>Hint 1</summary>
Zombie processes (`Z` state) can't be killed directly with `kill` — they're already dead. The issue is their parent not calling `wait()` to reap them.
</details>

<details>
<summary>Hint 2</summary>
Find the parent process using `ps -eo ppid,pid,stat | grep Z` — all zombies will share a common PPID.
</details>

<details>
<summary>Hint 3</summary>
Killing the parent process will cause zombies to be adopted by PID 1 (init/systemd), which will automatically reap them.
</details>

---

## Fix Commands

```bash
# Find zombie processes and their parent
ps -eo ppid,pid,stat,cmd | grep -w Z

# Identify the parent PID (PPID column)
ps -p <PPID> -o pid,ppid,cmd

# Option A: Kill the parent (zombies get reparented to init and reaped)
kill <PPID>

# Option B: Send SIGCHLD to parent to remind it to reap
kill -SIGCHLD <PPID>

# Verify zombies are gone
ps aux | grep -w Z | grep -v grep
```

---

## Cleanup

```bash
sudo bash cleanup.sh
```
