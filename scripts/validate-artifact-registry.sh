#!/usr/bin/env bash
# Validates Phase 6 Artifact Registry Terraform and (after apply) repositories.
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

if [[ ! -d "${ENV_DIR}" ]]; then
  echo "Unknown environment: ${ENV}"
  exit 1
fi

echo "==> Environment: ${ENV}"
terraform -chdir="${ROOT}/terraform" fmt -check -recursive

if [[ ! -d "${ENV_DIR}/.terraform" ]]; then
  terraform -chdir="${ENV_DIR}" init -backend=false
fi

terraform -chdir="${ENV_DIR}" validate

if [[ ! -f "${ENV_DIR}/terraform.tfvars" ]]; then
  echo "==> SKIP live Artifact Registry checks (no terraform.tfvars)"
  echo "Phase 6 static validation OK for ${ENV}."
  exit 0
fi

if ! terraform -chdir="${ENV_DIR}" output -json artifact_registry_urls >/dev/null 2>&1; then
  echo "No Artifact Registry outputs yet. Apply first."
  echo "Phase 6 static validation OK for ${ENV}."
  exit 0
fi

PROJECT="$(terraform -chdir="${ENV_DIR}" output -raw project_id)"
LOCATION="$(terraform -chdir="${ENV_DIR}" output -raw artifact_registry_location)"

echo "==> Repositories in ${LOCATION} / ${PROJECT}"
gcloud artifacts repositories list --project="${PROJECT}" --location="${LOCATION}" \
  --format="table(name,format,createTime)"

echo "==> Image URL examples"
terraform -chdir="${ENV_DIR}" output -json artifact_registry_image_examples

echo "Phase 6 validation OK for ${ENV}."
