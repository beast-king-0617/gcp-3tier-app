#!/usr/bin/env bash
# End-to-end smoke test:
# Internet → LB/Gateway → Frontend → Backend → Cloud SQL
set -euo pipefail

ENV="${1:-dev}"
BASE_URL="${2:-}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT}/terraform/environments/${ENV}"

if [[ -z "${BASE_URL}" ]]; then
  if [[ -f "${ENV_DIR}/terraform.tfvars" ]] && terraform -chdir="${ENV_DIR}" output -raw app_hostname >/dev/null 2>&1; then
    HOST="$(terraform -chdir="${ENV_DIR}" output -raw app_hostname)"
    BASE_URL="https://${HOST}"
  else
    echo "Usage: $0 <env> <base_url>"
    echo "Example: $0 dev https://dev.myapp.example.com"
    exit 1
  fi
fi

echo "==> Smoke test against ${BASE_URL}"

echo "-- Frontend /"
CODE="$(curl -sk -o /tmp/myapp-fe.html -w '%{http_code}' "${BASE_URL}/")"
[[ "${CODE}" == "200" ]] || { echo "FAIL frontend HTTP ${CODE}"; exit 1; }
grep -qi "myapp" /tmp/myapp-fe.html || echo "WARN: brand string not found in HTML (may still be OK)"

echo "-- Frontend healthz (via path if exposed) or root OK"

echo "-- Backend /api/v1/version"
CODE="$(curl -sk -o /tmp/myapp-ver.json -w '%{http_code}' "${BASE_URL}/api/v1/version")"
[[ "${CODE}" == "200" ]] || { echo "FAIL version HTTP ${CODE}"; exit 1; }
grep -q 'backend\|version' /tmp/myapp-ver.json

echo "-- Backend /api/v1/users (DB path)"
CODE="$(curl -sk -o /tmp/myapp-users.json -w '%{http_code}' "${BASE_URL}/api/v1/users")"
[[ "${CODE}" == "200" ]] || { echo "FAIL users HTTP ${CODE} (check SQL/ESO/NetworkPolicy)"; exit 1; }
grep -q 'users\|email\|Alice\|alice' /tmp/myapp-users.json || grep -q '\[' /tmp/myapp-users.json

echo "-- HTTP→HTTPS redirect (if http URL derivable)"
HTTP_URL="${BASE_URL/https:/http:}"
REDIR="$(curl -s -o /dev/null -w '%{http_code}' --max-redirs 0 "${HTTP_URL}/" || true)"
if [[ "${REDIR}" == "301" || "${REDIR}" == "302" || "${REDIR}" == "308" ]]; then
  echo "Redirect OK (${REDIR})"
else
  echo "WARN: expected redirect from HTTP, got ${REDIR} (cert/DNS may still be fine on HTTPS-only tests)"
fi

echo "SMOKE TEST PASSED for ${ENV} (${BASE_URL})"
