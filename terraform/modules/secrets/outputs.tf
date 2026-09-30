output "secret_ids" {
  description = "Map of logical key => secret_id."
  value       = { for k, v in google_secret_manager_secret.this : k => v.secret_id }
}

output "secret_names" {
  description = "Map of logical key => full resource name."
  value       = { for k, v in google_secret_manager_secret.this : k => v.name }
}

output "secret_version_names" {
  description = "Map of logical key => secret version name."
  value       = { for k, v in google_secret_manager_secret_version.this : k => v.name }
  sensitive   = true
}
