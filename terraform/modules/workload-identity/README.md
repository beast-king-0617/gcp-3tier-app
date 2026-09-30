# GitHub Workload Identity Federation Module

Creates a Workload Identity Pool and GitHub OIDC provider, and binds repository principals to Google service accounts.

## Usage

```hcl
module "github_wif" {
  source = "../../modules/workload-identity"

  project_id          = var.shared_project_id
  github_organization = "my-org"
  allowed_repositories = [
    "my-org/myapp-terraform",
    "my-org/myapp-application",
  ]

  service_account_bindings = {
    "tf-planner-dev" = {
      service_account_email = "tf-planner@myapp-dev.iam.gserviceaccount.com"
      repository            = "my-org/myapp-terraform"
    }
  }
}
```

## Outputs

| Name | Use |
|------|-----|
| `provider_name` | `workload_identity_provider` input to `google-github-actions/auth` |
| `pool_name` | Auditing / IAM references |

## Security notes

- Provider attribute condition restricts tokens to the configured GitHub organization (and optional repo allow-list).
- SA impersonation is further scoped per repository via `principalSet` on `attribute.repository`.
- Never store SA JSON keys in GitHub.
