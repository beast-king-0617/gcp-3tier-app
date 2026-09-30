# Target Repository Tree (End State)

This is the **planned** structure after all phases. Phase 1 creates only `docs/` (plus empty scaffolds). Later phases fill in files without renaming top-level paths.

```text
gcp-3tier-platform/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── networking.md
│   ├── security.md
│   ├── terraform.md                 # Phase 13
│   ├── cicd.md
│   ├── gitops.md                    # Phase 13
│   ├── argocd.md                    # Phase 13
│   ├── database.md                  # Phase 13
│   ├── monitoring.md                # Phase 13
│   ├── disaster-recovery.md         # Phase 13
│   ├── troubleshooting.md           # Phase 13
│   └── phase-1/
│       ├── assumptions.md
│       ├── architecture-diagram.md
│       ├── cidr-plan.md
│       ├── decisions.md
│       ├── environments.md
│       └── target-tree.md
│
├── terraform/
│   ├── bootstrap/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   └── terraform.tf
│   ├── environments/
│   │   ├── dev/
│   │   ├── stage/
│   │   └── prod/
│   ├── modules/
│   │   ├── project-services/
│   │   ├── network/
│   │   ├── nat/
│   │   ├── private-service-access/
│   │   ├── firewall/
│   │   ├── artifact-registry/
│   │   ├── gke/
│   │   ├── cloud-sql/
│   │   ├── iam/
│   │   ├── workload-identity/
│   │   ├── dns/
│   │   ├── monitoring/
│   │   └── secrets/
│   └── policies/
│
├── application/
│   ├── frontend/                    # React + NGINX
│   └── backend/                     # Go API
│
├── gitops/
│   ├── apps/
│   │   ├── frontend/
│   │   └── backend/
│   ├── environments/
│   │   ├── dev/
│   │   ├── stage/
│   │   └── prod/
│   ├── infrastructure/              # Gateway, namespaces, ESO, policies
│   └── argocd/
│
├── scripts/
│   ├── validate-gcp.sh
│   ├── validate-gke.sh
│   ├── validate-network.sh
│   ├── validate-database.sh
│   ├── validate-argocd.sh
│   └── smoke-test.sh
│
└── .github/
    └── workflows/
        ├── terraform-plan.yml
        ├── terraform-apply.yml
        ├── frontend-ci.yml
        ├── backend-ci.yml
        └── docker-build.yml
```
