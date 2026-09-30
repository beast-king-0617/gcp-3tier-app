output "enabled_services" {
  description = "Map of service name => project service resource ID."
  value = {
    for k, v in google_project_service.this : k => v.id
  }
}

output "services" {
  description = "List of enabled API service names."
  value       = sort(keys(google_project_service.this))
}
