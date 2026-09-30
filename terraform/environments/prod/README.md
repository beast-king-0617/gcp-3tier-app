# Environment platform stack (Phases 3–5)

Applies networking + GKE + Cloud SQL for one environment.

## Prerequisites

1. Phase 2 bootstrap applied.
2. `backend.tf` bucket matches bootstrap state bucket.
3. Add CIDRs to `gke_master_authorized_networks` for kubectl access.
4. Never put DB passwords in `terraform.tfvars` — they are generated and stored in Secret Manager.

## Deploy

```bash
cd terraform/environments/<env>
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=platform.tfplan
terraform apply platform.tfplan
```

## Validate

```bash
../../../scripts/validate-network.sh <env>
../../../scripts/validate-gke.sh <env>
../../../scripts/validate-database.sh <env>
```

## Key outputs

| Output | Use |
|--------|-----|
| `gke_cluster_name` | kubectl / Argo CD |
| `cloudsql_private_ip` | Backend connection host |
| `cloudsql_connection_secret_id` | ESO / app secret reference |
| `artifact_registry_urls` | CI image push targets |
| `psa_*` | Confirms private path for SQL |
