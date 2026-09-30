#!/usr/bin/env bash
# Run all static validators for an environment (no live GCP required for most).
set -euo pipefail

ENV="${1:-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

chmod +x scripts/*.sh

echo "======== validate-all env=${ENV} ========"
./scripts/validate-bootstrap.sh
./scripts/validate-network.sh "${ENV}"
./scripts/validate-gke.sh "${ENV}"
./scripts/validate-database.sh "${ENV}"
./scripts/validate-artifact-registry.sh "${ENV}"
./scripts/validate-gateway.sh "${ENV}"
./scripts/validate-argocd.sh "${ENV}"
./scripts/validate-monitoring.sh "${ENV}"
./scripts/validate-security.sh "${ENV}"

echo "==> Backend unit tests"
( cd application/backend && go test ./... )

echo "==> Kustomize all envs"
for e in dev stage prod; do
  kubectl kustomize --load-restrictor LoadRestrictionsNone "gitops/environments/${e}" >/dev/null
  echo "kustomize ${e} OK"
done

echo "======== ALL STATIC CHECKS PASSED ========"
echo "After apply + DNS + images: ./scripts/validate-gcp.sh ${ENV} && ./scripts/smoke-test.sh ${ENV}"
