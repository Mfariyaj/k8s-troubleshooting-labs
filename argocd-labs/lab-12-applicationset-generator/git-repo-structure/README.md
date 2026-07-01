# Git Repository Structure
# This simulates the remote repo at https://git.example.com/platform/services.git
#
# Actual structure:
# services/
# ├── api-gateway/
# │   ├── base/
# │   │   ├── deployment.yaml
# │   │   └── kustomization.yaml
# │   └── overlays/
# │       ├── production/
# │       │   └── kustomization.yaml
# │       └── staging/
# │           └── kustomization.yaml
# ├── payment-service/
# │   ├── base/
# │   │   ├── deployment.yaml
# │   │   └── kustomization.yaml
# │   └── overlays/
# │       ├── production/
# │       │   └── kustomization.yaml
# │       └── staging/
# │           └── kustomization.yaml
# └── user-service/
#     ├── base/
#     │   ├── deployment.yaml
#     │   └── kustomization.yaml
#     └── overlays/
#         ├── production/
#         │   └── kustomization.yaml
#         └── staging/
#             └── kustomization.yaml
#
# NOTE: The ApplicationSet's git directory generator references 'apps/*'
# but the correct path should be 'services/*'
