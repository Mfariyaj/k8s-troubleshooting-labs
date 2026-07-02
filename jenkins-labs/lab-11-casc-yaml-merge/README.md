## 🎯 How to Use This Lab

1. Start Jenkins: `./deploy.sh` (or use an already-running Jenkins instance)
2. Open **http://localhost:8080** → **New Item** → **Pipeline**
3. Paste the `Jenkinsfile` contents into "Pipeline script"
4. Click **Save** → **Build Now**
5. Click **Console Output** on the failed build to see the error
6. Diagnose and fix! Check `solution.md` if stuck.

---

# Lab 11: JCasC YAML Merge Failures After Plugin Upgrade

## Difficulty: ⭐⭐⭐⭐⭐ Expert

## Scenario

Your team recently upgraded Jenkins from 2.375 to 2.426 along with several plugins. The Jenkins Configuration as Code (JCasC) setup uses multiple YAML files with YAML anchors and merge keys for DRY configuration. After the upgrade, Jenkins fails to start — the CasC plugin throws errors about undefined anchors, unrecognized fields, and invalid credential types. The configuration worked perfectly before the upgrade.

The JCasC configuration spans 3 files:
- `casc/jenkins.yaml` — Main Jenkins config with YAML anchors for reuse
- `casc/credentials.yaml` — Credential definitions referencing anchors from jenkins.yaml
- `casc/security.yaml` — Security realm and authorization config

## What You'll Observe

Jenkins container starts but the CasC plugin fails to apply configuration:

```
2026-07-01 10:15:33.421+0000 [id=28] SEVERE io.jenkins.plugins.casc.ConfigurationAsCode#configure:
io.jenkins.plugins.casc.ConfigurationAsCodeException: Error configuring instance from [/var/jenkins_home/casc_configs/]

Caused by: io.jenkins.plugins.casc.ConfigurationAsCodeException: 
  Invalid configuration elements for type class jenkins.model.Jenkins : securityRealm

2026-07-01 10:15:33.425+0000 [id=28] WARNING io.jenkins.plugins.casc.yaml.YamlUtils#merge:
  Found undefined anchor 'default-java-tool' at line 42, column 8

2026-07-01 10:15:33.430+0000 [id=28] SEVERE io.jenkins.plugins.casc.ConfigurationAsCode#configure:
  org.yaml.snakeyaml.composer.ComposerException: found undefined alias *ldap-server-config
   in 'reader', line 15, column 5:
        <<: *ldap-server-config

2026-07-01 10:15:33.435+0000 [id=28] WARNING io.jenkins.plugins.casc.ConfigurationAsCode#configure:
  io.jenkins.plugins.casc.ConfigurationAsCodeException: No configurator for type: 
  com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentials
  Expected: com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl

2026-07-01 10:15:33.440+0000 [id=28] INFO jenkins.InitReactorRunner$1#onTaskFailed:
  Configuration as Code failed. Jenkins starting with default configuration.
```

## Your Task

Diagnose and fix ALL JCasC issues so Jenkins starts with the full configuration applied:
1. Fix broken YAML anchors that reference across files (cross-file anchors don't work)
2. Correct the schema changes from plugin upgrades (field renames)
3. Fix credential type names that changed after plugin update
4. Resolve YAML merge key (`<<:`) issues where anchors are undefined

## Hints

<details>
<summary>Hint 1</summary>
YAML anchors are file-scoped — they cannot be referenced across separate YAML files. JCasC merges files at the Jenkins config level, not at the YAML parser level. Anchors defined in jenkins.yaml cannot be used in credentials.yaml.
</details>

<details>
<summary>Hint 2</summary>
After Jenkins 2.401+, `securityRealm` was moved under `jenkins.securityRealm` (top-level), while `authorizationStrategy` remains under `jenkins.authorizationStrategy`. The old format that put both under a `security` block was deprecated. Check the JCasC schema documentation for your version.
</details>

<details>
<summary>Hint 3</summary>
The credentials plugin renamed the class from `UsernamePasswordCredentials` to `UsernamePasswordCredentialsImpl` in version 1337.v60b_d7b_c7b_c9f+. Also, the `string` credential type became `secretText` in the JCasC schema. Use `http://jenkins:8080/configuration-as-code/schema` to see valid types.
</details>

## Useful Commands

```bash
# Deploy the lab
./deploy.sh

# Check Jenkins container logs for CasC errors
docker logs jenkins-casc-lab 2>&1 | grep -i "casc\|error\|severe\|warning"

# Validate JCasC YAML syntax locally
docker exec jenkins-casc-lab cat /var/jenkins_home/casc_configs/jenkins.yaml
python3 -c "import yaml; yaml.safe_load(open('casc/jenkins.yaml'))"

# Check JCasC schema for current plugin versions
curl -s http://localhost:8080/configuration-as-code/schema

# Export current (default) configuration for comparison
curl -s http://localhost:8080/configuration-as-code/export

# Check which plugins are installed and their versions
docker exec jenkins-casc-lab cat /var/jenkins_home/plugins/*.jpi.version 2>/dev/null
docker exec jenkins-casc-lab jenkins-plugin-cli --list

# Reload JCasC after fixing
curl -X POST http://localhost:8080/configuration-as-code/reload

# Verify YAML anchors with Python
python3 -c "import yaml; print(yaml.safe_load(open('casc/jenkins.yaml')))"

# Check Jenkins init logs
docker exec jenkins-casc-lab cat /var/jenkins_home/logs/casc.log

# Test merged YAML output
docker exec jenkins-casc-lab cat /var/jenkins_home/casc_configs/*.yaml | python3 -c "import sys,yaml; [yaml.safe_load(d) for d in yaml.safe_load_all(sys.stdin)]"

# Inspect plugin manifest for class renames
docker exec jenkins-casc-lab find /var/jenkins_home/plugins -name "MANIFEST.MF" | head -5
```

## Clean Up

```bash
./cleanup.sh
```
