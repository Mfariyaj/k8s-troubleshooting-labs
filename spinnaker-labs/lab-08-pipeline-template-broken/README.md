## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 08: Pipeline Template Broken — MPT v2 Instantiation Fails

## Difficulty: 🔴 Advanced

---

## 📚 What You'll Learn

**Managed Pipeline Templates (MPT v2)** allow teams to create reusable pipeline definitions with configurable variables. This is Spinnaker's "pipeline-as-code" approach.

Architecture:
- **Template**: A parameterized pipeline definition (stored in Front50)
- **Instance**: A concrete pipeline that inherits from a template and provides variable values
- **Variables**: Typed parameters (string, int, list, object) that customize template behavior
- **Modules**: Reusable stage groups that can be referenced from templates

Template structure:
```json
{
  "schema": "v2",
  "id": "my-template",
  "variables": [
    {"name": "env", "type": "string", "defaultValue": "staging"}
  ],
  "pipeline": {
    "stages": [...]
  }
}
```

Instance structure:
```json
{
  "schema": "v2",
  "template": {
    "source": "spinnaker://my-template"
  },
  "variables": {
    "env": "production"
  }
}
```

Common failures:
- Template variable referenced but not defined in variables array
- Instance doesn't provide required variables (no defaultValue)
- Module source path is wrong
- Template schema version mismatch
- Jinja rendering errors in template expressions

---

## 🔧 Scenario

A team created a pipeline template for standardized deployments, but instantiation fails:

1. Template defines variable `targetCluster` but the stage uses `${templateVariables.cluster}` (wrong variable name)
2. Instance provides variable `replicas` as a string `"3"` but template expects an integer type
3. Template references a module `spinnaker://notifications-module` that doesn't exist in Front50

---

## 💥 Expected Error Output

```
Error saving pipeline: Pipeline template validation failed

Errors:
  - Variable 'cluster' is not defined in template 'deploy-standard-v2'.
    Available variables: [targetCluster, replicas, namespace, imageTag]
    
  - Type mismatch for variable 'replicas': expected 'int', got 'string'.
    Provided value: "3"
    
  - Module reference 'spinnaker://notifications-module' could not be resolved.
    Module not found in Front50 storage.
    
  - Template rendering failed at stage 'Deploy': 
    UndefinedError: 'templateVariables.cluster' is undefined
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Compare the variable names defined in the template's `variables` array with what's used in stage definitions. The expression must use the exact variable name defined in the array.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Pipeline template variables are typed. If the template defines `"type": "int"`, the instance must provide a number (3), not a string ("3"). Check the instance's variable values.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Change `${templateVariables.cluster}` to `${templateVariables.targetCluster}` in the template stages, 2) Change instance variable `"replicas": "3"` to `"replicas": 3` (remove quotes), 3) Either create the notifications module or remove/inline the module reference.
</details>

---

## 🛠️ Useful Commands

```bash
# List pipeline templates
spin pipeline-template list

# Get template details
spin pipeline-template get --id deploy-standard-v2

# Validate a template
spin pipeline-template plan --file pipeline-instance.json

# Save/update a template
spin pipeline-template save --file pipeline-template.json

# Check Front50 for stored templates
kubectl exec -n spinnaker spin-front50-xxx -- \
  curl -s localhost:8080/pipelineTemplates | jq '.[].id'

# View Orca template rendering logs
kubectl logs -n spinnaker spin-orca-xxx | grep -i "template\|variable"
```

---

## 📖 References

- https://spinnaker.io/docs/reference/pipeline/templates/
- https://spinnaker.io/docs/guides/user/pipeline/pipeline-templates/create/
- https://spinnaker.io/docs/guides/user/pipeline/pipeline-templates/instantiate/
- https://spinnaker.io/docs/reference/pipeline/templates/override/

---

## 🏁 Success Criteria

- Pipeline template saves without validation errors
- Instance can be created from the template
- All variables resolve correctly
- Pipeline executes with template-defined stages
