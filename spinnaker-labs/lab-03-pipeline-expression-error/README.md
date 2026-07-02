## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 03: Pipeline Expression Error — SpEL Evaluation Failure

## Difficulty: 🟡 Intermediate

---

## 📚 What You'll Learn

Spinnaker uses **Spring Expression Language (SpEL)** for dynamic pipeline configuration. Expressions are enclosed in `${ }` and can reference:

- **Trigger data**: `${trigger.type}`, `${trigger.parameters.env}`
- **Stage outputs**: `${#stage('Deploy').outputs.manifestName}`
- **Execution context**: `${execution.id}`, `${execution.application}`
- **Helper functions**: `${#toJson()}`, `${#fromUrl()}`, `${#stage()}`, `${#judgment()}`
- **Conditional logic**: `${parameters.env == 'prod' ? 'us-east-1' : 'us-west-2'}`

Common SpEL pitfalls:
- Using `#stage('name')` without the `#` prefix (just `stage()` fails)
- Referencing undefined variables (no null-safe operator)
- Type mismatches (comparing string to integer)
- Missing quotes around string literals in expressions
- Using wrong property paths (`.output` vs `.outputs`)

SpEL expressions are evaluated by **Orca** (the orchestration engine) at stage execution time. If evaluation fails, the stage immediately fails with an "Expression evaluation failed" error.

---

## 🔧 Scenario

A pipeline that deploys to different environments based on parameters is failing. The pipeline uses SpEL expressions for:
- Determining the target namespace from trigger parameters
- Extracting the Docker image tag from a previous stage
- Conditional notification message

All three expressions have bugs causing the pipeline to fail immediately at the first stage.

---

## 💥 Expected Error Output

In the Spinnaker UI (Pipeline Execution Details):
```
Exception: Expression evaluation failed
Stage: Determine Environment
Error: 
  - Failed to evaluate expression: ${trigger.parameter.environment}
    EL1008E: Property or field 'parameter' cannot be found on object of
    type 'java.util.HashMap' - maybe not public or not valid?
    
  - Failed to evaluate expression: ${#stage(Build Docker).outputs.image}
    org.springframework.expression.spel.SpelParseException: 
    Expression [#stage(Build Docker).outputs.image] @7: EL1043E: 
    Unexpected token. Expected 'rparen())' but was 'identifier(Docker)'
    
  - Failed to evaluate expression: ${deployResult.status = 'SUCCEEDED'}
    EL1012E: Assignment operator '=' used, but did you mean '=='?
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Look carefully at the property paths. Is it `trigger.parameter` or `trigger.parameters` (plural)? SpEL is case-sensitive and plural-sensitive.
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
The `#stage()` function requires its argument to be a quoted string. `#stage(Build Docker)` needs quotes: `#stage('Build Docker')`. Without quotes, SpEL tries to parse `Build Docker` as two separate tokens.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) `trigger.parameter.environment` → `trigger.parameters.environment` (add 's'), 2) `#stage(Build Docker)` → `#stage('Build Docker')` (add quotes), 3) `status = 'SUCCEEDED'` → `status == 'SUCCEEDED'` (use comparison, not assignment).
</details>

---

## 🛠️ Useful Commands

```bash
# Get the pipeline JSON to inspect expressions
spin pipeline get --name "Deploy Service" --application myapp | jq .

# Check Orca logs for expression errors
kubectl logs -n spinnaker spin-orca-xxx | grep -i "expression"

# Test expressions via Gate API (useful for debugging)
curl -X POST http://localhost:8084/pipelines/evaluate \
  -H "Content-Type: application/json" \
  -d '{"expression": "${trigger.parameters.environment}"}'

# List pipeline executions
spin pipeline execution list --application myapp --pipeline-name "Deploy Service"

# Get execution details
spin pipeline execution get --id <execution-id>
```

---

## 📖 References

- https://spinnaker.io/docs/reference/pipeline/expressions/
- https://spinnaker.io/docs/guides/user/pipeline/expressions/
- https://spinnaker.io/docs/reference/pipeline/expressions/functions/
- https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#expressions

---

## 🏁 Success Criteria

- Pipeline executes past the expression evaluation stage
- All SpEL expressions resolve correctly
- The correct namespace is selected based on trigger parameters
- No "Expression evaluation failed" errors in Orca logs
