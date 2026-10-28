output "bucket_name" {
  description = "Name of the S3 bucket (upload the build output here)."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.this.arn
}

output "distribution_id" {
  description = "CloudFront distribution ID (used for cache invalidation after a deploy)."
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN."
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront domain name (target for alias records)."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "Hosted zone ID of the distribution, for Route 53 alias records."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}
