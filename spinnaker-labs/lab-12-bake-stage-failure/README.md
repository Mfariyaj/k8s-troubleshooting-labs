## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 12: Bake Stage Failure — Rosco/Packer Broken

## Difficulty: 🔴 Advanced

---

## 📚 What You'll Learn

**Rosco** is Spinnaker's bakery service — it creates machine images (AMIs, GCE images) using **HashiCorp Packer**. "Baking" is the process of creating an immutable VM image with your application pre-installed.

How Bake works:
1. Pipeline triggers a Bake stage with package name and base OS
2. Rosco receives the request and generates a Packer template
3. Packer launches a temporary instance from a base AMI
4. Provisioners (shell scripts, Chef, Puppet) install your app
5. Packer creates a new AMI from the configured instance
6. AMI ID is output as an artifact for subsequent Deploy stages

Bake stage configuration:
- **Package**: The package to install (deb/rpm)
- **Base OS**: ubuntu-14.04, ubuntu-16.04, centos-7, etc.
- **Region**: AWS region for the AMI
- **Template**: Custom Packer template (optional)
- **Extended Attributes**: Extra variables passed to Packer

Common failures:
- Base AMI doesn't exist or isn't accessible in the specified region
- Packer template has syntax errors (JSON validation)
- AWS credentials for Rosco expired or missing
- Custom provisioner script not found
- Region mismatch between base AMI and target region
- Package repository unreachable during bake

---

## 🔧 Scenario

A bake stage fails to create an AMI:

1. The Packer template has invalid JSON (trailing comma in the provisioners array)
2. The base AMI `ami-0123456789INVALID` doesn't exist in `us-west-2`
3. Rosco's AWS region configuration says `us-east-1` but the template specifies `us-west-2`

---

## 💥 Expected Error Output

```
Bake Stage: TERMINAL (Failed)

Rosco logs:
  ERROR c.n.s.rosco.executor.BakeExecutor -
    Failed to execute bake for package 'myapp-1.2.3':
    
  Packer validation failed:
    Error parsing JSON template: invalid character '}' after array element
    at line 25, column 6 in /tmp/rosco-bake/packer-12345.json
    
  ERROR: SourceAmi 'ami-0123456789INVALID' does not exist in region 'us-west-2'
    
  ERROR: Configuration mismatch - Rosco configured for region 'us-east-1'
    but bake request specifies region 'us-west-2'. 
    AMI will not be accessible from the deployment region.
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
JSON doesn't allow trailing commas. Look at the provisioners array in the Packer template — is there a comma after the last element?
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
The `source_ami` in the Packer template must be a real AMI that exists in the target region. Use `aws ec2 describe-images` to find valid base AMIs.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
Three fixes: 1) Remove the trailing comma in the Packer template's provisioners array, 2) Replace the fake AMI ID with a real Ubuntu AMI for us-west-2, 3) Align rosco-local.yml region with the Packer template region (both should be us-west-2 or both us-east-1).
</details>

---

## 🛠️ Useful Commands

```bash
# Check Rosco logs
kubectl logs -n spinnaker spin-rosco-xxx | grep -i "error\|bake\|packer"

# Validate Packer template locally
packer validate packer-template.json

# Find valid base AMIs
aws ec2 describe-images --owners amazon \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04*" \
  --region us-west-2 --query 'Images[0].ImageId'

# Check Rosco configuration
kubectl exec -n spinnaker spin-rosco-xxx -- cat /opt/rosco/config/rosco.yml

# View bake logs
curl http://localhost:8087/api/v1/bakes | jq '.[-1]'
```

---

## 📖 References

- https://spinnaker.io/docs/setup/bakery/
- https://spinnaker.io/docs/reference/pipeline/stages/#bake
- https://www.packer.io/docs/templates/json_templates
- https://spinnaker.io/docs/guides/user/pipeline/baking-images/

---

## 🏁 Success Criteria

- Packer template validates without JSON errors
- Base AMI is found in the target region
- Bake completes and produces a new AMI ID
- AMI is accessible in the deployment region
