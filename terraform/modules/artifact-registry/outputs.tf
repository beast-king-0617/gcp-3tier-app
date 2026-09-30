output "repository_ids" {
  description = "Map of short name => repository_id."
  value       = { for k, v in google_artifact_registry_repository.this : k => v.repository_id }
}

output "repository_names" {
  description = "Map of short name => full repository resource name."
  value       = { for k, v in google_artifact_registry_repository.this : k => v.name }
}

output "repository_urls" {
  description = "Map of short name => docker push/pull base URL (without image name)."
  value = {
    for k, v in google_artifact_registry_repository.this :
    k => "${var.location}-docker.pkg.dev/${var.project_id}/${v.repository_id}"
  }
}

output "location" {
  description = "Artifact Registry location."
  value       = var.location
}

output "image_url_examples" {
  description = "Example image references using git SHA tags."
  value = {
    for k, url in {
      for k, v in google_artifact_registry_repository.this :
      k => "${var.location}-docker.pkg.dev/${var.project_id}/${v.repository_id}"
    } : k => "${url}/${k}:GIT_SHA"
  }
}
