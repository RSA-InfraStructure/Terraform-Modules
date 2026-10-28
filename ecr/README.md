# ecr

Container image repositories with scan-on-push, encryption, immutable tags and a lifecycle policy (expire untagged images, keep the last N tagged images).

Repositories are named `<name>/<repository>`, e.g. `rsa/api`.

## Example

```hcl
module "ecr" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//ecr?ref=v0.1.0"

  name         = "rsa"
  repositories = ["api", "worker"]

  tags = { managed-by = "terraform" }
}
```

Tag images with the git SHA. With the default `IMMUTABLE` tags, never rely on `latest`.
