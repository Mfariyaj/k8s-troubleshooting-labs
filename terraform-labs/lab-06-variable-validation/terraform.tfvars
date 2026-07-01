# BUG 1: "prod" is not valid - must be "dev", "staging", or "production"
environment = "prod"

# BUG 2: Starts with uppercase, has underscore - violates regex
project_name = "My_Project"

# BUG 3: c5.xlarge is not allowed - must be t3 or m5 family
instance_type = "c5.xlarge"

# BUG 4: This is a number, not a string CIDR block
vpc_cidr = 10

# BUG 5: 0 is not a valid port (must be 1-65535), and 99999 exceeds max
allowed_ports = [80, 443, 0, 99999]

# BUG 6: 15 exceeds maximum of 10
instance_count = 15

# BUG 7: Missing required "Owner" key
tags = {
  Team        = "platform"
  Environment = "prod"
}
