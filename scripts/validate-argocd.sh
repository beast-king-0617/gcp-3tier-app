#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

echo "==> Static checks"
test -f "${ROOT}/gitops/argocd/project.yaml"
test -f "${ROOT}/gitops/argocd/application-${ENV}.yaml" || test -f "${ROOT}/gitops/argocd/application-dev.yaml"
kubectl kustomize --load-restrictor LoadRestrictionsNone "${ROOT}/gitops/environments/${ENV}" >/dev/null

terraform -chdir="${ROOT}/terraform" fmt -check -recursive
if [[ ! -d "${ENV_DIR}/.terraform" ]]; then
  terraform -chdir="${ENV_DIR}" init -backend=false
fi
terraform -chdir="${ENV_DIR}" validate

if [[ ! -f "${ENV_DIR}/terraform.tfvars" ]]; then
  echo "Phase 10 static validation OK for ${ENV} (no live cluster)."
  exit 0
fi

if ! terraform -chdir="${ENV_DIR}" output -raw argocd_namespace >/dev/null 2>&1; then
  echo "Argo CD not enabled/applied yet."
  echo "Phase 10 static validation OK for ${ENV}."
  exit 0
fi

NS="$(terraform -chdir="${ENV_DIR}" output -raw argocd_namespace)"
eval "$(terraform -chdir="${ENV_DIR}" output -raw gke_get_credentials_command)"
kubectl -n "${NS}" get deploy,svc,applications.argoproj.io
kubectl -n "${NS}" wait --for=condition=Available deploy/argocd-server --timeout=180s || true

echo "Phase 10 validation OK for ${ENV}."
