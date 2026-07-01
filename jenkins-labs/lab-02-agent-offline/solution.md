## Solution: Agent Offline

### Root Cause

The pipeline specifies `agent { label 'nonexistent-node' }` but no Jenkins node has this label. The build queues indefinitely waiting for a matching executor. Additionally, if using JNLP agents, port 50000 must be exposed and the agent must connect to the correct master URL.

### Step-by-Step Fix

1. Change the agent label to `any` (uses built-in node) or a valid existing label
2. If using a dedicated agent, create a node with the matching label in Manage Jenkins > Nodes
3. Ensure port 50000 is exposed for JNLP agent connections
4. Configure the agent with the correct Jenkins master URL

### Fixed Jenkinsfile

```groovy
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building application...'
                sh 'mvn clean package'
            }
        }
        stage('Test') {
            steps {
                echo 'Running tests...'
                sh 'mvn test'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying...'
                sh './deploy.sh'
            }
        }
    }
}
```

### Fixed docker-compose.yml (with JNLP agent)

```yaml
version: '3.8'
services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins-lab-02
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_lab02_data:/var/jenkins_home
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
  agent:
    image: jenkins/inbound-agent:latest
    environment:
      - JENKINS_URL=http://jenkins:8080
      - JENKINS_AGENT_NAME=build-agent
      - JENKINS_SECRET=<agent-secret>
    depends_on:
      - jenkins
volumes:
  jenkins_lab02_data:
```

### Verification

```bash
# Pipeline should start immediately instead of waiting in queue
curl -s http://localhost:8080/computer/api/json | jq '.computer[].displayName'
# Build log should show "Running on Jenkins" or the named agent
```
