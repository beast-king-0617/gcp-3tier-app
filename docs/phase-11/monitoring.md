# Phase 11 — Observability

## What GKE already provides (Phase 4)

- Cloud Logging: SYSTEM_COMPONENTS + WORKLOADS
- Cloud Monitoring components + Managed Prometheus
- Container stdout/stderr → Cloud Logging

## What this phase adds

Terraform module `modules/monitoring`:

| Alert | Threshold / window |
|-------|--------------------|
| GKE node CPU | > 85% / 15m |
| GKE node memory | > 90% / 15m |
| Container CPU | > 90% limit / 15m |
| Container memory | > 90% limit / 15m |
| Container restarts | delta > 3 / 10m |
| Cloud SQL CPU | > 80% / 15m |
| Cloud SQL disk | > 85% / 15m |
| Cloud SQL connections | > 80 / 10m |
| Backend 5xx | log-based metric > 5 / 5m |

Plus an overview dashboard.

## Noise control

- Sustained durations (10–15m), not 1-minute flaps
- `auto_close = 30m`
- Email channels only when `monitoring_notification_emails` is set

## Enable notifications

```hcl
monitoring_notification_emails = ["sre-oncall@example.com"]
```

## Useful log queries

```text
resource.type="k8s_container"
resource.labels.cluster_name="myapp-dev-gke"
resource.labels.namespace_name="backend"
```

```text
resource.type="gke_cluster"
protoPayload.methodName:"google.container"
```

## Validate

```bash
./scripts/validate-monitoring.sh dev
terraform output monitoring_alert_policies
```
