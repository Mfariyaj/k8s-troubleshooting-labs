#!/usr/bin/env python3
"""
Config File Parser — YAML & JSON
==================================
This script reads Kubernetes YAML configs and Terraform JSON state.

INTENDED BEHAVIOR:
- Parse multi-document YAML (K8s deployment + service)
- Parse Terraform state JSON
- Handle YAML gotchas (yes/no → boolean)
- Produce a unified infrastructure report
"""

import json
import os
import sys

try:
    import yaml
except ImportError:
    # Provide a minimal YAML parser fallback for the lab
    class yaml:
        @staticmethod
        def safe_load(stream):
            """Minimal fallback - just shows the error."""
            raise ImportError("PyYAML not installed. Run: pip install pyyaml")
        
        @staticmethod
        def safe_load_all(stream):
            raise ImportError("PyYAML not installed. Run: pip install pyyaml")


def parse_kubernetes_yaml(filepath):
    """Parse a Kubernetes YAML file (possibly multi-document)."""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # BUG 1: Using yaml.safe_load() for multi-document YAML — only reads first document!
    # Should use yaml.safe_load_all() for files with --- separators
    documents = yaml.safe_load(content)
    
    # This will fail because safe_load returns ONE document, not a list
    if not isinstance(documents, list):
        documents = [documents]
    
    return documents


def extract_env_vars(deployment):
    """Extract environment variables from a K8s deployment."""
    containers = deployment.get("spec", {}).get("template", {}).get("spec", {}).get("containers", [])
    
    env_vars = {}
    for container in containers:
        for env in container.get("env", []):
            name = env["name"]
            value = env["value"]
            env_vars[name] = value
    
    return env_vars


def check_yaml_gotchas(env_vars):
    """Check for YAML type coercion issues (yes/no → True/False)."""
    issues = []
    for key, value in env_vars.items():
        # BUG 2: YAML converts 'yes'/'no' to boolean True/False
        # The script doesn't handle this — it assumes all values are strings
        # Comparing boolean to string "yes" will never match
        if value == "yes":
            issues.append(f"  ⚠️  {key}={value} (string 'yes' — will be True in YAML)")
        elif value == "no":
            issues.append(f"  ⚠️  {key}={value} (string 'no' — will be False in YAML)")
        
        # BUG 3: Port value 8080 without quotes becomes int in YAML, not string
        if key == "PORT" and isinstance(value, int):
            issues.append(f"  ⚠️  {key}={value} (type: {type(value).__name__} — expected string)")
    
    return issues


def parse_terraform_json(filepath):
    """Parse Terraform state JSON file."""
    with open(filepath, 'r') as f:
        # BUG: Using json.loads instead of json.load (loads is for strings, load for files)
        data = json.loads(f.read())  # Works but not idiomatic — json.load(f) is cleaner
    
    return data


def extract_instances(tf_state):
    """Extract EC2 instance details from Terraform state."""
    instances = []
    
    resources = tf_state.get("terraform_state", {}).get("resources", [])
    for resource in resources:
        if resource["type"] == "aws_instance":
            for instance in resource["instances"]:
                attrs = instance["attributes"]
                instances.append({
                    "name": attrs["tags"]["Name"],
                    "id": attrs["id"],
                    "type": attrs["instance_type"],
                    "public_ip": attrs.get("public_ip", "N/A"),
                    "private_ip": attrs["private_ip"],
                })
    
    return instances


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    print("=" * 60)
    print("  Infrastructure Config Parser")
    print("=" * 60)
    
    # Parse Kubernetes YAML
    yaml_path = os.path.join(script_dir, "broken_config.yaml")
    print("\n☸️  Kubernetes Resources:")
    
    try:
        documents = parse_kubernetes_yaml(yaml_path)
        
        for doc in documents:
            if doc is None:
                continue
            kind = doc.get("kind", "Unknown")
            name = doc.get("metadata", {}).get("name", "unnamed")
            print(f"  📄 {kind}: {name}")
            
            # Check env vars for YAML gotchas
            if kind == "Deployment":
                env_vars = extract_env_vars(doc)
                print(f"     Environment variables: {len(env_vars)}")
                for k, v in env_vars.items():
                    print(f"       {k}={v} (type: {type(v).__name__})")
                
                issues = check_yaml_gotchas(env_vars)
                if issues:
                    print("     ⚠️  YAML Gotchas Detected:")
                    for issue in issues:
                        print(f"       {issue}")
        
        if len(documents) < 2:
            print("  ⚠️  Expected 2 documents (Deployment + Service) but only found 1!")
            print("     Check: Are you using safe_load_all() for multi-doc YAML?")
    
    except ImportError as e:
        print(f"  ❌ {e}")
        print("  Install with: pip install pyyaml")
    except Exception as e:
        print(f"  ❌ YAML parse error: {e}")
    
    # Parse Terraform JSON
    json_path = os.path.join(script_dir, "broken_data.json")
    print("\n🏗️  Terraform State:")
    
    try:
        tf_state = parse_terraform_json(json_path)
        instances = extract_instances(tf_state)
        
        for inst in instances:
            public = inst["public_ip"] if inst["public_ip"] else "none"
            print(f"  🖥️  {inst['name']} ({inst['type']})")
            print(f"     ID: {inst['id']}")
            print(f"     Private: {inst['private_ip']} | Public: {public}")
    
    except json.JSONDecodeError as e:
        print(f"  ❌ JSON parse error: {e}")
    except Exception as e:
        print(f"  ❌ Error: {e}")
    
    print("\n" + "=" * 60)


if __name__ == "__main__":
    main()
