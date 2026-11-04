# ecs-service

One application service on ECS Fargate, behind the shared ALB. It enforces the container standards so every app gets them by default.

## Built-in standards

- **CPU and memory are always set** (required inputs; no unlimited option).
- **Health checks**: a container health check plus the target group health check on `health_check_path` (default `/health`), with a grace period.
- **No `latest` tag**: the `image` input is rejected if it uses `latest` or has no tag or digest. Use the git SHA.
- **Safe deploys**: deployment circuit breaker with automatic rollback, minimum healthy 100%, maximum 200%.
- **Secrets by reference**: `secrets` maps environment variable names to Secrets Manager ARNs; the values never appear in the task definition or in Terraform.
- **Cheap defaults**: ARM64, one task, 14-day logs, optional Fargate Spot for staging.
- The service accepts traffic only from the ALB security group.

## Usage

```hcl
module "api" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//ecs-service?ref=ecs-service-v1.0.0"

  name        = "rsa-staging-api"
  cluster_arn = module.cluster.cluster_arn
  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.private_subnet_ids

  image          = "${module.ecr.repository_urls["api"]}:${var.image_tag}"
  container_port = 8080
  cpu            = 256
  memory         = 512

  listener_arn           = module.alb.https_listener_arn
  alb_security_group_id  = module.alb.security_group_id
  host_headers           = ["api.staging.example.com"]
  listener_rule_priority = 100

  environment = { LOG_LEVEL = "info" }
  secrets     = { DATABASE_URL = module.secrets.secret_arns["api-database-url"] }

  use_spot = true # staging only

  tags = { app = "api", env = "staging", owner = "devops", managed-by = "terraform" }
}
```

## Notes

- The default container health check runs `curl` inside the image. If your image has no `curl`, set `container_health_check_command`.
- Fargate allows only certain cpu and memory pairs (for example 256 CPU with 512, 1024 or 2048 MiB). AWS rejects an invalid pair at apply time.
- With `enable_autoscaling = true`, Terraform and autoscaling both manage the task count. Set `desired_count` equal to `min_capacity`.
- A DNS record for `host_headers` must point at the ALB (see the `alb` and `dns-certs` modules).

## Inputs (main ones)

| Name | Description | Default |
|---|---|---|
| `name`, `cluster_arn`, `vpc_id`, `subnet_ids` | Where it runs | required |
| `image` | Image with an immutable tag | required |
| `container_port`, `cpu`, `memory` | App port and limits | required |
| `listener_arn`, `alb_security_group_id`, `host_headers`, `listener_rule_priority` | ALB wiring | required |
| `architecture` | `ARM64` or `X86_64` | `ARM64` |
| `desired_count` | Tasks | `1` |
| `use_spot` | Fargate Spot | `false` |
| `health_check_path` | Health endpoint | `/health` |
| `environment`, `secrets` | Variables, and secret ARNs | `{}` |
| `task_role_policy_json` | What the app may do in AWS | `null` |
| `enable_autoscaling`, `min_capacity`, `max_capacity`, `cpu_target_percent` | Scaling | off, 1, 2, 70 |
| `log_retention_days` | Log retention | `14` |

## Outputs

`service_name`, `task_definition_arn`, `security_group_id`, `target_group_arn_suffix`, `log_group_name`, `task_role_arn`, `execution_role_arn`.

## Cost

A 0.25 vCPU / 0.5 GB ARM64 task costs about $9 a month running all day (about $3 on Spot). Plus logs and the shared ALB.
