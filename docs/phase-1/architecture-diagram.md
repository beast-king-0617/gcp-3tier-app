# Architecture Diagrams (Phase 1)

## End-to-end platform

```mermaid
flowchart TB
  subgraph People
    DEV[Developer]
    APR[Prod Approver]
  end

  subgraph GitHub
    APP_REPO[myapp-application]
    TF_REPO[myapp-terraform]
    GITOPS[myapp-gitops]
    GHA[GitHub Actions<br/>OIDC]
  end

  subgraph GCP_Shared["GCP Project: myapp-shared"]
    STATE[(GCS Terraform State)]
    WIF[Workload Identity Pool]
  end

  subgraph GCP_Env["GCP Project: myapp-{env}"]
    VPC[Custom VPC]
    NAT[Cloud NAT]
    AR[Artifact Registry]
    GKE[Regional Private GKE]
    SM[Secret Manager]
    SQL[(Cloud SQL PG<br/>Private IP)]
    PSA[PSA Connection]
    MON[Cloud Monitoring / Logging]
  end

  subgraph GKE_Cluster[GKE Cluster]
    ARGO[Argo CD]
    GW[Gateway API]
    FE[frontend ns]
    BE[backend ns]
  end

  DEV --> APP_REPO
  DEV --> TF_REPO
  APR -.->|approve prod| GHA

  APP_REPO --> GHA
  TF_REPO --> GHA
  GHA --> WIF
  WIF --> GHA
  GHA -->|terraform| STATE
  GHA -->|plan/apply| VPC
  GHA -->|push images| AR
  GHA -->|update manifests| GITOPS

  GITOPS --> ARGO
  ARGO --> FE
  ARGO --> BE
  ARGO --> GW

  Internet((Internet)) --> GW
  GW --> FE
  GW --> BE
  BE --> SM
  BE --> PSA
  PSA --> SQL
  GKE --> NAT
  VPC --> PSA
  GKE --> MON
```

## Network data path

```mermaid
flowchart LR
  User[Client Browser] -->|HTTPS| LB[External Application LB]
  LB --> GW[Gateway]
  GW -->|/| FE[Frontend Service]
  GW -->|/api| BE[Backend Service]
  BE -->|TCP 5432 private| SQL[(Cloud SQL)]
```

## Identity path for CI

```mermaid
sequenceDiagram
  participant GH as GitHub Actions
  participant OIDC as GitHub OIDC
  participant WIF as GCP WIF Pool
  participant SA as Google SA gha-ci
  participant AR as Artifact Registry

  GH->>OIDC: Request ID token
  OIDC-->>GH: JWT
  GH->>WIF: Exchange JWT
  WIF-->>GH: Federated token
  GH->>SA: Impersonate
  SA-->>GH: Access token
  GH->>AR: docker push :gitsha
```

## Gateway API vs Ingress vs Load Balancer

```mermaid
flowchart TB
  subgraph Control_Plane
    GWAPI[Gateway + HTTPRoute CRDs]
    ING[Ingress CRD - not used]
  end

  subgraph Data_Plane
    LB[GCP Application Load Balancer]
  end

  GWAPI -->|GKE Gateway controller provisions| LB
  ING -.->|legacy controller| LB
```

| Layer | What it is |
|-------|------------|
| Load Balancer | Actual Google Front End / URL map / backends / NEGs |
| Ingress | Older Kubernetes API that often maps 1:1 to an LB via annotations |
| Gateway API | Newer role-oriented API; this design’s L7 entry point |
