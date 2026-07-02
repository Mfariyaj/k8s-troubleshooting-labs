## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 14: Managed Pipeline Delivery — Not Converging

## Difficulty: 🟣 Expert

---

## 📚 What You'll Learn

**Managed Delivery** (also called Declarative Delivery) is Spinnaker's GitOps-style approach. Instead of defining imperative pipelines ("do A, then B, then C"), you declare desired state and Spinnaker continuously converges.

Key concepts:
- **Delivery Config**: YAML file declaring environments and resources
- **Environments**: Ordered deployment stages (test → staging → production)
- **Constraints**: Rules that must pass before promotion (time-window, manual-judgement, pipeline-success)
- **Resources**: What to deploy (titus/cluster, ec2/cluster, k8s/resource)
- **Artifacts**: The versioned thing being deployed through environments
- **Verification**: Post-deployment checks (automated or manual)

Delivery config structure:
```yaml
name: myapp
serviceAccount: spinnaker-managed-delivery
artifacts:
  - name: myapp-docker
    type: docker
    reference: myorg/myapp
environments:
  - name: testing
    resources:
      - kind: k8s/resource@v1
        spec:
          template:
            apiVersion: apps/v1
            kind: Deployment
            ...
  - name: production
    constraints:
      - type: depends-on
        environment: testing
      - type: allowed-times
        windows:
          - days: Mon-Fri
            hours: 9-17
    resources: [...]
```

Common issues:
- YAML indentation errors in delivery config
- Constraint type misspelled or wrong format
- Resource `kind` not supported or wrong version
- `serviceAccount` missing EXECUTE permission
- Artifact reference doesn't match any trigger source

---

## 🔧 Scenario

Managed Delivery is configured but resources never converge to desired state:

1. The delivery config has incorrect YAML indentation (constraints under wrong key)
2. A `depends-on` constraint references environment `test` but the environment is named `testing`
3. The `allowed-times` constraint window format is wrong (`hours: 9-17` instead of `hours: "9-17"` as string, and `days` needs to be a list)

---

## 💥 Expected Error Output

```
$ curl http://gate:8084/managed/application/myapp/config
{
  "status": "ERROR",
  "message": "Delivery config validation failed",
  "errors": [
    "Line 28: Expected mapping under 'constraints', got sequence",
    "Environment 'production' depends on 'test' which does not exist. 
     Available environments: [testing, production]",
    "Constraint 'allowed-times' at production: 'days' must be a list. 
     'hours' must be a quoted string in format 'HH-HH'"
  ]
}

Keel logs:
  ERROR c.n.s.keel.constraints.DependsOnConstraintHandler -
    Cannot evaluate depends-on constraint: environment 'test' not found
    
  WARN c.n.s.keel.constraints.AllowedTimesConstraintHandler -
    Invalid time window format: hours=9-17 (expected quoted string)
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
YAML is sensitive to indentation. Check that `constraints` is at the correct level — it should be a direct child of the environment, not nested under `resources`.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
The `depends-on` constraint requires an `environment` field that exactly matches another environment's `name`. If you named it `testing`, the constraint must reference `testing` (not `test`).
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Fixes: 1) Fix YAML indentation so `constraints` is at the same level as `resources` under the environment, 2) Change `depends-on` environment from `test` to `testing`, 3) Fix `allowed-times` format: `days` should be a list `["Mon-Fri"]` and `hours` should be a string `"9-17"`.
</details>

---

## 🛠️ Useful Commands

```bash
# Submit delivery config
curl -X POST http://gate:8084/managed/delivery-configs \
  -H "Content-Type: application/yaml" \
  --data-binary @delivery-config.yml

# Check managed resource status
curl http://gate:8084/managed/resources/myapp/status | jq .

# View delivery config validation
curl http://gate:8084/managed/application/myapp/config | jq .

# Check Keel (managed delivery engine) logs
kubectl logs -n spinnaker spin-keel-xxx | grep -i "error\|constraint"

# List managed environments
curl http://gate:8084/managed/application/myapp/environment | jq '.[].name'

# Diff desired vs actual
curl http://gate:8084/managed/resources/<resource-id>/diff | jq .
```

---

## 📖 References

- https://spinnaker.io/docs/guides/user/managed-delivery/
- https://spinnaker.io/docs/guides/user/managed-delivery/delivery-configs/
- https://spinnaker.io/docs/reference/managed-delivery/constraints/
- https://spinnaker.io/docs/guides/user/managed-delivery/getting-started/

---

## 🏁 Success Criteria

- Delivery config passes validation
- Resources in `testing` environment converge
- Constraints evaluate correctly for `production`
- Resource diff shows "in-sync" status
