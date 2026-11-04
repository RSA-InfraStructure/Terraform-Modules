# secrets

Creates Secrets Manager **containers** only. The secret **value** is set by a person, outside Terraform, so it never lands in code, tfvars, CI variables or Terraform state.

## Usage

```hcl
module "secrets" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//secrets?ref=secrets-v1.0.0"

  name_prefix = "rsa/staging"

  secrets = {
    "api-database-url" = { description = "Connection string for the api" }
    "cloudflare-token" = { description = "Cloudflare DNS API token (one zone, DNS edit only)" }
  }

  tags = { app = "api", env = "staging", owner = "devops", managed-by = "terraform" }
}
```

After the first apply, a person sets each value, for example in the AWS console (Secrets Manager → the secret → Retrieve/Set secret value). The agents cannot read or set values.

Then give the secret to a service:

```hcl
secrets = { DATABASE_URL = module.secrets.secret_arns["api-database-url"] }
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `name_prefix` | Prefix of the secret names | required |
| `secrets` | Map of containers (`description`, `kms_key_id`, `recovery_window_in_days`) | `{}` |
| `tags` | Tags | `{}` |

## Outputs

`secret_arns`, `secret_names`.

## Cost

About $0.40 a month per secret.
