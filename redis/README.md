# redis

ElastiCache Redis replication group with its own security group, encrypted at rest and (by default) in transit.

Defaults are lean (single `cache.t4g.micro` node). For prod, use a replica:

```hcl
module "redis" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//redis?ref=v0.1.0"

  name       = "rsa-prod"
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids

  allowed_security_group_ids = [module.ecs_cluster.tasks_security_group_id]

  node_type                  = "cache.t4g.small"
  num_cache_clusters         = 2
  automatic_failover_enabled = true
  multi_az_enabled           = true

  tags = { env = "prod" }
}
```

With `transit_encryption_enabled = true`, clients must connect with TLS (`rediss://`).
