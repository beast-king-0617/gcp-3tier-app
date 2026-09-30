variable "project_id" {
  description = "Environment GCP project ID."
  type        = string
}

variable "region" {
  description = "Primary region."
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "Application short name."
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name (dev|stage|prod)."
  type        = string
}

variable "subnet_gke_cidr" {
  description = "Primary CIDR for GKE nodes subnet."
  type        = string
}

variable "subnet_gke_pods_cidr" {
  description = "Secondary CIDR for GKE pods."
  type        = string
}

variable "subnet_gke_services_cidr" {
  description = "Secondary CIDR for GKE services."
  type        = string
}

variable "subnet_mgmt_cidr" {
  description = "CIDR for management subnet."
  type        = string
}

variable "psa_address" {
  description = "Base address for Private Service Access allocated range."
  type        = string
}

variable "psa_prefix_length" {
  description = "Prefix length for PSA range."
  type        = number
  default     = 24
}

variable "gke_master_cidr" {
  description = "GKE private control-plane CIDR (/28). Used for firewall; cluster created in Phase 4."
  type        = string
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs on subnets."
  type        = bool
  default     = true
}

variable "flow_logs_sampling" {
  description = "Flow log sampling rate (0.0-1.0). Lower in prod if cost-sensitive."
  type        = number
  default     = 0.5
}

variable "enable_iap_ssh" {
  description = "Create IAP SSH firewall rule."
  type        = bool
  default     = true
}

variable "labels" {
  description = "Extra resource labels."
  type        = map(string)
  default     = {}
}

# ---------------------------------------------------------------------------
# GKE
# ---------------------------------------------------------------------------

variable "gke_release_channel" {
  description = "GKE release channel."
  type        = string
  default     = "REGULAR"
}

variable "gke_enable_private_endpoint" {
  description = "If true, master has no public endpoint."
  type        = bool
  default     = false
}

variable "gke_enable_master_authorized_networks" {
  description = "Restrict public master access by CIDR."
  type        = bool
  default     = true
}

variable "gke_master_authorized_networks" {
  description = "CIDRs allowed to reach the GKE public control-plane endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "gke_deletion_protection" {
  description = "Prevent accidental cluster deletion."
  type        = bool
  default     = false
}

variable "gke_system_node_pool" {
  description = "System node pool sizing."
  type = object({
    machine_type      = string
    min_count         = number
    max_count         = number
    disk_size_gb      = optional(number, 50)
    disk_type         = optional(string, "pd-balanced")
    spot              = optional(bool, false)
    max_pods_per_node = optional(number, 64)
  })
}

variable "gke_application_node_pool" {
  description = "Application node pool sizing."
  type = object({
    machine_type      = string
    min_count         = number
    max_count         = number
    disk_size_gb      = optional(number, 100)
    disk_type         = optional(string, "pd-balanced")
    spot              = optional(bool, false)
    max_pods_per_node = optional(number, 64)
  })
}

variable "gke_maintenance_start_time" {
  description = "Maintenance window start (RFC3339 UTC)."
  type        = string
  default     = "2025-01-05T05:00:00Z"
}

variable "gke_maintenance_end_time" {
  description = "Maintenance window end (RFC3339 UTC)."
  type        = string
  default     = "2025-01-05T09:00:00Z"
}

variable "gke_maintenance_recurrence" {
  description = "Maintenance RRULE."
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=SU"
}

# ---------------------------------------------------------------------------
# Cloud SQL
# ---------------------------------------------------------------------------

variable "cloudsql_tier" {
  description = "Cloud SQL machine tier."
  type        = string
}

variable "cloudsql_availability_type" {
  description = "ZONAL or REGIONAL."
  type        = string
  default     = "ZONAL"
}

variable "cloudsql_disk_size_gb" {
  description = "Initial Cloud SQL disk size GB."
  type        = number
  default     = 20
}

variable "cloudsql_disk_autoresize_limit" {
  description = "Max autoresize disk GB (0 = unlimited)."
  type        = number
  default     = 0
}

