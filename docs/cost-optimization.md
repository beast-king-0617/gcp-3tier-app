# Cost Optimization

Do **not** cut security or HA in prod for savings.

## GKE

- Right-size node pools (see env matrix); use autoscaling min/max.
- Spot VMs only for **dev** app pool if acceptable (off by default).
- Prefer `e2` family; avoid idle max nodes.

## Cloud SQL

- Dev: ZONAL, smaller tier.
- Stage/prod: REGIONAL HA only where required.
- Autoresize with limits in prod; monitor disk alerts.

## Networking

- Cloud NAT: start with AUTO IPs; watch egress volume.
- VPC Flow Logs sampling: lower in prod (0.25) if costly.

## Artifact Registry

- Cleanup policies keep 20/30/50 versions (dev/stage/prod).
- Delete unused repos/tags periodically.

## Logging / Monitoring

- Workload logs retained per org policy; avoid debug in prod.
- Alert on sustained signals only (Phase 11) — fewer pages, less toil.

## Non-production

- Schedule scale-to-zero / smaller pools nights/weekends (process or Cloud Scheduler + script — optional).
- Delete unused stage clusters if idle for long periods.

## Committed use

- After steady prod load, buy CUDs for GKE nodes / SQL for 1-year savings.
