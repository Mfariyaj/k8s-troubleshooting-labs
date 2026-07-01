## Solution: Shared Library

### Root Cause

1. `@Library('wrong-name')` references a library that doesn't match the configured name `my-shared-lib`
2. Without a pinned branch, the library may resolve to an unexpected version
3. The library method `deploy()` expects two arguments (`serviceName, environment`) — callers must match

### Step-by-Step Fix

1. Change `@Library('wrong-name')` to `@Library('my-shared-lib')`
2. Pin the branch: `@Library('my-shared-lib@main')` for reproducibility
3. Verify method signatures in `vars/buildHelper.groovy` match pipeline calls

### Fixed Jenkinsfile

```groovy
@Library('my-shared-lib@main') _

pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                script {
                    buildHelper.buildApp('my-service')
                }
            }
        }
        stage('Test') {
            steps {
                script {
                    buildHelper.runTests('my-service')
                }
            }
        }
        stage('Deploy') {
            steps {
                script {
                    buildHelper.deploy('my-service', 'production')
                }
            }
        }
    }
}
```

### Verification

```bash
# Check configured libraries: Manage Jenkins > Configure System > Global Pipeline Libraries
# Pipeline log should show: "Loading library my-shared-lib@main"
# All stages complete without "Library not found" or method signature errors
```
