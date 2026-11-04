# alb

One **shared** Application Load Balancer per environment. All services use it through host-based listener rules (see `ecs-service`). Never create one ALB per service (about $20 a month each).

## What it creates

- Security group: ports 80 and 443 in from `allowed_ingress_cidrs`, traffic out only to the VPC CIDR.
- ALB with invalid headers dropped and deletion protection on.
- HTTP listener (80) that redirects to HTTPS.
- HTTPS listener (443) with your ACM certificate and a TLS 1.2/1.3 policy. Unmatched requests get a 404.

## Usage

```hcl
module "alb" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//alb?ref=alb-v1.0.0"

  name            = "rsa-staging"
  vpc_id          = module.network.vpc_id
  vpc_cidr        = module.network.vpc_cidr
  subnet_ids      = module.network.public_subnet_ids
  certificate_arn = module.dns.certificate_arns["main"]

  tags = { app = "platform", env = "staging", owner = "devops", managed-by = "terraform" }
}
```

Point your DNS record at `module.alb.dns_name` (Cloudflare or Route 53 alias with `module.alb.zone_id`).

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Name, max 32 characters | required |
| `vpc_id`, `vpc_cidr` | VPC and its CIDR | required |
| `subnet_ids` | At least two public subnets | required |
| `certificate_arn` | ACM certificate in the same region | required |
| `internal` | Internal load balancer | `false` |
| `allowed_ingress_cidrs` | Who may reach 80/443 | `["0.0.0.0/0"]` |
| `ssl_policy` | TLS policy | `ELBSecurityPolicy-TLS13-1-2-2021-06` |
| `idle_timeout` | Seconds | `60` |
| `enable_deletion_protection` | Protect from deletion | `true` |
| `access_logs_bucket` | S3 bucket for access logs | `null` (off) |
| `tags` | Tags | `{}` |

## Outputs

`alb_arn`, `alb_arn_suffix`, `dns_name`, `zone_id`, `security_group_id`, `https_listener_arn`.

## Cost

About $17 a month for the ALB plus usage-based capacity units, shared by every service in the environment.
