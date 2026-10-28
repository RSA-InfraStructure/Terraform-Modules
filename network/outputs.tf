output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "azs" {
  description = "Availability Zones in use."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs (one per AZ)."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ)."
  value       = aws_subnet.private[*].id
}

output "isolated_subnet_ids" {
  description = "Isolated subnet IDs (one per AZ), intended for databases."
  value       = aws_subnet.isolated[*].id
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Private route table IDs (one per AZ)."
  value       = aws_route_table.private[*].id
}

output "isolated_route_table_id" {
  description = "Isolated route table ID."
  value       = aws_route_table.isolated.id
}

output "nat_public_ips" {
  description = "Public IPs of the NAT gateways (empty when NAT is disabled)."
  value       = aws_eip.nat[*].public_ip
}

output "s3_endpoint_id" {
  description = "ID of the S3 gateway endpoint, or null if disabled."
  value       = try(aws_vpc_endpoint.s3[0].id, null)
}

output "endpoints_security_group_id" {
  description = "Security group attached to interface endpoints, or null if none are created."
  value       = try(aws_security_group.endpoints[0].id, null)
}
