################################################################################
# Security group
################################################################################

resource "aws_security_group" "this" {
  name        = "${var.name}-alb"
  description = "Load balancer ${var.name}"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name}-alb" })
}

# Public web ports on the load balancer are the one place open ingress is intended.
#trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = toset(var.allowed_ingress_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "HTTPS"
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

#trivy:ignore:AVD-AWS-0107
resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.allowed_ingress_cidrs)

  security_group_id = aws_security_group.this.id
  description       = "HTTP (redirected to HTTPS)"
  cidr_ipv4         = each.value
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# The load balancer only talks to targets inside the VPC.
resource "aws_vpc_security_group_egress_rule" "targets" {
  security_group_id = aws_security_group.this.id
  description       = "To targets in the VPC"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "-1"
}

################################################################################
# Load balancer
################################################################################

# A public ALB is intended here. Set internal = true for a private one.
#trivy:ignore:AVD-AWS-0053
resource "aws_lb" "this" {
  name                       = var.name
  load_balancer_type         = "application"
  internal                   = var.internal
  security_groups            = [aws_security_group.this.id]
  subnets                    = var.subnet_ids
  idle_timeout               = var.idle_timeout
  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.access_logs_bucket == null ? [] : [1]

    content {
      bucket  = var.access_logs_bucket
      prefix  = var.name
      enabled = true
    }
  }

  tags = merge(var.tags, { Name = var.name })
}

# HTTP only redirects to HTTPS.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.tags
}

# Services add their own rules (host or path based). Anything unmatched gets a 404.
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }

  tags = var.tags
}
