output "cluster_name" {
  description = "GKE cluster name."
  value       = google_container_cluster.this.name
}

output "cluster_id" {
  description = "GKE cluster ID."
  value       = google_container_cluster.this.id
}

output "cluster_endpoint" {
  description = "GKE API endpoint."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (base64)."
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "location" {
  description = "Cluster location (region)."
  value       = google_container_cluster.this.location
}

output "workload_identity_pool" {
  description = "Workload Identity pool."
  value       = "${var.project_id}.svc.id.goog"
}

output "node_service_account_email" {
  description = "GKE node service account email."
  value       = google_service_account.nodes.email
}

output "system_node_pool_name" {
  description = "System node pool name."
  value       = google_container_node_pool.system.name
}

output "application_node_pool_name" {
  description = "Application node pool name."
  value       = google_container_node_pool.application.name
}

output "get_credentials_command" {
  description = "Command to fetch kubeconfig."
  value       = "gcloud container clusters get-credentials ${google_container_cluster.this.name} --region ${google_container_cluster.this.location} --project ${var.project_id}"
}
