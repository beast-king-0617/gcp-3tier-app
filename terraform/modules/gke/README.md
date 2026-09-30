# GKE Module

Regional private GKE cluster with separate system and application node pools, Workload Identity, Dataplane V2, and production defaults.

## Features

- Regional cluster (HA control plane)
- Private nodes (no public IPs) — egress via Cloud NAT
- VPC-native (IP aliasing) with secondary ranges
- Workload Identity
- Dataplane V2 (Cilium) / NetworkPolicy
- Release channel `REGULAR`
- Shielded nodes
- Logging + Monitoring
- Maintenance window
- Cluster autoscaling (node pool autoscaling)
- Gateway API channel enabled (Phase 8)
- Node network tag aligned with firewall module (`gke-node`)

## Node pools

| Pool | Purpose | Taint |
|------|---------|-------|
| `system` | DNS, metrics, CSI, Argo CD system components | `CriticalAddonsOnly=true:NoSchedule` |
| `application` | Frontend/backend workloads | none |

## Usage

```hcl
module "gke" {
  source = "../../modules/gke"

  project_id         = var.project_id
  name_prefix        = "myapp-dev"
  region             = "us-central1"
  network            = module.network.network_self_link
  subnetwork         = module.network.subnet_self_links["gke"]
  pods_range_name    = module.network.gke_pods_range_name
  services_range_name = module.network.gke_services_range_name
  master_ipv4_cidr_block = var.gke_master_cidr
  node_network_tags  = [module.firewall.gke_node_tag]
}
```
