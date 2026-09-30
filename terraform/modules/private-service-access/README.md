# Private Service Access Module

Allocates an IP range and creates a Service Networking connection for Cloud SQL private IP.

## Usage

```hcl
module "psa" {
  source = "../../modules/private-service-access"

  project_id  = var.project_id
  name_prefix = "myapp-dev"
  network     = module.network.network_id
  prefix_length = 24
  address       = "10.10.100.0"
}
```

## Data path

```text
GKE Pod → VPC → PSA connection → Cloud SQL private IP
```
