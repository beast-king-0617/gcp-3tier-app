# Terraform Guide

## Layout

```text
terraform/
├── bootstrap/     # Phase 2 — state, WIF, automation SAs (apply first)
├── modules/       # Reusable modules
└── environments/  # Phase 3+ per-env stacks (dev/stage/prod)
```

## Remote state

| Stack | Backend bucket | Prefix |
|-------|----------------|--------|
| bootstrap | `var.state_bucket_name` in shared project | `bootstrap` |
| env/dev | same bucket | `env/dev` |
| env/stage | same bucket | `env/stage` |
| env/prod | same bucket | `env/prod` |

### Bootstrap problem

The state bucket cannot live in remote state until it exists. Bootstrap therefore:

1. Applies with **local** state
2. Creates the bucket
3. Migrates state into GCS (`terraform init -migrate-state`)

Environment stacks never have this problem — they start with the GCS backend.

## Provider / version pins

- Terraform `>= 1.7.0` (local floor); CI should install **1.9.x** via `hashicorp/setup-terraform`
- Pin file `terraform/.terraform-version` tracks the local tfenv version used for development
- `hashicorp/google` `~> 6.0`
- `hashicorp/google-beta` `~> 6.0` (bootstrap; used more in GKE/Gateway phases)

Commit `terraform/bootstrap/.terraform.lock.hcl` so provider versions stay reproducible.

## Modules (Phase 2)

| Module | Purpose |
|--------|---------|
| `project-services` | Enable GCP APIs with `for_each` |
| `workload-identity` | GitHub OIDC pool/provider + SA impersonation bindings |

## Authentication

| Actor | Method |
|-------|--------|
| Human bootstrap | `gcloud auth application-default login` |
| GitHub Actions (later) | OIDC → WIF → `tf-planner` / `tf-applier` / `gha-ci` |

## Applying bootstrap

See [terraform/bootstrap/README.md](../terraform/bootstrap/README.md).

## Applying networking (Phase 3)

See [terraform/environments/dev/README.md](../terraform/environments/dev/README.md) and [docs/phase-3/networking-impl.md](./phase-3/networking-impl.md).

```bash
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

## IAM (no Owner/Editor for automation)

Automation uses service-scoped roles. The broadest apply role is `roles/resourcemanager.projectIamAdmin` on **tf-applier** so Terraform can manage IAM members — still far narrower than `roles/owner`. Protect impersonation with:

- WIF repository conditions
- GitHub Environment required reviewers for prod apply

## Outputs consumed later

| Output | Consumer |
|--------|----------|
| `state_bucket_name` | `environments/*/backend.tf` |
| `workload_identity_provider` | GitHub Actions `google-github-actions/auth` |
| `service_accounts` | GitHub Actions `service_account` input |
