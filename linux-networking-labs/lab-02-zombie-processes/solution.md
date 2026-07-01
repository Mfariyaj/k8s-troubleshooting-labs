# Solution: Lab 02 - Zombie Processes

## Problem

Multiple zombie (defunct) processes accumulate on the system, consuming PID slots
and indicating a poorly behaving parent process.

## Diagnosis

```bash
# Count zombie processes
ps aux | grep -c 'Z'

# List zombie processes with their parent PIDs
ps -eo pid,ppid,stat,cmd | grep '^.*Z'

# Identify the parent process creating zombies
ps -eo pid,ppid,stat,cmd | awk '$3 ~ /Z/ {print $2}' | sort | uniq -c | sort -rn

# Check what the parent process is
ps -p <PPID> -o pid,cmd
```

## Root Cause

The parent process spawns child processes but never calls `wait()` or `waitpid()` to
collect their exit status. When children terminate, they become zombies — their process
table entries remain until the parent reaps them.

## Fix

### Option 1: Kill the parent process (zombies get reparented to init and reaped)

```bash
# Find the parent PID
PPID=$(ps -eo pid,ppid,stat | awk '$3 ~ /Z/ {print $2}' | sort -u | head -1)

# Kill the parent — init (PID 1) will adopt and reap the zombies
sudo kill $PPID

# If it doesn't respond to SIGTERM
sudo kill -9 $PPID
```

### Option 2: Fix the parent program to call wait()

```bash
# For shell scripts — add:
wait

# For C programs — add a SIGCHLD handler:
# signal(SIGCHLD, SIG_IGN);   /* auto-reap children */
# Or implement a handler that calls waitpid(-1, NULL, WNOHANG)
```

### Option 3: Send SIGCHLD to the parent to trigger reaping

```bash
sudo kill -SIGCHLD <PPID>
```

## Verification

```bash
# Confirm zombies are gone
ps aux | grep -c 'Z'

# Should show 0 zombie processes
ps -eo stat | grep -c Z
```

## Prevention

- Always call `wait()` in parent processes after forking
- Use `signal(SIGCHLD, SIG_IGN)` if you don't need child exit status
- Use process supervisors (systemd, supervisord) that handle reaping properly
- Monitor zombie count with alerting (e.g., node_exporter metric)
