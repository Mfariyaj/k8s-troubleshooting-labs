## Solution: Pipeline Memory Leak (CPS Serialization)

### Root Cause

5 memory leak patterns compound until OOM:
1. Large `fileList` captured in CPS-serialized closure — serialized at every step
2. Missing `@NonCPS` on data-processing methods (split/collect/join in CPS context)
3. `readFile()` in a loop accumulates Strings that survive GC due to CPS references
4. GString interpolation (`"${content}"`) creates massive String copies in CPS
5. `StringBuilder` grows unbounded, serialized at every CPS checkpoint

### Step-by-Step Fix

1. Add `@NonCPS` to all data-processing helper methods
2. Use shell commands for file processing instead of `readFile()` in loops
3. Null out references after use; avoid holding large data across step boundaries
4. Write intermediate results to files instead of accumulating in memory
5. Process files one at a time, never in bulk collections

### Fixed Jenkinsfile (key patterns)

```groovy
@NonCPS
def processFileData(String content, String fileName) {
    def lines = content.split('\n')
    return "File: ${fileName}, Lines: ${lines.length}, Chars: ${content.length()}"
}

pipeline {
    agent any

    stages {
        stage('Initialize') {
            steps {
                sh 'mkdir -p reports test-data'
                sh 'for i in $(seq 1 500); do dd if=/dev/urandom bs=1024 count=10 2>/dev/null | base64 > test-data/file_$i.txt; done'
            }
        }
        stage('Process Files') {
            steps {
                script {
                    // Fixed: use shell to process, only capture small summary
                    sh 'for f in test-data/*.txt; do wc -l "$f"; done > reports/line-counts.txt'
                    echo "Processing complete"
                }
            }
        }
        stage('Analyze') {
            steps {
                script {
                    // Fixed: shell-based analysis, no readFile() loop
                    sh 'for i in $(seq 1 50); do wc -lc test-data/file_$i.txt >> reports/analysis.txt; done'
                }
            }
        }
        stage('Aggregate') {
            steps {
                // Fixed: shell aggregation instead of Groovy StringBuilder
                sh '''
                    cat test-data/*.txt | wc -l > reports/master-report.txt
                    echo "Total files: $(ls test-data/*.txt | wc -l)" >> reports/master-report.txt
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'reports/**', allowEmptyArchive: true
            sh 'rm -rf test-data reports'
        }
    }
}
```

### Key Rules

- `@NonCPS` for any method doing split/collect/join on large data
- Never hold large strings in pipeline variables across step boundaries
- Use `sh` for file processing — avoid `readFile()` in loops
- Null out references explicitly: `content = null`

### Verification

```bash
docker stats jenkins-memory-lab --no-stream  # Memory stays stable
docker inspect jenkins-memory-lab --format='{{.State.OOMKilled}}'  # false
# Pipeline completes all stages without OOM kill
```
