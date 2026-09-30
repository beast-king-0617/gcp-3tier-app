#!/usr/bin/env bash
# Validates Phase 5 Cloud SQL Terraform and (after apply) instance health.
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
  echo "==> SKIP live DB checks (no terraform.tfvars)"
  echo "Phase 5 static validation OK for ${ENV}."
  exit 0
fi

if ! terraform -chdir="${ENV_DIR}" output -raw cloudsql_instance_name >/dev/null 2>&1; then
  echo "No Cloud SQL outputs yet. Apply the environment stack first."
  echo "Phase 5 static validation OK for ${ENV}."
  exit 0
fi

PROJECT="$(terraform -chdir="${ENV_DIR}" output -raw project_id)"
INSTANCE="$(terraform -chdir="${ENV_DIR}" output -raw cloudsql_instance_name)"
SECRET="$(terraform -chdir="${ENV_DIR}" output -raw cloudsql_connection_secret_id)"

echo "==> Instance: ${INSTANCE}"
gcloud sql instances describe "${INSTANCE}" --project="${PROJECT}" \
  --format="yaml(name,state,databaseVersion,settings.availabilityType,settings.ipConfiguration,settings.backupConfiguration.enabled,settings.backupConfiguration.pointInTimeRecoveryEnabled)"

IP="$(terraform -chdir="${ENV_DIR}" output -raw cloudsql_private_ip)"
echo "==> Private IP: ${IP}"
# Public IP must be absent
if gcloud sql instances describe "${INSTANCE}" --project="${PROJECT}" --format="value(ipAddresses.filter('type:PRIMARY').ipAddress)" | grep -q .; then
  echo "ERROR: public PRIMARY IP found — expected private-only"
  exit 1
fi

echo "==> Secret exists: ${SECRET}"
gcloud secrets describe "${SECRET}" --project="${PROJECT}" --format="value(name)"

echo "Phase 5 validation OK for ${ENV}."
