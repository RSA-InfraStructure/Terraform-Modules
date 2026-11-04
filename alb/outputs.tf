output "alb_arn" {
  description = "ARN of the load balancer."
  value       = aws_lb.this.arn
}

output "alb_arn_suffix" {
  description = "ARN suffix, used as the LoadBalancer dimension of CloudWatch alarms."
  value       = aws_lb.this.arn_suffix
}

output "dns_name" {
  description = "DNS name of the load balancer (target of your DNS record)."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Hosted zone ID of the load balancer, for Route 53 alias records."
  value       = aws_lb.this.zone_id
}

output "security_group_id" {
  description = "Security group of the load balancer. Services allow ingress from it."
  value       = aws_security_group.this.id
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener. Services attach their listener rules to it."
  value       = aws_lb_listener.https.arn
}
