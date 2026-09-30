# Cloud NAT Module

Creates a Cloud Router and Cloud NAT for private GKE node egress.

## Usage

```hcl
module "nat" {
  source = "../../modules/nat"

  project_id  = var.project_id
  name_prefix = "myapp-dev"
  region      = "us-central1"
  network     = module.network.network_self_link
}
```
