## Solution: Module Source Not Found

### Root Cause

Four module source issues prevent `terraform init` from downloading modules:

1. **`module.vpc`** — uses `hashicorp-fake/vpc/aws` (namespace doesn't exist; correct is `terraform-aws-modules`)
2. **`module.networking`** — references a nonexistent GitHub repository with an impossible tag `v99.0.0`
3. **`module.compute`** — version constraint `>= 99.0.0` is impossible; no module has that version
4. **`module.monitoring`** — local path `./modules/monitoring-stack` doesn't exist on disk

### Step-by-Step Fix

```bash
# 1. Fix all module sources in main.tf (see corrected code below)

# 2. Create the local module directory if using a local module
mkdir -p modules/monitoring-stack
cat > modules/monitoring-stack/main.tf << 'EOF'
variable "enable_alerts" { type = bool }
variable "sns_topic_arn" { type = string }
# Add monitoring resources here
EOF

# 3. Reinitialize to download corrected modules
terraform init

# 4. Verify all modules are resolved
terraform validate
```

### Fixed Code (main.tf)

```hcl
# Fix 1: Correct registry namespace
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "prod-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = { Environment = "production" }
}

# Fix 2: Use a valid git source or remove this module
module "networking" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.1.0"

  vpc_id = module.vpc.vpc_id
}

# Fix 3: Use a realistic version constraint
module "compute" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.0"

  name          = "web-server"
  instance_type = "t3.medium"
  subnet_id     = module.vpc.private_subnets[0]

  tags = { Environment = "production" }
}

# Fix 4: Ensure local module path exists
module "monitoring" {
  source = "./modules/monitoring-stack"

  enable_alerts = true
  sns_topic_arn = "arn:aws:sns:us-east-1:123456789:alerts"
}
```

### Verification

```bash
terraform init
terraform validate
terraform plan
```
