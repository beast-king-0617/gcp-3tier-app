locals {
  instance_name        = "${var.name_prefix}-pg"
  password_secret_id   = "${var.name_prefix}-db-password"
  connection_secret_id = "${var.name_prefix}-db-connection"
}

resource "random_password" "db" {
  length           = var.password_length
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 2
  min_upper        = 2
  min_numeric      = 2
  min_special      = 2
}

resource "google_sql_database_instance" "this" {
  name                = local.instance_name
  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection

  settings {
    tier                        = var.tier
    edition                     = var.edition
    availability_type           = var.availability_type
    disk_size                   = var.disk_size_gb
    disk_type                   = var.disk_type
    disk_autoresize             = var.disk_autoresize
    disk_autoresize_limit       = var.disk_autoresize_limit
    user_labels                 = var.labels
    deletion_protection_enabled = var.deletion_protection

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
      ssl_mode                                      = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
      transaction_log_retention_days = var.transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.retained_backups
        retention_unit   = "COUNT"
      }
    }

    maintenance_window {
      day          = var.maintenance_day
      hour         = var.maintenance_hour
      update_track = "stable"
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    insights_config {
      query_insights_enabled  = var.query_insights_enabled
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = false
    }
  }

  # PSA peering must exist before private IP assignment.
  lifecycle {
    ignore_changes = [
      # Avoid noisy diffs if Google adjusts storage after autoresize.
      settings[0].disk_size,
    ]
  }
}

resource "google_sql_database" "app" {
  name     = var.database_name
  project  = var.project_id
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "app" {
  name     = var.database_user
  project  = var.project_id
  instance = google_sql_database_instance.this.name
  password = random_password.db.result
}

module "credentials" {
  source = "../secrets"

  project_id = var.project_id

  secrets = {
    (local.password_secret_id) = {
      secret_data = random_password.db.result
      labels = merge(var.labels, {
        purpose = "cloudsql-password"
      })
    }
    (local.connection_secret_id) = {
      secret_data = jsonencode({
        host     = google_sql_database_instance.this.private_ip_address
        port     = 5432
        database = var.database_name
        user     = var.database_user
        password = random_password.db.result
        sslmode  = "require"
        instance = google_sql_database_instance.this.connection_name
      })
      labels = merge(var.labels, {
        purpose = "cloudsql-connection"
      })
    }
  }

  depends_on = [
    google_sql_database_instance.this,
    google_sql_user.app,
  ]
}
