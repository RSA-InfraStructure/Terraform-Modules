# state-backend

Creates the S3 bucket and KMS key that store the Terraform state of **one environment**. Use one instance per environment (staging and prod each get their own bucket and key).

## What it creates

- S3 bucket: versioning on, public access fully blocked, owner-enforced ownership, SSE-KMS with a bucket key, HTTPS-only policy, old versions expire after `noncurrent_version_expiration_days`.
- KMS key with rotation on, and an alias.
- `prevent_destroy` on the bucket and the key, so a `terraform destroy` cannot delete the state by accident.
- An IAM policy document (`access_policy_json`) for the role that runs Terraform in this environment.

Locking uses S3's own lock file (`use_lockfile = true`, Terraform 1.10 or later). No DynamoDB table.

## Usage

```hcl
module "state" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//state-backend?ref=state-backend-v1.0.0"

  bucket_name = "rsa-staging-tfstate"
  tags        = { app = "platform", env = "staging", owner = "devops", managed-by = "terraform" }
}
```

## Bootstrap (once per environment)

The bucket has to exist before Terraform can keep state in it, so the first run uses local state:

1. In the infra repo, `bootstrap/<env>/main.tf` calls this module. Run `terraform init` and `terraform apply` with local state (through your approval, from an admin session).
2. Add the `backend "s3"` block using the `backend_config` output plus your key (`<app>/<env>/terraform.tfstate`).
3. Run `terraform init -migrate-state` and answer yes.
4. Delete the local `terraform.tfstate` files. Do not commit them.
5. Attach `access_policy_json` to the deploy role of **this environment only**.

## Inputs

| Name | Description | Default |
|---|---|---|
| `bucket_name` | Globally unique bucket name | required |
| `kms_alias` | Alias name without `alias/` | bucket name |
| `kms_deletion_window_days` | Waiting period before key deletion (7-30) | `30` |
| `noncurrent_version_expiration_days` | Days to keep old state versions | `90` |
| `tags` | Tags on all resources | `{}` |

## Outputs

| Name | Description |
|---|---|
| `bucket_name`, `bucket_arn` | The state bucket |
| `kms_key_arn`, `kms_alias_name` | The state key |
| `access_policy_json` | Policy for the environment's deploy role |
| `backend_config` | Values for the `backend "s3"` block |

## Cost

A few cents a month: one KMS key (about $1 a month) plus S3 storage for small state files.
