# Phase 1 — Architecture Decision Records

All decisions below are **locked for subsequent phases** unless explicitly revised with a note.

---

## ADR-001: Separate GCP project per environment

**Decision:** `myapp-dev`, `myapp-stage`, `myapp-prod`, plus `myapp-shared` for bootstrap (state, WIF).

**Why:** Blast-radius isolation, separate billing/quota, clearer IAM boundaries. Shared VPC is more complex and deferred.

**Trade-off:** Slightly higher management overhead vs single project with folders.

---

## ADR-002: Regional private GKE with Dataplane V2

**Decision:** Regional cluster, private nodes, public endpoint optionally restricted via authorized networks, Workload Identity, Dataplane V2, release channel `REGULAR`.

**Why:** HA control plane + nodes; private nodes reduce attack surface; Dataplane V2 provides modern NetworkPolicy; REGULAR balances stability and features (Gateway API maturity).

---

## ADR-003: Separate system and application node pools

**Decision:** `system` (tainted for system add-ons where applicable) and `application` (untainted for workloads).

**Why:** Prevent app noisy-neighbor impact on DNS/metrics/CSI; clearer capacity planning.

---

## ADR-004: Gateway API instead of Ingress

**Decision:** Use GKE Gateway API (`Gateway`, `HTTPRoute`) with Google-managed HTTPS certificates.

**Why:**

| Concept | Role |
|---------|------|
| **Load Balancer** | GCP data-plane (forwarding rules, backends, health checks) |
| **Ingress** | Older K8s API; single resource mixes L7 routing + cert concerns; annotation-heavy on GKE |
| **Gateway API** | Role-oriented (Gateway admin vs app Route owners); portable; first-class redirects, header matching, multi-service routing |

Gateway API is the strategic GKE L7 path; Ingress remains legacy-compatible but is not used for this greenfield design.

---

## ADR-005: Go backend + React/NGINX frontend

**Decision:** Backend in **Go**; frontend **React** built into static assets served by **NGINX**.

**Why:** Small static binary for backend (fast cold start, minimal image); React is standard for SPA; NGINX is proven for static + reverse proxy patterns.

---

## ADR-006: Cloud SQL PostgreSQL private IP + HA in stage/prod

**Decision:** Enterprise Plus or Enterprise edition as sized per env; private IP only; HA (`REGIONAL`) for stage and prod; PITR + backups enabled; deletion protection on prod.

**Why:** Meets RPO goals without self-managing Postgres; private IP removes public attack surface.

---

## ADR-007: External Secrets Operator for secret delivery

**Decision:** Secret Manager is system of record; ESO syncs into namespaces.

**Why:** GitOps-friendly; no secret values in Git; WI-based access; easier rotation than baking CSI-only mounts for all cases.

---

## ADR-008: GitOps via separate repo + Argo CD

**Decision:** GitHub Actions never `kubectl apply` for apps; updates GitOps manifests; Argo CD reconciles.

**Why:** Auditable desired state; easy rollback via Git revert; consistent with enterprise CD practice.

---

## ADR-009: Workload Identity Federation for GitHub Actions

**Decision:** OIDC → WIF → Google SA. No JSON keys.

**Why:** Eliminates long-lived credential leak risk; short-lived tokens; attribute conditions can lock to repo/branch/environment.

---

## ADR-010: Terraform module layout + GCS remote state

**Decision:** Bootstrap stack creates state bucket + WIF; environment stacks use GCS backend with prefix `env/{name}`.

**Why:** Solves chicken-and-egg for state; module reuse across env; state isolation by prefix.

---

## ADR-011: Image tags are git SHAs

**Decision:** Immutable tags; no `latest` for deployment.

**Why:** Deterministic rollback and provenance.

---

## ADR-012: Domain placeholder via variable

**Decision:** Default documented domain pattern `myapp.example.com`; real domain supplied in tfvars (`dns_domain`).

**Why:** Executable code cannot invent a customer DNS zone; variable is the correct production pattern (not a fake project ID hard-code).

---

## ADR-013: Primary region us-central1

**Decision:** Single-region active deployment for v1.

**Why:** Cost and operational simplicity; DR documented as rebuild + PITR restore to alternate region if needed.

---

## ADR-014: Terraform and provider pinning

**Decision:** Terraform `>= 1.7.0` (CI target 1.9.x); Google provider `~> 6.0`; google-beta only where required (e.g. some GKE/Gateway features).

**Why:** Reproducible plans; modern provider features for GKE Gateway / WI; floor allows local 1.7.x toolchains while CI pins newer patch releases.
