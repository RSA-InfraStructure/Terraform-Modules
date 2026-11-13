# github-oidc

Lets GitHub Actions deploy to AWS **without stored keys**. GitHub proves who is running (repo plus environment), and AWS hands out short-lived credentials to the matching role.

## What it creates

- The GitHub OIDC identity provider (one per AWS account; set `create_oidc_provider = false` if it already exists).
- One IAM role per entry in `roles`. Each role trusts exactly one workflow context:
  - `environment`: `repo:<owner>/<repo>:environment:<env>`
  - or `branch`: `repo:<owner>/<repo>:ref:refs/heads/<branch>`
- Optional inline policy and managed policy attachments per role.

There are no wildcards in the trust. Setting both `environment` and `branch`, or neither, is rejected.

## Usage

Two independent roles, one per environment, in one account:

```hcl
module "github_oidc" {
  source = "git::https://github.com/RSA-InfraStructure/Terraform-Modules.git//github-oidc?ref=github-oidc-v1.0.0"

  name_prefix = "rsa"

  roles = {
    infra-staging = {
      github_repo = "RSA-InfraStructure/infra"
      environment = "staging"
      policy_json = data.aws_iam_policy_document.staging_deploy.json
    }
    infra-prod = {
      github_repo = "RSA-InfraStructure/infra"
      environment = "prod"
      policy_json = data.aws_iam_policy_document.prod_deploy.json
    }
  }

  tags = { app = "platform", env = "shared", owner = "devops", managed-by = "terraform" }
}
```

In the workflow:

```yaml
permissions:
  id-token: write
  contents: read
jobs:
  apply:
    environment: staging          # must match the role's environment
    steps:
      - uses: aws-actions/configure-aws-credentials@<pinned commit sha>
        with:
          role-to-assume: arn:aws:iam::<account id>:role/rsa-infra-staging
          aws-region: us-east-2
```

## How staging and prod stay apart

- The `prod` role trusts only runs that use the GitHub environment `prod`, and that environment has a required reviewer. Nothing can assume the prod role without that approval.
- The staging role cannot assume the prod role, and the reverse.
- Give each role only its own environment's access. Combine the policy from the `state-backend` module (`access_policy_json`) with permissions scoped to resources tagged `env=<environment>` where AWS supports it.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name_prefix` | Prefix for role names | required |
| `create_oidc_provider` | Create the provider (one per account) | `true` |
| `roles` | Map of roles (see above) | `{}` |
| `tags` | Tags on all resources | `{}` |

Each role takes `github_repo`, exactly one of `environment` or `branch`, and optionally `policy_json`, `managed_policy_arns`, `max_session_duration` (default 3600) and `subject_prefix`.

### Repositories with immutable subject claims

Newer GitHub repositories issue tokens whose subject contains the owner and repository IDs, for example `repo:my-org@123456/my-repo@789012:environment:prod`. A role that trusts `repo:my-org/my-repo:...` then fails with "Not authorized to perform sts:AssumeRoleWithWebIdentity". Check what your repository uses:

```
gh api repos/<owner>/<repo>/actions/oidc/customization/sub
```

If `use_immutable_subject` is `true`, set `subject_prefix` to the returned `sub_claim_prefix`:

```hcl
roles = {
  infra-dev = {
    github_repo    = "my-org/my-repo"
    subject_prefix = "repo:my-org@123456/my-repo@789012"
    environment    = "dev"
  }
}
```

## Outputs

`provider_arn`, `role_arns`, `role_names`, `subjects`.

## Cost

Free. IAM roles and the identity provider have no charge.
