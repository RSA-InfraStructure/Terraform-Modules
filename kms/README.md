# kms

One customer managed KMS key for an environment's application data and secrets. Create **one per environment** (staging and prod each get their own), so a role that can use the staging key cannot decrypt anything of prod's.

## What it creates

- A KMS key with automatic yearly rotation, and an alias.
- `prevent_destroy`, because losing a key makes everything encrypted with it unreadable.
- A key policy that delegates to IAM, so access is granted by IAM policies, not by the key itself.

State encryption has its own key inside the `state-backend` module, and the alarm topic has its own inside `alarms`. This module is for the **application** side.

## Usage

```hcl
module "kms" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//kms?ref=kms-v1.0.0"

  name = "rsa-staging-data"
  tags = { app = "platform", env = "staging", owner = "devops", managed-by = "terraform" }
}

module "secrets" {
  # ...
  secrets = {
    "api-database-url" = { kms_key_id = module.kms.key_arn }
  }
}

module "db" {
  # ...
  kms_key_id                   = module.kms.key_arn # storage
  master_user_secret_kms_key_id = module.kms.key_arn # generated password
}

module "api" {
  # ...
  secrets_kms_key_arn = module.kms.key_arn
}
```

`ecs-service` receives the key so its execution role may decrypt the secrets at startup. Give a role access to the key only in its own environment.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Alias name without `alias/` | required |
| `description` | Shown in the console | `Application data and secrets` |
| `deletion_window_days` | Waiting period before deletion (7-30) | `30` |
| `tags` | Tags | `{}` |

## Outputs

`key_arn`, `key_id`, `alias_name`.

## Cost

About $1 a month per key, plus a tiny charge per request.
