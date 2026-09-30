# ---------------------------------------------------------------------------
# Per-environment automation service accounts
#
# Naming (account_id max 30 chars):
#   tf-planner  — terraform plan from PRs
#   tf-applier  — terraform apply from protected workflows
#   gha-ci      — build/push container images
# ---------------------------------------------------------------------------

resource "google_service_account" "tf_planner" {
  for_each = var.environments

  project      = each.value.project_id
  account_id   = "tf-planner"
  display_name = "Terraform Planner (${each.key})"
  description  = "Least-privilege SA for terraform plan via GitHub Actions WIF"

  depends_on = [module.environment_project_services]
}

resource "google_service_account" "tf_applier" {
  for_each = var.environments

  project      = each.value.project_id
  account_id   = "tf-applier"
  display_name = "Terraform Applier (${each.key})"
  description  = "SA for terraform apply via GitHub Actions WIF (protected environments)"

  depends_on = [module.environment_project_services]
}

resource "google_service_account" "gha_ci" {
  for_each = var.environments

  project      = each.value.project_id
  account_id   = "gha-ci"
  display_name = "GitHub Actions CI (${each.key})"
  description  = "SA for container build/push to Artifact Registry via WIF"

  depends_on = [module.environment_project_services]
}
