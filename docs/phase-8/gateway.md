# Phase 8 — Gateway API, TLS, DNS

## Gateway API vs Ingress vs Load Balancer

| Layer | Role |
|-------|------|
| **Load Balancer** | GCP data plane (URL map, proxies, NEGs, health checks) |
| **Ingress** | Legacy Kubernetes API; annotation-heavy on GKE |
| **Gateway API** | Role-oriented (`Gateway` + `HTTPRoute`); used here |

GKE Gateway controller watches Gateway/HTTPRoute and **provisions** the Load Balancer.

## Architecture

```text
Internet
  → Global External Application LB (from GatewayClass gke-l7-global-external-managed)
  → Gateway listeners :80 (redirect) and :443 (TLS)
  → HTTPRoute /
       → frontend:80
  → HTTPRoute /api
       → backend:8080
```

## Terraform edge resources

| Resource | Module | Purpose |
|----------|--------|---------|
| Cloud DNS zone | `dns` | Public zone for `dns_domain` |
| Global IP | `certificates` | Stable Gateway address |
| DNS auth + managed cert + cert map | `certificates` | Google-managed HTTPS |
| A record | `certificates` | Hostname → Gateway IP |

## GitOps

```text
gitops/infrastructure/gateway/   # Gateway, HTTPRoutes, HealthCheckPolicies
gitops/environments/{dev,stage,prod}/kustomization.yaml  # host + certmap + IP patches
```

After `terraform apply`, copy outputs into the env kustomization patches:

```bash
terraform output gateway_gitops_patch_hints
```

## HTTP → HTTPS

`HTTPRoute/https-redirect` on listener `http` uses `RequestRedirect` scheme=https status 301.

## Certificate provisioning note

Google-managed certs require:

1. Registrar NS delegation to Cloud DNS (`terraform output dns_name_servers`)
2. DNS authorization CNAME present (created by Terraform)
3. Cert may stay `PROVISIONING` for several minutes after DNS propagates

## Validate

```bash
kubectl kustomize --load-restrictor LoadRestrictionsNone gitops/environments/dev
terraform -chdir=terraform/environments/dev validate
./scripts/validate-gateway.sh dev
```

> Note: env overlays reference `../../apps` and `../../infrastructure`. Use `--load-restrictor LoadRestrictionsNone` (included in the validation script).
