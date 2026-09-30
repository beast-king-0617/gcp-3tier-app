# ---------------------------------------------------------------------------
# Project IAM bindings for automation service accounts
# ---------------------------------------------------------------------------

resource "google_project_iam_member" "tf_planner" {
  for_each = local.tf_planner_role_bindings

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.tf_planner[each.value.env_key].email}"
}

resource "google_project_iam_member" "tf_applier" {
  for_each = local.tf_applier_role_bindings

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.tf_applier[each.value.env_key].email}"
}

resource "google_project_iam_member" "gha_ci" {
  for_each = local.gha_ci_role_bindings

  project = each.value.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.gha_ci[each.value.env_key].email}"
}
