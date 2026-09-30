locals {
  repos = {
    for key, cfg in var.repositories : key => {
      repository_id  = "${var.name_prefix}-${key}"
      description    = cfg.description != "" ? cfg.description : "Docker repository for ${key}"
      immutable_tags = cfg.immutable_tags
    }
  }

  writer_bindings = {
    for pair in setproduct(keys(local.repos), var.writer_members) :
    "${pair[0]}|${pair[1]}" => {
      repo_key = pair[0]
      member   = pair[1]
    }
  }

  reader_bindings = {
    for pair in setproduct(keys(local.repos), var.reader_members) :
    "${pair[0]}|${pair[1]}" => {
      repo_key = pair[0]
      member   = pair[1]
    }
  }
}

resource "google_artifact_registry_repository" "this" {
  for_each = local.repos

  project       = var.project_id
  location      = var.location
  repository_id = each.value.repository_id
  description   = each.value.description
  format        = "DOCKER"
  labels        = var.labels
  mode          = "STANDARD_REPOSITORY"

  docker_config {
    immutable_tags = each.value.immutable_tags
  }

  dynamic "cleanup_policies" {
    for_each = var.enable_cleanup_policy ? [1] : []
    content {
      id     = "keep-minimum-versions"
      action = "KEEP"
      most_recent_versions {
        keep_count = var.keep_version_count
      }
    }
  }

  dynamic "vulnerability_scanning_config" {
    for_each = var.enable_vulnerability_scanning ? [1] : []
    content {
      enablement_config = "INHERIT"
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "writers" {
  for_each = local.writer_bindings

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this[each.value.repo_key].name
  role       = "roles/artifactregistry.writer"
  member     = each.value.member
}

resource "google_artifact_registry_repository_iam_member" "readers" {
  for_each = local.reader_bindings

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this[each.value.repo_key].name
  role       = "roles/artifactregistry.reader"
  member     = each.value.member
}
