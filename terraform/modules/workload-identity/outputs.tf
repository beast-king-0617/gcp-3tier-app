output "pool_name" {
  description = "Full resource name of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.github.name
}

output "pool_id" {
  description = "Workload Identity Pool ID."
  value       = google_iam_workload_identity_pool.github.workload_identity_pool_id
}

output "provider_name" {
  description = "Full resource name of the Workload Identity Provider (use as workload_identity_provider in GitHub Actions)."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "provider_id" {
  description = "Workload Identity Provider ID."
  value       = google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id
}
