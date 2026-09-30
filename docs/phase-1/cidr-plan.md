# CIDR Plan (Authoritative)

Use these values in Terraform `locals` / `terraform.tfvars` starting Phase 3. Do not change without updating this document and all env tfvars together.

## Supernets

| Environment | VPC CIDR | Notes |
|-------------|----------|-------|
| dev | `10.10.0.0/16` | Isolated |
| stage | `10.20.0.0/16` | Isolated |
| prod | `10.30.0.0/16` | Isolated |

## Subnet and secondary ranges

| Name | Dev | Stage | Prod | Mask |
|------|-----|-------|------|------|
| `gke` (nodes primary) | `10.10.0.0/20` | `10.20.0.0/20` | `10.30.0.0/20` | /20 |
| `gke-pods` | `10.10.16.0/18` | `10.20.16.0/18` | `10.30.16.0/18` | /18 |
| `gke-services` | `10.10.80.0/20` | `10.20.80.0/20` | `10.30.80.0/20` | /20 |
| `mgmt` | `10.10.96.0/24` | `10.20.96.0/24` | `10.30.96.0/24` | /24 |
| `psa` (Service Networking allocated) | `10.10.100.0/24` | `10.20.100.0/24` | `10.30.100.0/24` | /24 |

## GKE master (control plane) CIDRs

Must not overlap VPC ranges. Private cluster requirement.

| Environment | `master_ipv4_cidr_block` |
|-------------|--------------------------|
| dev | `172.16.0.0/28` |
| stage | `172.16.0.16/28` |
| prod | `172.16.0.32/28` |

## Overlap verification

```text
10.10.0.0/20   nodes
10.10.16.0/18  pods      → starts after nodes (/20 ends at 10.10.15.255) ✓
10.10.80.0/20  services  → 10.10.16.0/18 ends at 10.10.79.255 ✓
10.10.96.0/24  mgmt      → after services (/20 ends 10.10.95.255) ✓
10.10.100.0/24 psa       → after mgmt ✓
172.16.0.0/28  master    → different RFC1918 block ✓
```

Same relative layout for `10.20.0.0/16` and `10.30.0.0/16`.

## GCP health-check source ranges (firewall allowlist)

```text
35.191.0.0/16
130.211.0.0/22
```

These are Google-owned ranges for load balancer health checks — not part of the VPC allocation.
