# Database

See implementation details in [phase-5/database.md](./phase-5/database.md).

## Connection pattern (target)

```text
Backend Deployment
  → ExternalSecret (ESO) reads Secret Manager
  → K8s Secret mounted/env
  → Go app connects to Cloud SQL private IP:5432 with TLS
  → Optional: Cloud SQL Auth Proxy / Go connector for IAM auth (future enhancement)
```

v1 uses password auth stored in Secret Manager (rotated by re-running Terraform or a rotation pipeline). IAM database authentication can be added later without changing network design.
