# Network Module

Creates a custom-mode VPC with regional subnets, GKE secondary ranges, Private Google Access, and VPC Flow Logs.

## Resources

- `google_compute_network`
- `google_compute_subnetwork` (gke + mgmt)

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  project_id  = var.project_id
  name_prefix = "myapp-dev"
  region      = "us-central1"

  subnets = {
    gke = {
      ip_cidr_range = "10.10.0.0/20"
      secondary_ranges = {
        pods     = "10.10.16.0/18"
        services = "10.10.80.0/20"
      }
    }
    mgmt = {
      ip_cidr_range    = "10.10.96.0/24"
      secondary_ranges = {}
    }
  }
}
```
