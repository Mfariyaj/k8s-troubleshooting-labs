## Solution: Matrix Build

### Root Cause

1. Axis values contain spaces (`'linux amd64'`) — causes parsing issues
2. `value '8'` (singular) used instead of `values '8'` (plural) in exclude block
3. `notValues` is not a valid directive — no negation syntax exists in Jenkins matrix

### Step-by-Step Fix

1. Split the PLATFORM axis into separate OS and ARCH axes (no spaces)
2. Change `value` to `values` in all exclude blocks
3. Remove `notValues` and restructure as explicit exclude combinations
4. Add `when` conditions if more complex filtering is needed

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    stages {
        stage('Matrix Build') {
            matrix {
                axes {
                    axis {
                        name 'OS'
                        values 'linux', 'windows', 'darwin'
                    }
                    axis {
                        name 'ARCH'
                        values 'amd64', 'arm64'
                    }
                    axis {
                        name 'JAVA_VERSION'
                        values '8', '11', '17', '21'
                    }
                }
                excludes {
                    exclude {
                        axis {
                            name 'OS'
                            values 'darwin'
                        }
                        axis {
                            name 'ARCH'
                            values 'arm64'
                        }
                        axis {
                            name 'JAVA_VERSION'
                            values '8'
                        }
                    }
                    exclude {
                        axis {
                            name 'OS'
                            values 'windows'
                        }
                        axis {
                            name 'ARCH'
                            values 'arm64'
                        }
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            sh "echo Building on ${OS}-${ARCH} with Java ${JAVA_VERSION}"
                        }
                    }
                    stage('Test') {
                        steps {
                            sh "echo Testing on ${OS}-${ARCH} with Java ${JAVA_VERSION}"
                        }
                    }
                }
            }
        }
    }
}
```

### Verification

```bash
# Pipeline compiles without syntax errors
# Matrix produces valid combinations: linux-amd64-11, darwin-amd64-17, etc.
# Excluded combos (darwin-arm64-8, windows-arm64-*) do NOT appear
```
