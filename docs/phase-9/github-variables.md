# CI/CD variables checklist

Copy values from Terraform bootstrap / environment outputs after apply.

```bash
# From bootstrap
terraform -chdir=terraform/bootstrap output -raw workload_identity_provider

# From env
terraform -chdir=terraform/environments/dev output -json service_accounts  # if exposed
# Or known emails:
# gha-ci@PROJECT.iam.gserviceaccount.com
# tf-planner@PROJECT.iam.gserviceaccount.com
# tf-applier@PROJECT.iam.gserviceaccount.com

terraform -chdir=terraform/environments/dev output -json artifact_registry_urls
```

No SA JSON keys are stored in GitHub Secrets.
