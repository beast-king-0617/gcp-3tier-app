# Phase 12 — Security Hardening

## Controls implemented

| Control | Implementation |
|---------|----------------|
| No SA JSON keys | WIF for GitHub + Workload Identity for pods |
| Secrets out of Git | ExternalSecret → Secret Manager (`backend-db`) |
| Least-privilege workload SAs | `gke-backend`, `gke-frontend`, `gke-eso` |
| Network segmentation | NetworkPolicies on frontend/backend |
| Pod Security | Namespace labels: backend `restricted`, frontend `baseline` |
| Container hardening | Already in Deployments (Phase 7) |
| Supply chain | Trivy / Checkov / gitleaks (Phase 9) |
| Private data plane | Private GKE nodes + private Cloud SQL (Phases 3–5) |

## Enable External Secrets

```hcl
enable_external_secrets = true
terraform apply
```

Then ensure GitOps ExternalSecret `remoteRef.key` matches:

```text
{app}-{env}-db-password
```

## Workload Identity annotations

```yaml
metadata:
  annotations:
    iam.gke.io/gcp-service-account: gke-backend@PROJECT.iam.gserviceaccount.com
```

Patched per environment in `gitops/environments/*/kustomization.yaml`.

## NetworkPolicy summary

- **Backend**: allow ingress 8080 from gateway-system/frontend; egress DNS, SQL (10/8:5432), HTTPS
- **Frontend**: allow ingress 8080 from gateway; egress DNS, backend:8080, HTTPS

## Validate

```bash
./scripts/validate-security.sh dev
kubectl kustomize --load-restrictor LoadRestrictionsNone gitops/environments/dev | grep -A2 ExternalSecret
```
