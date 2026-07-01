## Solution: Workspace Disk Full

### Root Cause

The pipeline generates ~850MB of temporary files per build but never cleans the workspace. After a few builds, disk fills up and builds fail with "No space left on device."

### Step-by-Step Fix

1. Add `post { always { cleanWs() } }` to clean workspace after every build
2. Add `deleteDir()` as a fallback cleanup
3. Add `options { disableConcurrentBuilds() }` to prevent parallel accumulation
4. Limit artifact retention with `buildDiscarder`

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '5', artifactNumToKeepStr: '2'))
    }

    stages {
        stage('Generate Data') {
            steps {
                sh '''
                    echo "Downloading dependencies..."
                    dd if=/dev/zero of=vendor-cache.tar bs=1M count=200
                    echo "Building assets..."
                    dd if=/dev/zero of=compiled-assets.tar bs=1M count=150
                    echo "Creating debug artifacts..."
                    for i in $(seq 1 50); do
                        dd if=/dev/zero of=debug-dump-${i}.log bs=1M count=10
                    done
                '''
            }
        }
        stage('Build') {
            steps {
                sh 'echo "Building application..."'
            }
        }
        stage('Test') {
            steps {
                sh 'echo "Running tests..."'
            }
        }
        stage('Deploy') {
            steps {
                sh 'echo "Deploying..."'
            }
        }
    }

    post {
        always {
            deleteDir()
            cleanWs()
        }
    }
}
```

### Verification

```bash
# After build, workspace should be empty:
du -sh /var/jenkins_home/workspace/my-job  # Should be 0 or not exist
# Multiple consecutive builds succeed without disk errors
# Old builds auto-pruned by buildDiscarder
```
