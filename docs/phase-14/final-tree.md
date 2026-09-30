# Final directory tree

```text
gcp-3tier-platform/
├── README.md
├── .github/
│   ├── dependabot.yml
│   └── workflows/
│       ├── docker-build.yml
│       ├── frontend-ci.yml
│       ├── backend-ci.yml
│       ├── terraform-plan.yml
│       └── terraform-apply.yml
├── application/
│   ├── README.md
│   ├── backend/          # Go API + Dockerfile
│   └── frontend/         # React + NGINX Dockerfile
├── docs/                 # Full operator documentation
├── gitops/
│   ├── apps/
│   ├── argocd/
│   ├── environments/{dev,stage,prod}/
│   └── infrastructure/gateway/
├── scripts/
│   ├── validate-all.sh
│   ├── validate-bootstrap.sh
│   ├── validate-network.sh
│   ├── validate-gke.sh
│   ├── validate-database.sh
│   ├── validate-artifact-registry.sh
│   ├── validate-gateway.sh
│   ├── validate-argocd.sh
│   ├── validate-monitoring.sh
│   ├── validate-security.sh
│   ├── validate-gcp.sh
│   └── smoke-test.sh
└── terraform/
    ├── .gitignore
    ├── .terraform-version
    ├── bootstrap/
    ├── policies/
    ├── environments/{dev,stage,prod}/
    └── modules/
        ├── app-identity/
        ├── argocd/
        ├── artifact-registry/
        ├── certificates/
        ├── cloud-sql/
        ├── dns/
        ├── external-secrets/
        ├── firewall/
        ├── gke/
        ├── monitoring/
        ├── nat/
        ├── network/
        ├── private-service-access/
        ├── project-services/
        ├── secrets/
        └── workload-identity/
```
