resource "aws_security_group" "this" {
  name        = "${var.name}-redis"
  description = "Redis access for ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-redis" })
}

resource "aws_vpc_security_group_ingress_rule" "clients" {
  for_each = toset(var.allowed_security_group_ids)

  security_group_id            = aws_security_group.this.id
  description                  = "Redis from client security group"
  referenced_security_group_id = each.value
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-redis"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = "${var.name}-redis"
  description          = "Redis for ${var.name}"

  engine         = "redis"
  engine_version = var.engine_version
  node_type      = var.node_type
  port           = var.port

  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = var.transit_encryption_enabled

  snapshot_retention_limit = var.snapshot_retention_days
  apply_immediately        = var.apply_immediately

  tags = merge(var.tags, { Name = "${var.name}-redis" })

  lifecycle {
    precondition {
      condition     = !var.automatic_failover_enabled || var.num_cache_clusters >= 2
      error_message = "automatic_failover_enabled requires num_cache_clusters >= 2."
    }
    precondition {
      condition     = !var.multi_az_enabled || var.automatic_failover_enabled
      error_message = "multi_az_enabled requires automatic_failover_enabled."
    }
  }
}
