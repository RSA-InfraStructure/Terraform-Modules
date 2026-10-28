# static-site

Private S3 bucket served through CloudFront with Origin Access Control. The bucket blocks all public access, is encrypted and versioned, and only this distribution can read it. Optional single-page-app fallback to `index.html`.

## Example

```hcl
module "web" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//static-site?ref=v0.1.0"

  name        = "rsa-prod-web"
  bucket_name = "rsa-prod-web-assets"

  aliases         = ["app.example.com"]
  certificate_arn = module.dns_us_east_1.certificate_arns["prod"]
}
```

Deploy by syncing the build output to the bucket and invalidating CloudFront:

```
aws s3 sync ./build s3://<bucket_name> --delete
aws cloudfront create-invalidation --distribution-id <distribution_id> --paths "/*"
```

Create the Route 53 alias record with the `dns-certs` module, using `distribution_domain_name` and `distribution_hosted_zone_id`. The ACM certificate for CloudFront must be in `us-east-1`.
