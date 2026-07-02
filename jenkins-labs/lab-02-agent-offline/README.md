## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 02: Agent Offline

## Difficulty: ⭐ Easy

## Scenario

A pipeline is stuck in the queue and never executes. The build shows "pending" indefinitely with no available executor.

## Console Error Output

```
Started by user admin
Running in Durability level: MAX_SURVIVABILITY
Waiting for next available executor on 'nonexistent-node'
Jenkins doesn't have label 'nonexistent-node'
```

## Hints

1. Check `Manage Jenkins → Nodes` — is there an agent with the label `nonexistent-node`?
2. The `agent` directive specifies where the pipeline runs
3. Options: change label to `any`, add the label to an existing node, or create a new agent

## What to Fix

- Change `agent { label 'nonexistent-node' }` to `agent any` or a valid label
- Alternatively, configure a node with the matching label
