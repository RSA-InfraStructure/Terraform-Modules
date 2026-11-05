# rds-postgres

A PostgreSQL instance that follows the standards: private, encrypted, no password in code, single-AZ and small by default.

## Built-in standards

- In the isolated subnets; `publicly_accessible = false` is fixed, not an input.
- Storage encrypted, gp3, SSL forced (`rds.force_ssl = 1`).
- **No password input.** `manage_master_user_password = true` makes RDS generate it and keep it in Secrets Manager; the secret ARN is an output.
- IAM database authentication on, for read-only developer access in prod (a Postgres role with `SELECT` only).
- Deletion protection on, final snapshot on, 7 days of backups.
- Generic: no database name or app name is hard-coded.

## Usage

```hcl
module "db" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//rds-postgres?ref=rds-postgres-v1.0.0"

  name       = "rsa-staging-db"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.isolated_subnet_ids

  allowed_security_group_ids = [module.api.security_group_id, module.bastion.security_group_id]

  tags = { app = "api", env = "staging", owner = "devops", managed-by = "terraform" }
}
```

Developers reach it with SSM port forwarding through the `ssm-bastion` module, never directly.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name`, `vpc_id`, `subnet_ids` | Identity and placement | required |
| `allowed_security_group_ids` | Who may connect | `[]` |
| `engine_version` | PostgreSQL version | `16` |
| `instance_class` | Instance size | `db.t4g.micro` |
| `allocated_storage`, `max_allocated_storage` | GiB, autoscaling limit (0 = off) | `20`, `100` |
| `multi_az` | Standby in a second AZ | `false` |
| `master_username` | Master user name | `dbadmin` |
| `backup_retention_days` | Automated backups | `7` |
| `deletion_protection` | Block deletion | `true` |
| `skip_final_snapshot` | Skip the final snapshot | `false` |
| `kms_key_id` | Custom storage key | `null` |
| `master_user_secret_kms_key_id` | Key for the generated password in Secrets Manager (use the environment's `kms` key) | `null` |

## Outputs

`address`, `port`, `identifier`, `arn`, `security_group_id`, `master_user_secret_arn`.

## Cost

`db.t4g.micro` single-AZ with 20 GiB gp3 is about $13 a month. `multi_az = true` roughly doubles the instance cost. Check the budget before enabling it.
