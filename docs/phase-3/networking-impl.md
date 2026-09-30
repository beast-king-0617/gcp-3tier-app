# Phase 3 — Networking

## Scope

Per-environment:

| Component | Module | Resource names |
|-----------|--------|----------------|
| VPC + subnets | `modules/network` | `{app}-{env}-vpc`, `{app}-{env}-gke`, `{app}-{env}-mgmt` |
| Cloud Router + NAT | `modules/nat` | `{app}-{env}-router`, `{app}-{env}-nat` |
| Private Service Access | `modules/private-service-access` | `{app}-{env}-psa` |
| Firewall | `modules/firewall` | `{app}-{env}-allow-*` |

## CIDRs

Authoritative table: [cidr-plan.md](../phase-1/cidr-plan.md)

## Firewall rules (documented)

| Rule | Source | Destination | Purpose |
|------|--------|-------------|---------|
| allow-internal | VPC + secondary + PSA CIDRs | all instances | East-west |
| allow-gcp-health-checks | Google HC ranges | tag `gke-node` | LB health checks |
| allow-gke-master | master `/28` | tag `gke-node` | Control plane |
| allow-iap-ssh | IAP `35.235.240.0/20` | tag `iap-ssh` | Break-glass SSH |

No `0.0.0.0/0` allow-all rules.

## Deploy order

1. Bootstrap (Phase 2)
2. `environments/dev` → `stage` → `prod` (independent projects)

## Validation

```bash
./scripts/validate-network.sh dev
```

## Outputs for later phases

See environment `outputs.tf` — consumed by GKE (Phase 4) and Cloud SQL (Phase 5).
