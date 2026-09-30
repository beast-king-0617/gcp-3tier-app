module "project_services" {
  source = "../../modules/project-services"

  project_id = var.project_id
  services   = local.network_services
}

module "network" {
  source = "../../modules/network"

  project_id  = var.project_id
  name_prefix = local.name_prefix
  region      = var.region
  labels      = local.labels

  subnets = {
    gke = {
      ip_cidr_range = var.subnet_gke_cidr
      secondary_ranges = {
        pods     = var.subnet_gke_pods_cidr
        services = var.subnet_gke_services_cidr
      }
      flow_logs          = var.enable_flow_logs
      flow_logs_sampling = var.flow_logs_sampling
    }
    mgmt = {
      ip_cidr_range      = var.subnet_mgmt_cidr
      secondary_ranges   = {}
      flow_logs          = var.enable_flow_logs
      flow_logs_sampling = var.flow_logs_sampling
    }
  }

  depends_on = [module.project_services]
}

module "nat" {
  source = "../../modules/nat"

  project_id  = var.project_id
  name_prefix = local.name_prefix
  region      = var.region
  network     = module.network.network_self_link
}

module "private_service_access" {
  source = "../../modules/private-service-access"

  project_id    = var.project_id
  name_prefix   = local.name_prefix
  network       = module.network.network_id
  address       = var.psa_address
  prefix_length = var.psa_prefix_length

  depends_on = [module.project_services]
}

module "firewall" {
  source = "../../modules/firewall"

  project_id             = var.project_id
  name_prefix            = local.name_prefix
  network                = module.network.network_self_link
  internal_source_ranges = local.internal_source_ranges
  gke_master_cidr        = var.gke_master_cidr
  enable_iap_ssh         = var.enable_iap_ssh
}

module "gke" {
  source = "../../modules/gke"

  project_id                        = var.project_id
  name_prefix                       = local.name_prefix
  region                            = var.region
  network                           = module.network.network_self_link
  subnetwork                        = module.network.subnet_self_links["gke"]
  pods_range_name                   = module.network.gke_pods_range_name
  services_range_name               = module.network.gke_services_range_name
  master_ipv4_cidr_block            = var.gke_master_cidr
  node_network_tags                 = [module.firewall.gke_node_tag]
  release_channel                   = var.gke_release_channel
  enable_private_endpoint           = var.gke_enable_private_endpoint
  enable_master_authorized_networks = var.gke_enable_master_authorized_networks
  master_authorized_networks        = var.gke_master_authorized_networks
  deletion_protection               = var.gke_deletion_protection
  system_node_pool                  = var.gke_system_node_pool
  application_node_pool             = var.gke_application_node_pool
  maintenance_start_time            = var.gke_maintenance_start_time
  maintenance_end_time              = var.gke_maintenance_end_time
  maintenance_recurrence            = var.gke_maintenance_recurrence
  labels                            = local.labels

  depends_on = [
    module.nat,
    module.firewall,
    module.project_services,
  ]
}

module "cloud_sql" {
  source = "../../modules/cloud-sql"

  project_id                     = var.project_id
  name_prefix                    = local.name_prefix
  region                         = var.region
  network_id                     = module.network.network_id
  database_version               = var.cloudsql_database_version
  tier                           = var.cloudsql_tier
  availability_type              = var.cloudsql_availability_type
  disk_size_gb                   = var.cloudsql_disk_size_gb
  disk_autoresize_limit          = var.cloudsql_disk_autoresize_limit
  deletion_protection            = var.cloudsql_deletion_protection
  database_name                  = var.cloudsql_database_name
  database_user                  = var.cloudsql_database_user
  backup_start_time              = var.cloudsql_backup_start_time
  maintenance_day                = var.cloudsql_maintenance_day
  maintenance_hour               = var.cloudsql_maintenance_hour
  retained_backups               = var.cloudsql_retained_backups
  transaction_log_retention_days = var.cloudsql_pitr_days
  labels                         = local.labels

  depends_on = [
    module.private_service_access,
    module.project_services,
  ]
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project_id  = var.project_id
  location    = var.region
  name_prefix = local.name_prefix
  labels      = local.labels

  repositories                  = var.artifact_registry_repositories
  keep_version_count            = var.artifact_registry_keep_versions
  enable_cleanup_policy         = var.artifact_registry_cleanup_enabled
  enable_vulnerability_scanning = var.artifact_registry_vuln_scanning

  # Repo-scoped IAM (defense in depth beyond project-level bootstrap roles).
  writer_members = [
    "serviceAccount:gha-ci@${var.project_id}.iam.gserviceaccount.com",
  ]
  reader_members = [
    "serviceAccount:${module.gke.node_service_account_email}",
  ]

  depends_on = [module.project_services]
}

module "dns" {
  count  = var.enable_gateway_edge ? 1 : 0
  source = "../../modules/dns"

  project_id         = var.project_id
  name_prefix        = local.name_prefix
  dns_domain         = var.dns_domain
  create_zone        = var.dns_create_zone
  existing_zone_name = var.dns_existing_zone_name
  labels             = local.labels

  depends_on = [module.project_services]
}

module "certificates" {
  count  = var.enable_gateway_edge ? 1 : 0
  source = "../../modules/certificates"

  project_id    = var.project_id
  name_prefix   = local.name_prefix
  hostname      = local.app_hostname
  dns_zone_name = module.dns[0].zone_name
  labels        = local.labels

  depends_on = [module.dns]
}

module "argocd" {
  count  = var.enable_argocd ? 1 : 0
  source = "../../modules/argocd"

  project_id            = var.project_id
  name_prefix           = local.name_prefix
  environment           = var.environment
  chart_version         = var.argocd_chart_version
  git_repo_url          = var.argocd_git_repo_url
  git_target_revision   = var.argocd_git_target_revision
  bootstrap_application = true

  depends_on = [module.gke]
}

module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../modules/monitoring"

  project_id           = var.project_id
  name_prefix          = local.name_prefix
  environment          = var.environment
  notification_emails  = var.monitoring_notification_emails
  gke_cluster_name     = module.gke.cluster_name
  cloudsql_instance_id = module.cloud_sql.instance_name
  enable_dashboard     = var.monitoring_enable_dashboard
  labels               = local.labels

  depends_on = [
    module.gke,
    module.cloud_sql,
  ]
}

module "app_identity" {
  source = "../../modules/app-identity"

  project_id  = var.project_id
  name_prefix = local.name_prefix
  secret_ids = [
    module.cloud_sql.password_secret_id,
    module.cloud_sql.connection_secret_id,
  ]

  depends_on = [module.gke, module.cloud_sql]
}

module "external_secrets" {
  count  = var.enable_external_secrets ? 1 : 0
  source = "../../modules/external-secrets"

  project_id  = var.project_id
  name_prefix = local.name_prefix
  secret_ids = [
    module.cloud_sql.password_secret_id,
    module.cloud_sql.connection_secret_id,
  ]

  depends_on = [module.gke, module.cloud_sql, module.app_identity]
}
