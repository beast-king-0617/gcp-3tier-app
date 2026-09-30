# Replace bucket with terraform output -raw state_bucket_name from bootstrap.
terraform {
  backend "gcs" {
    bucket = "myapp-shared-tfstate"
    prefix = "env/prod"
  }
}
