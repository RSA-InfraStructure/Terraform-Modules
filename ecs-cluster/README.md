# ecs-cluster

An ECS cluster with the Fargate and Fargate Spot capacity providers. Create one per environment and run all services of that environment in it. A cluster itself is free.

## Usage

```hcl
module "cluster" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//ecs-cluster?ref=ecs-cluster-v1.0.0"

  name = "rsa-staging"
  tags = { app = "platform", env = "staging", owner = "devops", managed-by = "terraform" }
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Cluster name | required |
| `enable_container_insights` | CloudWatch Container Insights (extra cost) | `false` |
| `tags` | Tags on all resources | `{}` |

## Outputs

`cluster_arn`, `cluster_name`.

## Cost

Free. Costs come from the services that run in it.
