# Lab 13: Pipeline Replay Divergence — Blue Ocean vs SCM

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

A critical production deployment pipeline works perfectly when triggered by SCM webhook (push to `main` branch). However, when a senior engineer uses "Replay" from Blue Ocean to re-run a successful build with a small Jenkinsfile edit, the pipeline fails midway with multiple unexpected errors. Parameters show stale values, environment variables are empty, stashed artifacts are missing, and the shared library function behaves differently.

This has caused an outage because the engineer replayed a "known good" build during an incident, expecting identical behavior, but got a broken deployment instead.

## What You'll Observe

SCM-triggered run (works fine):
```
[Pipeline] Start of Pipeline
[Pipeline] library
Loading library company-shared-library@2.2.0
  > git rev-parse --is-inside-work-tree
  > git fetch --tags origin +refs/heads/*:refs/remotes/origin/*
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/payment-service_main
[Pipeline] {
  Deploy Environment: production
  Image Tag: v3.2.1
  Branch Name: main
  Deploy Target: production
  Version: 142-main
  Main branch detected — adding smoke tests
  Test command: mvn verify -P integration-tests -P smoke-tests
  Deploying to production with tag v3.2.1
  Target cluster: prod-cluster
[Pipeline] }
Finished: SUCCESS
```

Replayed run (fails):
```
[Pipeline] Start of Pipeline
[Pipeline] library
Loading library company-shared-library@2.1.0  ← CACHED OLD VERSION!
  (using cached library, not re-resolving from SCM)
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/payment-service_main@2
[Pipeline] {
  Deploy Environment: production  ← STALE: from original run's params, not defaults!
  Image Tag: v3.2.1  ← STALE: same issue
  Branch Name: null  ← BUG: empty on replay
  Deploy Target: staging  ← WRONG: null branch causes wrong ternary evaluation
  Version: 143-unknown  ← WRONG: 'unknown' because BRANCH_NAME is null
  WARNING: No branch information available — running minimal tests
  Test command: mvn test -P unit-only  ← WRONG: should be full integration tests
  Failed to unstash: No stash 'build-artifacts' found  ← BUG: stash not from this run
  ERROR: branch is null — cannot determine deployment target
  ERROR: Cannot deploy: branch information unavailable in replay context
[Pipeline] }
Finished: FAILURE
```

## Your Task

Identify all 5 divergence bugs between SCM-triggered and replayed builds, then fix them:
1. Pin the shared library version so replays use the same version
2. Handle null BRANCH_NAME gracefully with fallback detection
3. Don't rely on stash/unstash across replay boundaries — rebuild if needed
4. Document parameter behavior on replay (values are inherited, not defaulted)
5. Fix the shared library to work without SCM context

## Hints

<details>
<summary>Hint 1</summary>
When you replay a build, Jenkins re-runs the pipeline Groovy code in a new context but WITHOUT the SCM trigger metadata. `env.BRANCH_NAME`, `env.GIT_BRANCH`, `env.CHANGE_ID` (for PRs), and `currentBuild.changeSets` are all empty or null. Use `scm` step or read from git directly: `sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()` as a fallback.
</details>

<details>
<summary>Hint 2</summary>
`@Library('name')` without a version resolves to the default branch/version at pipeline START time. For replays, this uses whatever is in the library cache. Pin it with `@Library('company-shared-library@2.2.0')` or use `library identifier: 'company-shared-library@main', retriever: modernSCM(...)` inside the pipeline to force re-resolution.
</details>

<details>
<summary>Hint 3</summary>
`stash` is bound to the specific BUILD RUN, not the pipeline definition. A replay creates a NEW build (new build number). Stashes from build #142 are NOT available in replay build #143. You must either: (a) always run the build stage, or (b) use `copyArtifacts` from the original build, or (c) use `archiveArtifacts` + `build` step to retrieve from prior runs.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Check shared library resolution in build logs
# Look for "Loading library" lines showing version
docker exec jenkins-replay-lab cat /var/jenkins_home/jobs/*/builds/*/log | grep -i "library\|loading"

# Compare SCM-triggered vs replay build logs side by side
diff <(docker exec jenkins-replay-lab cat /var/jenkins_home/jobs/payment-service/branches/main/builds/1/log) \
     <(docker exec jenkins-replay-lab cat /var/jenkins_home/jobs/payment-service/branches/main/builds/2/log)

# Check build parameters for a replay vs original
curl -s http://localhost:8080/job/payment-service/branches/main/1/api/json?tree=actions[parameters[*]]
curl -s http://localhost:8080/job/payment-service/branches/main/2/api/json?tree=actions[parameters[*]]

# View shared library cache
docker exec jenkins-replay-lab ls -la /var/jenkins_home/libs/company-shared-library/

# Check if build was a replay
curl -s http://localhost:8080/job/payment-service/branches/main/2/api/json | jq '.actions[] | select(._class | contains("Replay"))'

# View pipeline replay modifications
curl -s http://localhost:8080/job/payment-service/branches/main/2/replay/

# Inspect stash storage for a build
docker exec jenkins-replay-lab find /var/jenkins_home/jobs -name "stashes" -type d 2>/dev/null

# Check environment variables available in build
curl -s http://localhost:8080/job/payment-service/branches/main/1/injectedEnvVars/api/json

# View changeSets for builds
curl -s http://localhost:8080/job/payment-service/branches/main/1/api/json?tree=changeSets[items[commitId,msg,author[fullName]]]
curl -s http://localhost:8080/job/payment-service/branches/main/2/api/json?tree=changeSets[items[commitId,msg,author[fullName]]]

# Groovy console to inspect library versions
# Navigate to http://localhost:8080/script and run:
# println(Jenkins.instance.getExtensionList('org.jenkinsci.plugins.workflow.libs.GlobalLibraries'))
```

## Clean Up

```bash
./cleanup.sh
```
