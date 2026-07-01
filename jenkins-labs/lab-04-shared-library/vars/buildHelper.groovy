// Shared library helper for building and deploying applications

def buildApp(String serviceName) {
    echo "Building ${serviceName}..."
    sh "echo 'Compiling ${serviceName}'"
}

def runTests(String serviceName) {
    echo "Testing ${serviceName}..."
    sh "echo 'Running unit tests for ${serviceName}'"
}

def deploy(String serviceName, String environment) {
    echo "Deploying ${serviceName} to ${environment}..."
    sh "echo 'Deployed ${serviceName} to ${environment} successfully'"
}
