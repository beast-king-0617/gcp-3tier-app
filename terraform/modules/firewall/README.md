# Firewall Module

Least-privilege VPC firewall rules for GKE + health checks + optional IAP SSH.

## Rules created

| Rule | Direction | Source | Targets | Ports | Why |
|------|-----------|--------|---------|-------|-----|
| `allow-internal` | Ingress | VPC subnet + secondary CIDRs | All instances in VPC | tcp, udp, icmp | East-west within the environment VPC |
| `allow-gcp-health-checks` | Ingress | `35.191.0.0/16`, `130.211.0.0/22` | tag `gke-node` | tcp | GCLB / Gateway health checks |
| `allow-gke-master` | Ingress | GKE master CIDR | tag `gke-node` | tcp 443,10250; udp 51820 | Private control plane → nodes (incl. Dataplane V2) |
| `allow-iap-ssh` | Ingress | `35.235.240.0/20` | tag `iap-ssh` | tcp 22 | Break-glass SSH via IAP (mgmt) |

**Not created:** `0.0.0.0/0` allow-all.

GKE may add additional rules when the cluster is created in Phase 4; these are the baseline Terraform-managed set.
