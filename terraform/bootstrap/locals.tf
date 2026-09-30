locals {
  labels = merge(
    {
      app         = var.app_name
      managed-by  = "terraform"
      component   = "bootstrap"
      environment = "shared"
    },
    var.labels,
  )

  # APIs required on the shared project for state + WIF + IAM automation.
  shared_project_services = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
    "cloudkms.googleapis.com",
  ]

  # Baseline APIs for environment projects (expanded in later phases as modules need them).
  environment_project_services = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudkms.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "dns.googleapis.com",
    "sts.googleapis.com",
  ]

  # Least-privilege-ish roles for terraform plan (read + state locking).
  # roles/viewer is intentionally used: plan must read most resource types.
  # Documented alternative later: custom role per module surface.
  tf_planner_roles = [
    "roles/viewer",
    "roles/iam.securityReviewer",
  ]

  # Apply roles — scoped to project, not org Owner/Editor.
  # roles/resourcemanager.projectIamAdmin is required for Terraform to manage IAM
  # bindings on the project; restrict who can impersonate tf-applier via WIF + GitHub env protection.
  tf_applier_roles = [
    "roles/viewer",
    "roles/iam.securityReviewer",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/compute.admin",
    "roles/container.admin",
    "roles/artifactregistry.admin",
    "roles/cloudsql.admin",
    "roles/secretmanager.admin",
    "roles/servicenetworking.networksAdmin",
    "roles/dns.admin",
    "roles/monitoring.editor",
    "roles/logging.configWriter",
    "roles/storage.admin",
    "roles/cloudkms.admin",
  ]

  # CI push images only — no infra mutation.
  gha_ci_roles = [
    "roles/artifactregistry.writer",
    "roles/artifactregistry.reader",
  ]

  # Flatten SA → role bindings for for_each.
  tf_planner_role_bindings = {
    for item in flatten([
      for env_key, env in var.environments : [
        for role in local.tf_planner_roles : {
          key        = "${env_key}|tf-planner|${role}"
          env_key    = env_key
          project_id = env.project_id
          role       = role
          sa_key     = "planner"
        }
      ]
    ]) : item.key => item
  }

  tf_applier_role_bindings = {
    for item in flatten([
      for env_key, env in var.environments : [
        for role in local.tf_applier_roles : {
          key        = "${env_key}|tf-applier|${role}"
          env_key    = env_key
          project_id = env.project_id
          role       = role
          sa_key     = "applier"
        }
      ]
    ]) : item.key => item
  }

  gha_ci_role_bindings = {
    for item in flatten([
      for env_key, env in var.environments : [
        for role in local.gha_ci_roles : {
          key        = "${env_key}|gha-ci|${role}"
          env_key    = env_key
          project_id = env.project_id
          role       = role
          sa_key     = "ci"
        }
      ]
    ]) : item.key => item
  }

  wif_service_account_bindings = merge(
    {
      for env_key, env in var.environments :
      "tf-planner-${env_key}" => {
        service_account_email = google_service_account.tf_planner[env_key].email
        repository            = var.github_terraform_repo
      }
    },
    {
      for env_key, env in var.environments :
      "tf-applier-${env_key}" => {
        service_account_email = google_service_account.tf_applier[env_key].email
        repository            = var.github_terraform_repo
      }
    },
    {
      for env_key, env in var.environments :
      "gha-ci-${env_key}" => {
        service_account_email = google_service_account.gha_ci[env_key].email
        repository            = var.github_application_repo
      }
    },
  )

  github_allowed_repositories = distinct([
    var.github_terraform_repo,
    var.github_application_repo,
    var.github_gitops_repo,
  ])
}
