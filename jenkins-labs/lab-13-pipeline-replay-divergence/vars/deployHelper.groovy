// vars/deployHelper.groovy
// Shared Library function for Lab 13 - Pipeline Replay Divergence
//
// BUG: This library is loaded at SCM trigger time and cached.
// On replay, the CACHED version is used — not the latest from SCM.
// If someone pushed a fix to this library between the original run and the replay,
// the replay will still use the OLD (broken) version.
//
// Version: 2.1.0 (but 2.2.0 is in SCM — replay won't pick it up)

def runTests(String environment) {
    echo "Running integration tests for environment: ${environment}"
    
    // BUG: In library version 2.1.0 (cached), this uses the old test runner
    // In version 2.2.0 (latest in SCM), this was changed to use a new test framework
    // Replay uses 2.1.0, SCM-triggered uses 2.2.0
    
    def testCommand = "mvn verify -P integration-tests"
    
    // BUG: env.BRANCH_NAME is null on replay, causing this condition to always be false
    if (env.BRANCH_NAME == 'main') {
        testCommand += " -P smoke-tests"
        echo "Main branch detected — adding smoke tests"
    } else if (env.BRANCH_NAME) {
        testCommand += " -P feature-tests"
        echo "Feature branch detected: ${env.BRANCH_NAME}"
    } else {
        // This branch is ALWAYS taken on replay
        echo "WARNING: No branch information available — running minimal tests"
        testCommand = "mvn test -P unit-only"
    }
    
    echo "Test command: ${testCommand}"
    // sh testCommand  // Would execute if this were real
    
    return true
}

def deploy(Map config) {
    def environment = config.env ?: 'staging'
    def imageTag = config.tag ?: 'latest'
    def branch = config.branch  // null on replay!
    
    echo "Deploying to ${environment} with tag ${imageTag}"
    
    // BUG: branch is null on replay, causing deployment target logic to fail
    if (!branch) {
        echo "ERROR: branch is null — cannot determine deployment target"
        echo "This is a known issue when replaying pipelines from Blue Ocean"
        echo "The SCM plugin doesn't inject BRANCH_NAME for replayed builds"
        
        // In version 2.2.0 this was fixed with a fallback:
        // branch = currentBuild.rawBuild.getAction(hudson.plugins.git.util.BuildData)?.lastBuiltRevision?.branches?.first()?.name
        // But the cached 2.1.0 doesn't have this fix
        error "Cannot deploy: branch information unavailable in replay context"
    }
    
    def targetCluster = branch == 'main' ? 'prod-cluster' : 'staging-cluster'
    echo "Target cluster: ${targetCluster}"
    
    // Simulate deployment
    echo """
    kubectl set image deployment/payment-service \\
        payment-service=registry.company.internal:5000/payment-service:${imageTag} \\
        --context=${targetCluster} \\
        -n payment
    """
    
    return true
}

def generateChangelog() {
    // BUG: currentBuild.changeSets is empty on replay
    // No SCM changes are associated with a replayed build
    def changeSets = currentBuild.changeSets
    
    if (changeSets.isEmpty()) {
        echo "No changeSets available — this build was replayed or manually triggered"
        return "No changes available"
    }
    
    def changelog = changeSets.collect { cs ->
        cs.items.collect { entry ->
            "- ${entry.commitId[0..6]}: ${entry.msg} (${entry.author})"
        }
    }.flatten().join('\n')
    
    return changelog
}
