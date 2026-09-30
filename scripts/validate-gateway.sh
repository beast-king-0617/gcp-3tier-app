#!/usr/bin/env bash
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"
GITOPS="${ROOT}/gitops/environments/${ENV}"

echo "==> Kustomize build ${ENV}"
kubectl kustomize --load-restrictor LoadRestrictionsNone "${GITOPS}" >/tmp/myapp-gateway-${ENV}.yaml
grep -q "kind: Gateway" /tmp/myapp-gateway-${ENV}.yaml
grep -q "kind: HTTPRoute" /tmp/myapp-gateway-${ENV}.yaml
grep -q "RequestRedirect\|requestRedirect" /tmp/myapp-gateway-${ENV}.yaml

echo "==> Terraform validate"
terraform -chdir="${ROOT}/terraform" fmt -check -recursive
if [[ ! -d "${ENV_DIR}/.terraform" ]]; then
  terraform -chdir="${ENV_DIR}" init -backend=false
fi
terraform -chdir="${ENV_DIR}" validate

echo "Phase 8 static validation OK for ${ENV}."
