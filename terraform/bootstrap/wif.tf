# ---------------------------------------------------------------------------
# GitHub OIDC → GCP Workload Identity Federation
# ---------------------------------------------------------------------------

module "github_wif" {
  source = "../modules/workload-identity"

  project_id           = var.shared_project_id
  pool_id              = "github-actions"
  provider_id          = "github"
  github_organization  = var.github_organization
  allowed_repositories = local.github_allowed_repositories

  service_account_bindings = local.wif_service_account_bindings

  depends_on = [
    module.shared_project_services,
    google_service_account.tf_planner,
    google_service_account.tf_applier,
    google_service_account.gha_ci,
  ]
}
