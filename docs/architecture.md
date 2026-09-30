# Architecture Overview — GCP 3-Tier Platform

**Project codename:** `myapp`  
**Phase:** 1 — Architecture and Design  
**Status:** Design locked pending confirmation to proceed to Phase 2

---

## 1. Purpose

This repository is a production-grade reference implementation of a three-tier web application on Google Cloud Platform, fully managed with Terraform, GitHub Actions (CI), and Argo CD (GitOps CD).

The intended audience is an enterprise DevOps/SRE team that needs a starting point that is secure by default, environment-separated, and operable in production.

---

## 2. High-Level Architecture

```text
Internet
   |
   v
Google Cloud External Application Load Balancer  (provisioned by GKE Gateway controller)
   |
   v
GKE Gateway API  (Gateway + HTTPRoute)
   |
   +------------------+------------------+
   |                                     |
   v                                     v
Frontend (React/NGINX)              Backend API (Go)
namespace: frontend                 namespace: backend
   |                                     |
   |                                     v
   |                              Cloud SQL PostgreSQL
   |                              (Private IP via PSA)
   |
   +---- both pull images from Artifact Registry
```

### Control / delivery plane

```text
Developer
   |
   v
GitHub (application + terraform + gitops repos)
   |
   +-- GitHub Actions (OIDC → Workload Identity Federation)
   |        |
   |        +--> Terraform apply  →  GCP infrastructure
   |        +--> Build/Test/Scan  →  Artifact Registry
   |        +--> Update image tags in GitOps repo
   |
   v
Argo CD (in GKE)
   |
   v
Reconciles desired state from GitOps → GKE workloads
```

---

## 3. Logical Tiers

| Tier | Components | Runtime | Exposure |
|------|------------|---------|----------|
| Presentation | React SPA served by NGINX | GKE Deployment + Service | Via Gateway HTTPRoute `/` |
| Application | Go REST API | GKE Deployment + Service + HPA | Via Gateway HTTPRoute `/api` |
| Data | Cloud SQL PostgreSQL | Managed GCP service | Private IP only (PSA) |

---

## 4. Environments and Projects

| Environment | GCP Project ID (variable) | Purpose |
|-------------|---------------------------|---------|
| Shared / bootstrap | `myapp-shared` | Terraform state bucket, WIF pool, shared IAM bootstrap |
| Development | `myapp-dev` | Day-to-day engineering; smaller footprint |
| Staging | `myapp-stage` | Production-like validation |
| Production | `myapp-prod` | Customer-facing; HA, deletion protection, approvals |

Project IDs are **never hard-coded** in module code. They are supplied via `terraform.tfvars` / GitHub environment variables per environment.

> **Assumption:** Projects already exist (or are created once by an org admin). Terraform in this reference manages resources *inside* projects, not org-level project creation, to avoid requiring Organization Admin privileges for day-to-day use. Bootstrap may optionally create projects if `create_projects = true`.

---

## 5. Regions and Zones

| Setting | Value | Rationale |
|---------|-------|-----------|
| Primary region | `us-central1` | Broad service availability, cost-efficient |
| GKE | Regional cluster across `us-central1-a/b/c` | Control-plane and node HA |
| Cloud SQL | Regional HA (`REGIONAL`) in `us-central1` | Automatic failover |
| Artifact Registry | `us-central1` | Co-located with GKE pulls (lower latency, egress) |

Secondary region DR is documented but **not** multi-region active-active in v1 (cost/complexity). See disaster-recovery docs in later phases.

---

## 6. Repository Layout (target end state)

Three logical repos (can live as sibling directories in a monorepo during development; split for production GitHub org):

```text
gcp-3tier-platform/
├── docs/                    # Architecture & runbooks
├── terraform/               # Infra as code (Phases 2–6, 11–12)
├── application/             # Frontend + backend source (Phase 7)
├── gitops/                  # Kustomize + Argo CD apps (Phases 8, 10)
├── scripts/                 # Validation / smoke tests (Phase 14)
└── .github/workflows/       # CI/CD (Phase 9)
```

Logical GitHub repositories when split:

| Repo | Contents |
|------|----------|
| `myapp-terraform` | `terraform/` |
| `myapp-application` | `application/` + app CI workflows |
| `myapp-gitops` | `gitops/` (Argo CD source of truth) |

---

## 7. Naming Conventions

| Resource | Pattern | Example |
|----------|---------|---------|
| VPC | `{app}-{env}-vpc` | `myapp-dev-vpc` |
| Subnet | `{app}-{env}-{purpose}` | `myapp-dev-gke` |
| GKE cluster | `{app}-{env}-gke` | `myapp-prod-gke` |
| Node pool | `{app}-{env}-{pool}` | `myapp-prod-system` |
| Cloud SQL | `{app}-{env}-pg` | `myapp-prod-pg` |
| Artifact Registry | `{app}-{env}-containers` | `myapp-dev-containers` |
| SA | `{purpose}@{project}.iam.gserviceaccount.com` | `gha-ci@myapp-dev.iam...` |
| K8s namespace | fixed: `frontend`, `backend`, `argocd`, `monitoring` | — |
| Image tag | git SHA (immutable) | `a1b2c3d` |

App short name: **`myapp`** (locked for consistency across all phases).

---

## 8. Related Documents

| Doc | Content |
|-----|---------|
| [networking.md](./networking.md) | CIDRs, VPC, firewall, PSA, NAT |
| [security.md](./security.md) | IAM model, secrets, hardening decisions |
| [cicd.md](./cicd.md) | Branching, promotion, approval gates |
| [phase-1/decisions.md](./phase-1/decisions.md) | ADR-style design decisions |
| [phase-1/cidr-plan.md](./phase-1/cidr-plan.md) | Detailed non-overlapping CIDR plan |
| [phase-1/environments.md](./phase-1/environments.md) | Per-env sizing and policy matrix |
