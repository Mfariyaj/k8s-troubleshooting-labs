## 🎯 How to Use This Lab

1. Deploy: `./deploy.sh` (copies broken config to workspace)
2. Upload pipeline: `spin pipeline save --file pipeline.json`
3. Execute: `spin pipeline execute --name <pipeline> --application <app>`
4. Check Spinnaker UI for execution errors
5. Fix the pipeline JSON or service config
6. Check `solution.md` if stuck

---

# Lab 01: Halyard Config Broken — Storage Backend Misconfigured

## Difficulty: 🟢 Beginner

---

## 📚 What You'll Learn

**Halyard** is the CLI tool used to configure and deploy Spinnaker. It manages the entire lifecycle of a Spinnaker deployment — from initial setup to upgrades. Halyard stores its configuration in `~/.hal/config` (the "hal config") and translates it into individual service configurations.

One of the most critical decisions in Spinnaker setup is choosing a **persistent storage backend**. Front50 (the metadata service) needs reliable storage for:
- Pipeline definitions
- Application metadata  
- Notification preferences
- Pipeline templates

Supported storage backends include:
- **S3** (AWS) — most common in AWS environments
- **GCS** (Google Cloud Storage) — for GCP deployments
- **Azure Blob Storage** — for Azure deployments
- **Oracle Object Storage** — for OCI
- **MinIO** — S3-compatible for on-prem
- **SQL (MySQL/PostgreSQL)** — newer option, recommended for large deployments

When storage is misconfigured, **Front50 crashes on startup**, which cascades to other services (Orca, Echo) that depend on it for pipeline definitions.

---

## 🔧 Scenario

You've been asked to set up a new Spinnaker deployment using Halyard. A colleague started the configuration but left before finishing. When you run `hal deploy apply`, it fails. The storage backend is configured for S3 but:

1. The S3 bucket name references a bucket that doesn't exist
2. The region is set to a non-existent AWS region
3. The IAM credentials section has placeholder values

---

## 💥 Expected Error Output

When running `hal deploy apply`:
```
Problems in default.persistentStorage:
- WARNING Your S3 bucket does not exist. Halyard will try to create it,
  but if this is not desired, create the bucket manually and try again.
- ERROR Could not reach S3 bucket 'spinnaker-data-bucket-CHANGEME':
  com.amazonaws.services.s3.model.AmazonS3Exception: The specified bucket
  does not exist (Service: Amazon S3; Status Code: 404; Error Code:
  NoSuchBucket)
- ERROR Invalid region: 'us-north-1' is not a valid AWS region.

Problems in default.persistentStorage.s3:
- ERROR Unable to authenticate with AWS using provided credentials.
  Access key ID 'AKIA_PLACEHOLDER_KEY' is not valid.
```

---

## 💡 Hints

<details>
<summary>Hint 1 (Gentle)</summary>
Look at the storage section of the hal config. What bucket name, region, and credentials are configured?
</details>

<details>
<summary>Hint 2 (Moderate)</summary>
Run `hal config storage s3 edit --help` to see what parameters can be fixed. The region must be a valid AWS region like `us-east-1`, `us-west-2`, etc.
</details>

<details>
<summary>Hint 3 (Strong)</summary>
You need to: 1) Create the S3 bucket or use an existing one, 2) Fix the region to a valid AWS region, 3) Configure valid AWS credentials (access key + secret key, or use IAM instance role). Use `hal config storage s3 edit --bucket REAL_BUCKET --region us-east-1`.
</details>

---

## 🛠️ Useful Commands

```bash
# Inspect current storage config
hal config storage edit --help
hal config storage s3 edit --help

# View current config (shows what's wrong)
hal config storage s3

# Fix storage settings
hal config storage s3 edit --bucket <valid-bucket> --region <valid-region>
hal config storage s3 edit --access-key-id <key> --secret-access-key

# Validate config
hal config

# Test S3 connectivity
aws s3 ls s3://<bucket-name>/ --region <region>

# Apply the fixed config
hal deploy apply
```

---

## 📖 References

- https://spinnaker.io/docs/setup/install/storage/
- https://spinnaker.io/docs/setup/install/storage/s3/
- https://spinnaker.io/docs/reference/halyard/commands/
- https://spinnaker.io/docs/setup/install/

---

## 🏁 Success Criteria

- `hal config` completes without errors
- `hal deploy apply` succeeds (or at least passes storage validation)
- Front50 pod starts and becomes healthy
