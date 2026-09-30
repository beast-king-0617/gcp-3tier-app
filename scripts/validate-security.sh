#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

echo "==> Kustomize includes ExternalSecret + NetworkPolicy"
OUT="$(kubectl kustomize --load-restrictor LoadRestrictionsNone "${ROOT}/gitops/environments/${ENV}")"
echo "${OUT}" | grep -q "kind: ExternalSecret"
echo "${OUT}" | grep -q "kind: NetworkPolicy"
echo "${OUT}" | grep -q "pod-security.kubernetes.io/enforce"

# Ensure no plaintext password placeholder remains
if echo "${OUT}" | grep -q 'REPLACE_VIA_EXTERNAL_SECRETS'; then
  echo "ERROR: plaintext secret placeholder still present"
  exit 1
fi

terraform -chdir="${ROOT}/terraform" fmt -check -recursive
if [[ ! -d "${ENV_DIR}/.terraform" ]]; then
  terraform -chdir="${ENV_DIR}" init -backend=false
fi
terraform -chdir="${ENV_DIR}" validate

echo "Phase 12 static validation OK for ${ENV}."
