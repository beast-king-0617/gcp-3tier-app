output "shared_project_id" {
  description = "Shared GCP project ID."
  value       = var.shared_project_id
}

output "state_bucket_name" {
  description = "GCS bucket for Terraform remote state. Use as backend bucket for environment stacks."
  value       = google_storage_bucket.tfstate.name
}

output "state_bucket_url" {
  description = "GCS URL of the Terraform state bucket."
  value       = google_storage_bucket.tfstate.url
}

output "workload_identity_provider" {
  description = "Full WIF provider resource name for google-github-actions/auth."
  value       = module.github_wif.provider_name
}

output "workload_identity_pool" {
  description = "Full WIF pool resource name."
  value       = module.github_wif.pool_name
}

output "service_accounts" {
  description = "Per-environment automation service account emails."
  value = {
    for env_key, _ in var.environments : env_key => {
      tf_planner = google_service_account.tf_planner[env_key].email
      tf_applier = google_service_account.tf_applier[env_key].email
      gha_ci     = google_service_account.gha_ci[env_key].email
    }
  }
}

output "github_actions_auth_examples" {
  description = "Copy/paste hints for GitHub Actions environment variables."
  value = {
    WORKLOAD_IDENTITY_PROVIDER = module.github_wif.provider_name
    # Example for dev plan:
    # SERVICE_ACCOUNT = output.service_accounts["dev"].tf_planner
  }
}

output "backend_config_snippets" {
  description = "Suggested GCS backend prefixes for each environment stack."
  value = {
    for env_key, _ in var.environments : env_key => {
      bucket = google_storage_bucket.tfstate.name
      prefix = "env/${env_key}"
    }
  }
}

output "iam_role_rationale" {
  description = "Documentation map of why bootstrap IAM roles exist."
  value = {
    tf_planner = {
      "roles/viewer"               = "Read resources required for terraform plan."
      "roles/iam.securityReviewer" = "Read IAM policies referenced by Terraform data sources."
      "roles/storage.objectAdmin"  = "Read/write Terraform state and lock files in the state bucket (bucket IAM)."
    }
    tf_applier = {
      "roles/resourcemanager.projectIamAdmin" = "Manage project IAM bindings declared in Terraform."
      "roles/iam.serviceAccountAdmin"         = "Create/manage runtime and CI service accounts."
      "roles/iam.serviceAccountUser"          = "Allow resources to act as service accounts where required."
      "roles/compute.admin"                   = "Manage VPC, NAT, firewall, addresses."
      "roles/container.admin"                 = "Manage GKE clusters and node pools."
      "roles/artifactregistry.admin"          = "Manage Artifact Registry repositories and IAM."
      "roles/cloudsql.admin"                  = "Manage Cloud SQL instances and users."
      "roles/secretmanager.admin"             = "Manage Secret Manager secrets used by the platform."
      "roles/servicenetworking.networksAdmin" = "Configure Private Service Access for Cloud SQL."
      "roles/dns.admin"                       = "Manage Cloud DNS zones/records for Gateway hostnames."
      "roles/monitoring.editor"               = "Create alerting policies and dashboards."
      "roles/logging.configWriter"            = "Configure log-based metrics/sinks."
      "roles/storage.admin"                   = "Manage buckets created by environment stacks if any."
      "roles/cloudkms.admin"                  = "Optional CMEK key rings/keys in later phases."
    }
    gha_ci = {
      "roles/artifactregistry.writer" = "Push container images from CI."
      "roles/artifactregistry.reader" = "Pull/cache base layers during build."
    }
  }
}
