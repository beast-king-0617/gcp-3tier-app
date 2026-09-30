#!/usr/bin/env bash
# Validates Phase 3 networking Terraform (and live GCP resources after apply).
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

if [[ ! -d "${ENV_DIR}" ]]; then
  echo "Unknown environment: ${ENV} (expected directory ${ENV_DIR})"
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
  echo "==> SKIP live checks (no terraform.tfvars)"
  echo "Phase 3 static validation OK for ${ENV}."
  exit 0
fi

if ! terraform -chdir="${ENV_DIR}" output -json >/tmp/myapp-network-${ENV}.json 2>/dev/null; then
  echo "No state/outputs yet. Apply networking before live validation."
  echo "Phase 3 static validation OK for ${ENV}."
  exit 0
fi

PROJECT="$(terraform -chdir="${ENV_DIR}" output -raw project_id)"
NETWORK="$(terraform -chdir="${ENV_DIR}" output -raw network_name)"

echo "==> VPC: ${NETWORK} in ${PROJECT}"
gcloud compute networks describe "${NETWORK}" --project="${PROJECT}" --format="value(name,autoCreateSubnetworks)"
gcloud compute networks subnets list --network="${NETWORK}" --project="${PROJECT}" --format="table(name,region,ipCidrRange)"
gcloud compute routers list --project="${PROJECT}" --format="table(name,region,network)"
gcloud compute firewall-rules list --project="${PROJECT}" --filter="network~${NETWORK}" --format="table(name,direction,priority)"

echo "Phase 3 validation OK for ${ENV}."
