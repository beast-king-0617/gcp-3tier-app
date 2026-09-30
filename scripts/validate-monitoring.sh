#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

terraform -chdir="${ROOT}/terraform" fmt -check -recursive
if [[ ! -d "${ENV_DIR}/.terraform" ]]; then
  terraform -chdir="${ENV_DIR}" init -backend=false
fi
terraform -chdir="${ENV_DIR}" validate

if [[ ! -f "${ENV_DIR}/terraform.tfvars" ]]; then
  echo "Phase 11 static validation OK for ${ENV}."
  exit 0
fi

if terraform -chdir="${ENV_DIR}" output -json monitoring_alert_policies >/tmp/alerts-${ENV}.json 2>/dev/null; then
  echo "==> Alert policies:"
  cat /tmp/alerts-${ENV}.json
  PROJECT="$(terraform -chdir="${ENV_DIR}" output -raw project_id)"
  gcloud monitoring policies list --project="${PROJECT}" --format="table(displayName,enabled)" || true
fi

echo "Phase 11 validation OK for ${ENV}."
