provider "google" {
  project = var.shared_project_id
  region  = var.region
}

provider "google-beta" {
  project = var.shared_project_id
  region  = var.region
}
