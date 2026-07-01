## Solution: Pipeline Replay Divergence

### Root Cause

5 issues cause SCM-triggered builds to diverge from replayed builds:
1. `@Library` without version pin — replay may use cached old version
2. `env.BRANCH_NAME` is null on replay (no SCM trigger metadata)
3. `stash` from original build unavailable in replay (new build number)
4. Parameters inherit values from original run, not defaults
5. `currentBuild.changeSets` is empty on replay

### Step-by-Step Fix

1. Pin library version: `@Library('company-shared-library@2.2.0')`
2. Fallback for BRANCH_NAME: detect from git if null
3. Always run Build stage — don't rely on stash from prior runs
4. Validate params with null-safe operators
5. Handle empty changeSets gracefully

### Fixed Jenkinsfile

```groovy
@Library('company-shared-library@2.2.0') _

pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['staging', 'production', 'development'])
        string(name: 'IMAGE_TAG', defaultValue: 'latest')
        booleanParam(name: 'RUN_INTEGRATION_TESTS', defaultValue: true)
    }

    stages {
        stage('Detect Branch') {
            steps {
                script {
                    // Fixed: fallback to git command when BRANCH_NAME is null (replay)
                    env.EFFECTIVE_BRANCH = env.BRANCH_NAME ?:
                        sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    env.DEPLOY_TARGET = (env.EFFECTIVE_BRANCH == 'main') ? 'production' : 'staging'
                    env.VERSION = "${BUILD_NUMBER}-${env.EFFECTIVE_BRANCH}"
                }
            }
        }
        stage('Build & Stash') {
            steps {
                sh 'mkdir -p build && echo "artifact-v${BUILD_NUMBER}" > build/app.jar'
                stash name: 'build-artifacts', includes: 'build/**'
            }
        }
        stage('Deploy') {
            steps {
                script {
                    unstash 'build-artifacts'
                    deployHelper.deploy(
                        env: params.DEPLOY_ENV ?: 'staging',
                        tag: params.IMAGE_TAG ?: 'latest',
                        branch: env.EFFECTIVE_BRANCH
                    )
                }
            }
        }
        stage('Notify') {
            steps {
                script {
                    def changes = currentBuild.changeSets.collect { cs ->
                        cs.items.collect { "${it.commitId[0..6]}: ${it.msg}" }
                    }.flatten().join('\n') ?: 'No changes (replay or manual trigger)'
                    echo "Deployed ${env.VERSION}: ${changes}"
                }
            }
        }
    }
}
```

### Verification

```bash
# SCM-triggered: BRANCH_NAME populated, library pinned, works normally
# Replay: EFFECTIVE_BRANCH detected from git, stash created fresh, params null-safe
# Both paths produce consistent deployments
```
