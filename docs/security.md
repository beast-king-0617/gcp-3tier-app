# Security Design (Phase 1)

## 1. Security Principles

1. **Least privilege** — dedicated SAs; no `roles/owner` / `roles/editor` for automation.
2. **No long-lived keys** — GitHub Actions authenticates via OIDC → Workload Identity Federation.
3. **Private by default** — private GKE nodes, private Cloud SQL, Private Google Access.
4. **Secrets out of Git** — Secret Manager; never in tfvars, manifests, or images.
5. **Immutable artifacts** — images tagged by git SHA; vulnerability scanned before promote.
6. **Defense in depth** — network policies, security contexts, shielded nodes, scanning in CI.

---

## 2. Identity Model

| Identity | Purpose | Auth method |
|----------|---------|-------------|
| `tf-planner@{env}` | `terraform plan` from PRs | WIF (GitHub) |
| `tf-applier@{env}` | `terraform apply` from protected branches/envs | WIF (GitHub) |
| `gha-ci@{env}` | Build, push images to Artifact Registry | WIF (GitHub) |
| `gke-backend@{env}` | Backend pods → Secret Manager, Cloud SQL IAM/token if used | Workload Identity |
| `gke-frontend@{env}` | Frontend pods (minimal; usually no GCP API needs) | Workload Identity |
| `argocd-server` / repo SA | Pull GitOps repo; optional AR read | Workload Identity / deploy key |
| Human break-glass | Emergency | MFA + short-lived elevation (org process) |

Terraform state bucket IAM is restricted to terraform SAs + break-glass admins.

---

## 3. Secrets Strategy (chosen approach)

**Decision: External Secrets Operator + Secret Manager + Workload Identity**

| Option | Verdict |
|--------|---------|
| Plain Kubernetes Secret YAML in Git | Rejected — secrets in Git |
| Secret Manager CSI driver alone | Viable; less flexible for sync/rotation annotations |
| **External Secrets Operator (ESO)** | **Selected** — GitOps-friendly `ExternalSecret` CRDs; syncs into K8s Secrets at runtime; WI-backed |
| Cloud SQL Auth Proxy / connector | Used by backend for DB auth path (sidecar or library) |

Rationale: ESO keeps declarative config in GitOps without storing secret *values*; integrates cleanly with Argo CD; supports rotation.

Cloud SQL password (or IAM DB auth) lives only in Secret Manager; ESO materializes it into a K8s Secret consumed by the backend Deployment.

---

## 4. Network Security

- Private GKE nodes + Cloud NAT
- Private Cloud SQL (no public IP)
- VPC Firewall least privilege
- Kubernetes NetworkPolicies: default deny within `frontend`/`backend` namespaces; allow Gateway → FE, FE → BE (or Gateway → BE), BE → SQL (via egress to PSA CIDR), DNS, health probes
- Dataplane V2 (Cilium-based) for network policy enforcement

---

## 5. Workload Hardening (Kubernetes)

Every production Deployment will include:

- `runAsNonRoot: true`
- `allowPrivilegeEscalation: false`
- `readOnlyRootFilesystem: true` where practical (writable emptyDir for NGINX cache/tmp)
- Drop all capabilities
- Resource requests/limits
- startup / readiness / liveness probes
- PodDisruptionBudget
- Dedicated ServiceAccount (no default SA token abuse)

---

## 6. Supply Chain

| Stage | Tool |
|-------|------|
| Secrets in repo | gitleaks |
| Terraform misconfig | Checkov (and/or tfsec) |
| Container OS/deps | Trivy |
| Dependencies | GitHub Dependabot / language tooling |
| Image promote | Only scanned images; SHA tags |

---

## 7. Encryption

| Data | Encryption |
|------|------------|
| Terraform state GCS | Google-managed (CMEK optional later via KMS module) |
| Artifact Registry | Google-managed |
| Cloud SQL disks | Google-managed (CMEK optional in prod later) |
| Secrets at rest | Secret Manager |
| In transit | TLS to clients; private Google networking to SQL |

---

## 8. Production Approval Gates

- GitHub Environment `prod` requires reviewers
- Terraform apply for prod is manual approval workflow
- Argo CD sync for prod may use automated sync with self-heal **or** manual sync — **selected: automated sync with prune + self-heal for app, with PR review on GitOps as the control point**; infra changes require Terraform approval separately

## 9. Phase 12 implementation

See [phase-12/security.md](./phase-12/security.md) for Workload Identity, External Secrets, NetworkPolicies, and Pod Security Admission.
