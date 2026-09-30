terraform {
  # CI should use Terraform 1.9.x (see .terraform-version). Local floor is 1.7+ for compatibility.
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
  }

  # ---------------------------------------------------------------------------
  # BOOTSTRAP BACKEND STRATEGY
  #
  # Step 1: Leave this block commented (local state) and run the first apply.
  # Step 2: After the GCS bucket exists, uncomment the backend block below,
  #         copy values from terraform output / tfvars, then:
  #           terraform init -migrate-state
  #
  # See README.md — "The bootstrap problem".
  # ---------------------------------------------------------------------------
  #
  # backend "gcs" {
  #   bucket = "myapp-shared-tfstate"
  #   prefix = "bootstrap"
  # }
}
