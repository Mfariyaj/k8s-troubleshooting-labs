## Solution: Pipeline Syntax Errors

### Root Cause

The Jenkinsfile has three syntax violations:
1. A `stages` block placed **outside** the `pipeline {}` block
2. `def` keyword used directly inside a `steps` block (not allowed in declarative pipelines)
3. A `stage('Test')` placed outside a `stages` block, and missing closing braces

### Step-by-Step Fix

1. Remove the stray `stages {}` block above `pipeline {}`
2. Move all `stage()` blocks inside a single `stages {}` block within `pipeline {}`
3. Wrap the `def` variable assignment inside a `script {}` block
4. Ensure all braces are balanced

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building...'
            }
        }
        stage('Test') {
            steps {
                script {
                    def testResult = sh(script: 'echo "running tests"', returnStdout: true)
                    echo "Result: ${testResult}"
                }
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
            }
        }
    }
}
```

### Verification

```bash
# Validate syntax using Jenkins pipeline linter
curl -X POST -F "jenkinsfile=<Jenkinsfile" http://localhost:8080/pipeline-model-converter/validate

# Run the pipeline — all three stages should execute without compilation errors
```
