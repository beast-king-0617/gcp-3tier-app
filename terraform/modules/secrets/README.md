# Secrets Module

Creates Google Secret Manager secrets and optional versions.

## Usage

```hcl
module "db_password" {
  source = "../../modules/secrets"

  project_id = var.project_id
  secrets = {
    "myapp-dev-db-password" = {
      secret_data = random_password.db.result
      labels      = { app = "myapp" }
    }
  }
}
```

Passwords must never be stored in tfvars, Git, or Kubernetes YAML committed to Git.
