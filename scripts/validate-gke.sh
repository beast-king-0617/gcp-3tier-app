#!/usr/bin/env bash
# Validates Phase 4 GKE Terraform and (after apply) cluster health.
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

if [[ ! -d "${ENV_DIR}" ]]; then
  echo "Unknown environment: ${ENV}"
  exit 1
fi

echo "==> Environment: ${ENV}"
echo "==> terraform fmt (check)"
terraform -chdir="${ROOT}/terraform" fmt -check -recursive

if [[ ! -d "${ENV_DIR}/.terraform" ]]; then
  echo "==> terraform init -backend=false"
  terraform -chdir="${ENV_DIR}" init -backend=false
fi

echo "==> terraform validate"
terraform -chdir="${ENV_DIR}" validate

if [[ ! -f "${ENV_DIR}/terraform.tfvars" ]]; then
  echo "==> SKIP live GKE checks (no terraform.tfvars)"
  echo "Phase 4 static validation OK for ${ENV}."
  exit 0
fi

if ! terraform -chdir="${ENV_DIR}" output -raw gke_cluster_name >/dev/null 2>&1; then
  echo "No GKE outputs yet. Apply the environment stack first."
  echo "Phase 4 static validation OK for ${ENV}."
  exit 0
fi

PROJECT="$(terraform -chdir="${ENV_DIR}" output -raw project_id)"
CLUSTER="$(terraform -chdir="${ENV_DIR}" output -raw gke_cluster_name)"
LOCATION="$(terraform -chdir="${ENV_DIR}" output -raw gke_cluster_location)"

echo "==> Cluster: ${CLUSTER} (${LOCATION}) project=${PROJECT}"
gcloud container clusters describe "${CLUSTER}" \
  --region="${LOCATION}" \
  --project="${PROJECT}" \
  --format="yaml(name,status,currentMasterVersion,privateClusterConfig,workloadIdentityConfig,networkConfig.datapathProvider)"

eval "$(terraform -chdir="${ENV_DIR}" output -raw gke_get_credentials_command)"
kubectl get nodes -o wide
kubectl get nodepools 2>/dev/null || gcloud container node-pools list --cluster="${CLUSTER}" --region="${LOCATION}" --project="${PROJECT}"

echo "Phase 4 validation OK for ${ENV}."
