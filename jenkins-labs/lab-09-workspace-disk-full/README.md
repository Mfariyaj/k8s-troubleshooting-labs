# Lab 09: Workspace Disk Full

## Difficulty: ⭐⭐ Medium

## Scenario

A pipeline builds successfully a few times, then starts failing with disk space errors. Each build generates large temporary files but never cleans up the workspace.

## Console Error Output

```
[Pipeline] sh
+ dd if=/dev/zero of=vendor-cache.tar bs=1M count=200
dd: error writing 'vendor-cache.tar': No space left on device
128+0 records in
127+0 records out

ERROR: script returned exit code 1

hudson.AbortException: No space left on device
    at org.jenkinsci.plugins.workflow.steps.durable_task.DurableTaskStep.execution(...)

Disk usage: /var/jenkins_home/workspace/my-job
  Build #1: 850MB
  Build #2: 850MB
  Build #3: 850MB
  Total: 2.55GB (limit: 2GB)
```

## Hints

1. Check workspace size with `du -sh /var/jenkins_home/workspace/*`
2. Add `post { always { cleanWs() } }` to clean up after every build
3. Or use `deleteDir()` in a post action
4. Consider `options { disableConcurrentBuilds() }` to prevent parallel accumulation
5. Reduce file sizes or don't persist them across stages if not needed

## What to Fix

- Add a `post { always { cleanWs() } }` block at the end of the pipeline
- Or add `deleteDir()` as the last step
- Optionally add `options { disableConcurrentBuilds() }` to prevent overlap
- Consider cleaning intermediate files between stages
