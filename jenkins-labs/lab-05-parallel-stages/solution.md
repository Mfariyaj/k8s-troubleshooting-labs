## Solution: Parallel Stages

### Root Cause

All three parallel stages share the same workspace and write to the same file (`test-results.txt`). This causes race conditions where stages overwrite each other's output, resulting in corrupted or incomplete reports.

### Step-by-Step Fix

1. Use unique file names per parallel stage to avoid conflicts
2. Use `stash`/`unstash` with unique names to collect results in the Report stage
3. Alternatively, wrap each stage in `ws()` for isolated workspaces

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    stages {
        stage('Parallel Tests') {
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh 'echo "UNIT TEST RESULTS" > test-results-unit.txt'
                        sh 'sleep 2'
                        sh 'echo "unit: PASS" >> test-results-unit.txt'
                        stash name: 'unit-results', includes: 'test-results-unit.txt'
                    }
                }
                stage('Integration Tests') {
                    steps {
                        sh 'echo "INTEGRATION TEST RESULTS" > test-results-integration.txt'
                        sh 'sleep 1'
                        sh 'echo "integration: PASS" >> test-results-integration.txt'
                        stash name: 'integration-results', includes: 'test-results-integration.txt'
                    }
                }
                stage('E2E Tests') {
                    steps {
                        sh 'echo "E2E TEST RESULTS" > test-results-e2e.txt'
                        sh 'sleep 3'
                        sh 'echo "e2e: PASS" >> test-results-e2e.txt'
                        stash name: 'e2e-results', includes: 'test-results-e2e.txt'
                    }
                }
            }
        }
        stage('Report') {
            steps {
                unstash 'unit-results'
                unstash 'integration-results'
                unstash 'e2e-results'
                sh 'echo "Final report:"; cat test-results-*.txt'
            }
        }
    }
}
```

### Verification

```bash
# Report stage should show ALL results from all 3 branches with no missing data
# Expected: unit PASS + integration PASS + e2e PASS all present
```
