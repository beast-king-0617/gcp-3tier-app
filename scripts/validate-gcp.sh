#!/usr/bin/env bash
# High-level GCP project sanity checks (APIs, expected resource classes).
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

if [[ ! -f "${ENV_DIR}/terraform.tfvars" ]]; then
  echo "No terraform.tfvars for ${ENV}; static OK only."
  exit 0
fi

PROJECT="$(terraform -chdir="${ENV_DIR}" output -raw project_id 2>/dev/null || true)"
if [[ -z "${PROJECT}" ]]; then
  echo "No terraform outputs yet for ${ENV}. Apply first."
  exit 0
fi

echo "==> Project ${PROJECT}"
gcloud services list --enabled --project="${PROJECT}" --filter="name:(container OR sqladmin OR artifactregistry OR compute OR secretmanager OR dns OR certificatemanager)" --format="value(config.name)"

echo "==> Networks"
gcloud compute networks list --project="${PROJECT}" --format="table(name,subnet_mode)"

echo "==> GKE"
gcloud container clusters list --project="${PROJECT}" --format="table(name,location,status)"

echo "==> Cloud SQL"
gcloud sql instances list --project="${PROJECT}" --format="table(name,region,settings.activationPolicy,settings.ipConfiguration.ipv4Enabled)"

echo "==> Artifact Registry"
gcloud artifacts repositories list --project="${PROJECT}" --format="table(name,format,location)" || true

echo "validate-gcp OK for ${ENV}"
