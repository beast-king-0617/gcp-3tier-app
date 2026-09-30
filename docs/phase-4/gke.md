# Phase 4 — GKE Implementation

## Cluster design

| Setting | Value |
|---------|-------|
| Type | Regional |
| Nodes | Private (no public IPs) |
| Networking | VPC-native + Dataplane V2 |
| Identity | Workload Identity |
| Release channel | REGULAR |
| Gateway API | CHANNEL_STANDARD |
| Logging | SYSTEM_COMPONENTS + WORKLOADS |
| Monitoring | System + managed Prometheus |
| Node hardening | Shielded (secure boot + integrity) |

## Control-plane access

- `enable_private_nodes = true`
- `enable_private_endpoint = false` by default (public endpoint exists)
- `master_authorized_networks` **enabled** — you must add office/VPN/CI CIDRs or use Connect Gateway

Empty authorized networks + feature enabled = public endpoint rejects non-Google client IPs.

## Node pools

| Pool | Taint | Purpose |
|------|-------|---------|
| system | `CriticalAddonsOnly=true:NoSchedule` | kube-system / platform add-ons |
| application | none | app Deployments |

Application pods must **not** be scheduled onto system nodes unless they tolerate the taint (avoid by default).

## Node IAM

Custom SA `gke-nodes@PROJECT` with:

- `roles/logging.logWriter`
- `roles/monitoring.metricWriter`
- `roles/monitoring.viewer`
- `roles/artifactregistry.reader`

Not using the overly broad default Compute Engine SA.

## Dependencies

Requires Phase 3 networking outputs (wired in the same environment stack):

- VPC + GKE subnet + secondary ranges
- Cloud NAT (node egress / image pulls beyond Private Google Access)
- Firewall rule targeting tag `gke-node`
- PSA ready for Phase 5 (not required to create the cluster)

## Deploy / validate

See `terraform/environments/<env>/README.md` and `scripts/validate-gke.sh`.
