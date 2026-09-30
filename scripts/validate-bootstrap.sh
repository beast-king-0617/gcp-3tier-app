#!/usr/bin/env bash
# Validates Phase 2 bootstrap outputs and key GCP resources.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="${ROOT}/terraform/bootstrap"

echo "==> Checking bootstrap directory"
test -d "${BOOTSTRAP}"

echo "==> terraform fmt (check)"
terraform -chdir="${BOOTSTRAP}" fmt -check -recursive || {
  echo "Run: terraform -chdir=${BOOTSTRAP} fmt -recursive"
  exit 1
}

if [[ ! -d "${BOOTSTRAP}/.terraform" ]]; then
  echo "==> terraform init (backend=false for modules)"
  terraform -chdir="${BOOTSTRAP}" init -backend=false
fi

echo "==> terraform validate"
terraform -chdir="${BOOTSTRAP}" validate

if [[ ! -f "${BOOTSTRAP}/terraform.tfvars" ]]; then
  echo "==> SKIP live GCP checks (no terraform.tfvars). Copy terraform.tfvars.example to proceed with apply."
  echo "Phase 2 static validation OK."
  exit 0
fi

if [[ ! -f "${BOOTSTRAP}/terraform.tfstate" ]] && [[ ! -f "${BOOTSTRAP}/.terraform/terraform.tfstate" ]]; then
  # Remote state may exist; try output anyway.
  :
fi

echo "==> terraform output (requires successful apply)"
if ! terraform -chdir="${BOOTSTRAP}" output -json >/tmp/myapp-bootstrap-outputs.json 2>/dev/null; then
  echo "No state/outputs yet. Apply bootstrap before live validation."
  echo "Phase 2 static validation OK."
  exit 0
fi

BUCKET="$(terraform -chdir="${BOOTSTRAP}" output -raw state_bucket_name)"
SHARED="$(terraform -chdir="${BOOTSTRAP}" output -raw shared_project_id)"
WIF="$(terraform -chdir="${BOOTSTRAP}" output -raw workload_identity_provider)"

echo "==> State bucket: gs://${BUCKET}"
gcloud storage buckets describe "gs://${BUCKET}" --project="${SHARED}" --format="value(name,versioning.enabled,iamConfiguration.uniformBucketLevelAccess.enabled)"

echo "==> WIF provider: ${WIF}"
echo "${WIF}" | grep -q "workloadIdentityPools/github-actions/providers/github"

echo "==> Service accounts (sample)"
terraform -chdir="${BOOTSTRAP}" output -json service_accounts | head -c 2000
echo

echo "Phase 2 validation OK."
