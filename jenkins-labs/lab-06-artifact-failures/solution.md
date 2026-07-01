## Solution: Artifact Failures

### Root Cause

1. `archiveArtifacts` uses glob `dist/**/*.jar` but files are in `build/output/` — path mismatch
2. `stash` includes all of `build/output/**` which contains a 500MB binary, exceeding the ~100MB stash limit

### Step-by-Step Fix

1. Fix the `archiveArtifacts` glob to `build/output/**/*.jar` (match actual path)
2. Exclude large binary from stash: add `excludes: '**/*.bin'`
3. Use `archiveArtifacts` for the large file if needed (no size limit)
4. Ensure the build directory exists before archiving

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh '''
                    mkdir -p build/output
                    echo "compiled binary" > build/output/app.jar
                    echo "build metadata" > build/output/build-info.json
                    dd if=/dev/urandom of=build/output/large-asset.bin bs=1M count=500
                '''
            }
        }
        stage('Archive') {
            steps {
                // Fixed: correct glob matching actual build output path
                archiveArtifacts artifacts: 'build/output/**/*.jar', fingerprint: true
                // Fixed: exclude large binary from stash
                stash includes: 'build/output/**', excludes: '**/*.bin', name: 'build-artifacts'
            }
        }
        stage('Deploy') {
            steps {
                unstash 'build-artifacts'
                sh 'echo "Deploying app.jar..."; ls build/output/app.jar'
            }
        }
    }
}
```

### Verification

```bash
# Pipeline completes without "No artifacts found" or stash size errors
# Archived artifacts visible at http://localhost:8080/job/<name>/lastBuild/artifact/
# Deploy stage unstash succeeds with app.jar present
```
