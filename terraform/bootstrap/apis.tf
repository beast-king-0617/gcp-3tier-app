# ---------------------------------------------------------------------------
# Shared project API enablement
# ---------------------------------------------------------------------------

module "shared_project_services" {
  source = "../modules/project-services"

  project_id = var.shared_project_id
  services   = local.shared_project_services
}

# ---------------------------------------------------------------------------
# Environment project API enablement (baseline for later phases)
# ---------------------------------------------------------------------------

module "environment_project_services" {
  for_each = var.enable_apis_on_environment_projects ? var.environments : {}

  source = "../modules/project-services"

  project_id = each.value.project_id
  services   = local.environment_project_services

  depends_on = [module.shared_project_services]
}
