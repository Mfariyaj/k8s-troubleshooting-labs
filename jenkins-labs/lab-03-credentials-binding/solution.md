## Solution: Credentials Binding

### Root Cause

1. Credential ID `aws-secret-key` doesn't exist — the actual configured ID is `aws-credentials`
2. `usernamePassword()` binding is used for a Secret Text credential (`docker-registry-token` is `StringCredentialsImpl`), causing a type mismatch
3. Secrets could leak in console output without `set +x`

### Step-by-Step Fix

1. Change `credentials('aws-secret-key')` to `credentials('aws-credentials')`
2. Replace `usernamePassword()` with `string()` binding for Secret Text credentials
3. Use `set +x` in shell steps to prevent credential values leaking in logs

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    environment {
        AWS_CREDS = credentials('aws-credentials')
    }

    stages {
        stage('Authenticate') {
            steps {
                withCredentials([string(
                    credentialsId: 'docker-registry-token',
                    variable: 'DOCKER_TOKEN'
                )]) {
                    sh '''
                        set +x
                        echo "Logging in to Docker registry..."
                        docker login -u deploy-bot -p "$DOCKER_TOKEN" registry.example.com
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    set +x
                    aws s3 cp app.tar.gz s3://my-bucket/ --region us-east-1
                '''
            }
        }
    }
}
```

### Verification

```bash
# Check credential IDs exist
curl -s http://localhost:8080/credentials/api/json | jq '.stores[].domains[].credentials[].id'
# Pipeline passes without "Could not find credentials" or type mismatch errors
# Console output does NOT show credential values in plain text
```
