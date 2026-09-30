output "instance_name" {
  description = "Cloud SQL instance name."
  value       = google_sql_database_instance.this.name
}

output "instance_connection_name" {
  description = "Connection name (project:region:instance) for Auth Proxy / connectors."
  value       = google_sql_database_instance.this.connection_name
}

output "private_ip_address" {
  description = "Private IP of the instance."
  value       = google_sql_database_instance.this.private_ip_address
}

output "database_name" {
  description = "Application database name."
  value       = google_sql_database.app.name
}

output "database_user" {
  description = "Application database user."
  value       = google_sql_user.app.name
}

output "password_secret_id" {
  description = "Secret Manager secret_id for the DB password."
  value       = local.password_secret_id
}

output "connection_secret_id" {
  description = "Secret Manager secret_id for the JSON connection payload."
  value       = local.connection_secret_id
}

output "password_secret_name" {
  description = "Full resource name of the password secret."
  value       = module.credentials.secret_names[local.password_secret_id]
}

output "connection_secret_name" {
  description = "Full resource name of the connection secret."
  value       = module.credentials.secret_names[local.connection_secret_id]
}

output "self_link" {
  description = "Instance self_link."
  value       = google_sql_database_instance.this.self_link
}
