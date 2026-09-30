output "project_id" {
  description = "Environment project ID."
  value       = var.project_id
}

output "environment" {
  description = "Environment name."
  value       = var.environment
}

output "network_name" {
  description = "VPC name."
  value       = module.network.network_name
}

output "network_id" {
  description = "VPC ID."
  value       = module.network.network_id
}

output "network_self_link" {
  description = "VPC self_link."
  value       = module.network.network_self_link
}

output "gke_subnet_name" {
  description = "GKE subnet name."
  value       = module.network.subnet_names["gke"]
}

output "gke_subnet_self_link" {
  description = "GKE subnet self_link."
  value       = module.network.subnet_self_links["gke"]
}

output "mgmt_subnet_name" {
  description = "Management subnet name."
  value       = module.network.subnet_names["mgmt"]
}

output "gke_pods_range_name" {
  description = "Secondary range name for pods (Phase 4 GKE)."
  value       = module.network.gke_pods_range_name
}

output "gke_services_range_name" {
  description = "Secondary range name for services (Phase 4 GKE)."
  value       = module.network.gke_services_range_name
}

output "nat_name" {
  description = "Cloud NAT name."
  value       = module.nat.nat_name
}

output "router_name" {
  description = "Cloud Router name."
  value       = module.nat.router_name
}

output "psa_allocated_range" {
  description = "PSA allocated CIDR for Cloud SQL."
  value       = module.private_service_access.allocated_ip_cidr
}

output "psa_range_name" {
  description = "PSA allocated range resource name."
  value       = module.private_service_access.allocated_range_name
}

output "gke_master_cidr" {
  description = "Reserved GKE master CIDR for Phase 4."
  value       = var.gke_master_cidr
}

output "gke_node_network_tag" {
  description = "Network tag Phase 4 node pools must use."
  value       = module.firewall.gke_node_tag
}

output "firewall_rules" {
  description = "Managed firewall rule names."
  value       = module.firewall.firewall_rule_names
}

output "firewall_documentation" {
  description = "Firewall rule documentation map."
  value       = module.firewall.rule_documentation
}

output "gke_cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.cluster_name
}

output "gke_cluster_location" {
  description = "GKE cluster region."
  value       = module.gke.location
}

output "gke_workload_identity_pool" {
  description = "Workload Identity pool for K8s service accounts."
  value       = module.gke.workload_identity_pool
}

output "gke_node_service_account" {
  description = "GKE node service account email."
  value       = module.gke.node_service_account_email
}

output "gke_system_node_pool" {
  description = "System node pool name."
  value       = module.gke.system_node_pool_name
}

output "gke_application_node_pool" {
  description = "Application node pool name."
  value       = module.gke.application_node_pool_name
}

output "gke_get_credentials_command" {
  description = "gcloud command to obtain kubeconfig."
  value       = module.gke.get_credentials_command
}

output "cloudsql_instance_name" {
  description = "Cloud SQL instance name."
  value       = module.cloud_sql.instance_name
}

output "cloudsql_connection_name" {
  description = "Cloud SQL connection name for Auth Proxy."
  value       = module.cloud_sql.instance_connection_name
}

output "cloudsql_private_ip" {
  description = "Cloud SQL private IP."
  value       = module.cloud_sql.private_ip_address
}

output "cloudsql_database_name" {
  description = "Application database name."
  value       = module.cloud_sql.database_name
}

output "cloudsql_database_user" {
  description = "Application database user."
  value       = module.cloud_sql.database_user
}

output "cloudsql_password_secret_id" {
  description = "Secret Manager secret_id for DB password (value never in Terraform outputs)."
  value       = module.cloud_sql.password_secret_id
}

output "cloudsql_connection_secret_id" {
  description = "Secret Manager secret_id for JSON connection blob."
  value       = module.cloud_sql.connection_secret_id
}

output "artifact_registry_urls" {
  description = "Docker repository base URLs for frontend/backend."
  value       = module.artifact_registry.repository_urls
}

output "artifact_registry_image_examples" {
  description = "Example image references (replace GIT_SHA)."
  value       = module.artifact_registry.image_url_examples
}

output "artifact_registry_location" {
  description = "Artifact Registry location."
  value       = module.artifact_registry.location
}

output "app_hostname" {
  description = "Public hostname for Gateway HTTPRoutes."
  value       = local.app_hostname
}

output "dns_name_servers" {
  description = "Delegate these NS records at your registrar when dns_create_zone=true."
  value       = try(module.dns[0].name_servers, [])
}

output "gateway_ip_name" {
  description = "Global address name for Gateway annotation networking.gke.io/addresses."
  value       = try(module.certificates[0].gateway_ip_name, null)
}

output "gateway_ip_address" {
  description = "Reserved Gateway IPv4 address."
  value       = try(module.certificates[0].gateway_ip_address, null)
}

output "certificate_map_name" {
  description = "Certificate map name for Gateway annotation networking.gke.io/certmap."
  value       = try(module.certificates[0].certificate_map_name, null)
}

output "gateway_gitops_patch_hints" {
  description = "Values to place into gitops/environments/<env>/kustomization.yaml patches."
  value = var.enable_gateway_edge ? {
    addresses_annotation = module.certificates[0].gateway_ip_name
    certmap_annotation   = module.certificates[0].certificate_map_name
    hostname             = local.app_hostname
  } : null
}

output "argocd_namespace" {
  value = try(module.argocd[0].namespace, null)
}

output "argocd_application_name" {
  value = try(module.argocd[0].application_name, null)
}

output "argocd_access_hint" {
  value = try(module.argocd[0].access_hint, null)
}

output "monitoring_alert_policies" {
  value = try(module.monitoring[0].alert_policy_names, [])
}

output "monitoring_dashboard_id" {
  value = try(module.monitoring[0].dashboard_id, null)
}

output "gke_backend_service_account" {
  value = module.app_identity.backend_service_account_email
}

output "gke_frontend_service_account" {
  value = module.app_identity.frontend_service_account_email
}

output "external_secrets_store" {
  value = try(module.external_secrets[0].cluster_secret_store_name, null)
}
