# Lab 14: Provider Crash / Panic During Plan

## Difficulty: 🔴 Expert

## Estimated Time: 15-25 minutes

---

## Scenario

Your team uses a community Terraform provider (`terraform-provider-datadog` or similar) for managing monitoring resources. After upgrading Terraform from 1.3 to 1.6, `terraform plan` crashes with a **Go panic / stack trace**. The provider binary is incompatible with the new Terraform version.

Additionally, there are version constraint issues causing Terraform to pull a known-buggy provider version, missing required provider configuration blocks that cause nil pointer dereferences, and protocol version mismatches between the provider and Terraform core.

This lab simulates the diagnostic process — you won't actually crash a provider, but you'll identify all the configuration issues that would cause it.

---

## Error Output

```
$ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding datadog/datadog versions matching ">= 3.0.0, < 3.21.0"...
- Finding custom-corp/monitoring versions matching "~> 1.2"...
- Installing datadog/datadog v3.20.0...
- Installed datadog/datadog v3.20.0 (signed by a]HashiCorp partner, key ID ...)
- Installing custom-corp/monitoring v1.2.3...

╷
│ Warning: Additional provider information from registry
│ 
│ The remote registry returned warnings for custom-corp/monitoring:
│ - This provider version is not compatible with Terraform >= 1.5
│ - Consider upgrading to custom-corp/monitoring v2.0.0+
╵

Terraform has been successfully initialized!

$ terraform plan

╷
│ Error: Plugin error
│ 
│ The plugin returned an unexpected error from plugin.(*GRPCProvider).ConfigureProvider:
│ rpc error: code = Unavailable desc = error reading from server: EOF
╵

# With TF_LOG=DEBUG:
$ TF_LOG=DEBUG terraform plan 2>&1

2024-01-15T10:23:45.678Z [DEBUG] provider: plugin process exited: 
  path=.terraform/providers/registry.terraform.io/custom-corp/monitoring/1.2.3/linux_amd64/terraform-provider-monitoring_v1.2.3
  pid=12345
  error="exit status 2"

2024-01-15T10:23:45.679Z [DEBUG] provider.terraform-provider-monitoring_v1.2.3: 
  panic: runtime error: invalid memory address or nil pointer dereference
  [signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x1a2b3c4]
  
  goroutine 1 [running]:
  github.com/custom-corp/terraform-provider-monitoring/internal/provider.(*monitoringProvider).Configure(...)
      /build/internal/provider/provider.go:89
  github.com/hashicorp/terraform-plugin-framework/internal/fwserver.(*Server).ConfigureProvider(...)
      /go/pkg/mod/github.com/hashicorp/terraform-plugin-framework@v1.2.0/internal/fwserver/server_configureprovider.go:32

2024-01-15T10:23:45.680Z [ERROR] provider.stdio: received EOF, provider output:
  panic: interface conversion: interface {} is nil, not *schema.Provider

2024-01-15T10:23:45.681Z [DEBUG] provider: plugin failed to respond to 
  GetProviderSchema.get_provider_schema: 
  Incompatible API version with plugin. Plugin version: 5, Client version: 6

$ terraform plan
╷
│ Error: Incompatible provider version
│ 
│ Provider "registry.terraform.io/custom-corp/monitoring" v1.2.3 is not compatible
│ with Terraform v1.6.0. Provider protocol version 5 is not supported by this 
│ version of Terraform. Supported protocol versions: 6.
│ 
│ Either downgrade Terraform or upgrade the provider to a version that supports
│ protocol version 6.
╵
```

---

## Hints

<details>
<summary>Hint 1</summary>
Check `versions.tf` — the version constraint `>= 3.0.0, < 3.21.0` explicitly excludes v3.21.0+ which contains the fix for the crash. Also the custom provider constraint `~> 1.2` pins to a version compiled for protocol 5 (Terraform < 1.5). The constraint should be `~> 2.0` for protocol 6 compatibility.
</details>

<details>
<summary>Hint 2</summary>
The provider `custom-corp/monitoring` requires a `base_url` and `auth_token` in its configuration block. In `main.tf`, the provider block is declared but `auth_token` is set to an empty string, causing a nil pointer dereference when the provider tries to build an HTTP client. Check how the provider is configured.
</details>

<details>
<summary>Hint 3</summary>
There are also `required_providers` source address issues — the Datadog provider source is listed as `"datadog/datadog"` but the correct HashiCorp registry path is `"DataDog/datadog"` (case-sensitive on some platforms). The custom provider's source still points to the old namespace before migration.
</details>

---

## Troubleshooting Commands

```bash
# Check Terraform version
terraform version

# Check provider protocol compatibility
terraform version -json | jq '.provider_selections'

# See what provider versions are installed
ls -la .terraform/providers/

# Check the provider binary details
file .terraform/providers/registry.terraform.io/custom-corp/monitoring/1.2.3/linux_amd64/terraform-provider-monitoring*

# Try to get the provider schema
terraform providers schema -json 2>&1 | head -50

# Enable maximum debug logging
TF_LOG=TRACE terraform plan 2>&1 | tee crash.log

# Check for crash logs
ls -la crash.log

# Look at the version constraints
grep -r "version" versions.tf

# Check provider lock file for what was resolved
cat .terraform.lock.hcl

# Verify provider registry availability
terraform providers mirror /tmp/mirror 2>&1

# Check if newer provider version fixes the crash
terraform init -upgrade

# Validate configuration without planning
terraform validate

# Check the provider configuration block
grep -A 10 'provider "monitoring"' main.tf
```

---

## What to Fix

1. Update `versions.tf` provider constraints to allow compatible versions (datadog >= 3.21.0, monitoring ~> 2.0)
2. Fix the provider source address case sensitivity (`DataDog/datadog` not `datadog/datadog`)
3. Fix the custom provider source namespace (migrated from `custom-corp/monitoring` to `customcorp/monitoring`)
4. Add required `auth_token` configuration (non-empty) in the provider block
5. Remove or update the incompatible `required_version` constraint that blocks Terraform 1.6+
6. Ensure `base_url` uses HTTPS (the provider panics on HTTP URLs in v2+)
