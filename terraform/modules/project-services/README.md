# Project Services Module

Enables a set of Google Cloud APIs on a target project.

## Usage

```hcl
module "apis" {
  source     = "../../modules/project-services"
  project_id = var.project_id
  services   = ["compute.googleapis.com", "container.googleapis.com"]
}
```

## Inputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID |
| `services` | List of API service names |
| `disable_on_destroy` | Whether to disable APIs on destroy (default `false`) |

## Outputs

| Name | Description |
|------|-------------|
| `enabled_services` | Map of enabled service IDs |
