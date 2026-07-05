---
name: project-portfolio-site-terraform
description: Structure and known gaps in the portfolio-site Terraform config (S3+CloudFront) as of the Assignment 3 generated infra
metadata:
  type: project
---

The Terraform in `terraform/` (main.tf, providers.tf, variables.tf, outputs.tf, backend.tf) only
defines an S3 origin bucket + CloudFront distribution with OAC. It does **not** define any
`aws_iam_openid_connect_provider` / `aws_iam_role` / trust policy, even though
`.github/workflows/deploy.yml` assumes a role via OIDC
(`arn:aws:iam::533267262133:role/github-actions-deploy`) to deploy. That IAM role and its trust
policy exist purely out-of-band (created manually or elsewhere), which contradicts the repo's own
CLAUDE.md rule "All infrastructure changes go through Terraform — never modify AWS resources
manually."

**Why:** Means the OIDC trust policy scoping (repo/branch restriction) and the role's permission
policy can't be audited from code — a recurring gap worth checking first in any future review of
this repo.

**How to apply:** In future security/infra reviews of this repo, always check
`.github/workflows/*.yml` for hardcoded role ARNs/account IDs/bucket names/distribution IDs in
addition to `terraform/*.tf`, since credentials and resource identifiers here are split across
both. Also note: `variables.tf` defaults `region = "ap-south-1"` and bucket name would resolve to
`portfolio-site-production`, but the live workflow deploys to `eu-north-1` / bucket
`pravinmishradmi-site-production` / distribution `E3V6O6MRE2E21P` — the checked-in Terraform does
not describe the actually-deployed resources (likely boilerplate for forks per the DMI training
exercise, not the live infra). Flag this drift whenever asked to reconcile or apply this Terraform.

Backend is intentionally left commented out in `backend.tf` (bootstrap pattern: apply once with
local state to create the state bucket, then migrate). `.gitignore` correctly excludes
`terraform/*.tfstate*` and `.terraform/`, so no state leakage found in-repo.
