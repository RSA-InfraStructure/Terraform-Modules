output "bucket_name" {
  description = "Name of the state bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the state bucket."
  value       = aws_s3_bucket.this.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key that encrypts the state."
  value       = aws_kms_key.this.arn
}

output "kms_alias_name" {
  description = "Alias of the KMS key, e.g. alias/rsa-staging-tfstate."
  value       = aws_kms_alias.this.name
}

output "access_policy_json" {
  description = "IAM policy document that lets a role read and write state in this bucket and use its key. Attach it to the deploy role of this environment only."
  value       = data.aws_iam_policy_document.access.json
}

output "backend_config" {
  description = "Values for the backend \"s3\" block of this environment. Add your own key, e.g. <app>/staging/terraform.tfstate."
  value = {
    bucket       = aws_s3_bucket.this.id
    region       = data.aws_region.current.region
    encrypt      = true
    kms_key_id   = aws_kms_alias.this.name
    use_lockfile = true
  }
}