variable "cloudsql_deletion_protection" {
  description = "Prevent Cloud SQL instance deletion."
  type        = bool
  default     = true
}

variable "cloudsql_database_version" {
  description = "Cloud SQL Postgres version."
  type        = string
  default     = "POSTGRES_15"
}

variable "cloudsql_database_name" {
  description = "Application database name."
  type        = string
  default     = "myapp"
}

variable "cloudsql_database_user" {
  description = "Application database user."
  type        = string
  default     = "myapp"
}

variable "cloudsql_backup_start_time" {
  description = "Backup window start HH:MM UTC."
  type        = string
  default     = "03:00"
}

variable "cloudsql_maintenance_day" {
  description = "Maintenance day (1=Mon ... 7=Sun)."
  type        = number
  default     = 7
}

variable "cloudsql_maintenance_hour" {
  description = "Maintenance hour UTC."
  type        = number
  default     = 5
}

variable "cloudsql_retained_backups" {
  description = "Number of retained automated backups."
  type        = number
  default     = 7
}

variable "cloudsql_pitr_days" {
  description = "Transaction log retention days for PITR."
  type        = number
  default     = 7
}

# ---------------------------------------------------------------------------
# Artifact Registry
# ---------------------------------------------------------------------------

variable "artifact_registry_repositories" {
  description = "Map of short name => Artifact Registry repository config."
  type = map(object({
    description    = optional(string, "")
    immutable_tags = optional(bool, false)
  }))
  default = {
    frontend = { description = "Frontend (React/NGINX) images" }
    backend  = { description = "Backend (Go API) images" }
  }
}

variable "artifact_registry_keep_versions" {
  description = "Cleanup policy: keep N most recent versions per repo."
  type        = number
  default     = 20
}

variable "artifact_registry_cleanup_enabled" {
  description = "Enable Artifact Registry cleanup policies."
  type        = bool
  default     = true
}

variable "artifact_registry_vuln_scanning" {
  description = "Enable vulnerability scanning config on repositories."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# DNS / TLS (Gateway edge)
# ---------------------------------------------------------------------------

variable "dns_domain" {
  description = "Base public DNS domain (e.g. myapp.example.com)."
  type        = string
}

variable "app_hostname" {
  description = "FQDN for this environment. Null => env.dns_domain (or dns_domain for prod)."
  type        = string
  default     = null
}

variable "dns_create_zone" {
  description = "Create Cloud DNS public zone for dns_domain in this project."
  type        = bool
  default     = true
}

variable "dns_existing_zone_name" {
  description = "Existing zone name when dns_create_zone=false."
  type        = string
  default     = null
}

variable "enable_gateway_edge" {
  description = "Provision static IP, Certificate Manager, and DNS records for Gateway."
  type        = bool
  default     = true
}

# ---------------------------------------------------------------------------
# Argo CD
# ---------------------------------------------------------------------------

variable "enable_argocd" {
  description = "Install Argo CD via Helm and bootstrap the environment Application."
  type        = bool
  default     = false
}

variable "argocd_git_repo_url" {
  description = "Git repo URL for Argo CD to sync (must contain gitops/)."
  type        = string
  default     = ""
}

variable "argocd_git_target_revision" {
  description = "Git revision tracked by Argo CD."
  type        = string
  default     = "develop"
}

variable "argocd_chart_version" {
  description = "argo-cd Helm chart version."
  type        = string
  default     = "7.7.16"
}

# ---------------------------------------------------------------------------
# Monitoring
# ---------------------------------------------------------------------------

variable "enable_monitoring" {
  description = "Create Cloud Monitoring alerts and dashboard."
  type        = bool
  default     = true
}

variable "monitoring_notification_emails" {
  description = "Email addresses for alert notifications."
  type        = list(string)
  default     = []
}

variable "monitoring_enable_dashboard" {
  description = "Create an overview Cloud Monitoring dashboard."
  type        = bool
  default     = true
}

variable "enable_external_secrets" {
  description = "Install External Secrets Operator and ClusterSecretStore."
  type        = bool
  default     = false
}
