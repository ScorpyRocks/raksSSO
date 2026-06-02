#!/usr/bin/env bash
# Export the live myapps realm from Keycloak into realm/myapps-realm.json (for git backup).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

REALM="${KEYCLOAK_REALM:-myapps}"
OUTPUT="${ROOT}/realm/${REALM}-realm.json"
KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"

docker_cmd=(docker)
if [[ "${DOCKER_SUDO:-}" == "1" ]]; then
  docker_cmd=(sudo docker)
fi

if [[ -f .env ]]; then
  # shellcheck disable=SC1091
  source .env
fi

ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASS="${KEYCLOAK_ADMIN_PASSWORD:-admin}"
PORT="${KEYCLOAK_PORT:-8080}"
KEYCLOAK_URL="http://localhost:${PORT}"

if ! curl -sf "${KEYCLOAK_URL}/realms/${REALM}" >/dev/null 2>&1; then
  echo "Keycloak is not running or realm '${REALM}' is missing." >&2
  echo "Start it first: ./scripts/start.sh" >&2
  exit 1
fi

echo "Exporting realm '${REALM}' from ${KEYCLOAK_URL}..."

TOKEN="$(
  curl -sf -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${ADMIN_USER}" \
    -d "password=${ADMIN_PASS}" \
    -d "grant_type=password" \
    -d "client_id=admin-cli" \
    | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])"
)"

EXPORT_JSON="$(
  curl -sf -X POST "${KEYCLOAK_URL}/admin/realms/${REALM}/partial-export" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"exportClients":true,"exportGroupsAndRoles":true,"exportUsers":true}'
)"

if command -v python3 >/dev/null 2>&1; then
  python3 -c "import json, sys; json.dump(json.loads(sys.argv[1]), open(sys.argv[2], 'w'), indent=2); print('')" "$EXPORT_JSON" "$OUTPUT"
else
  printf '%s\n' "$EXPORT_JSON" >"$OUTPUT"
fi

echo "Saved: ${OUTPUT}"
echo ""
echo "Next steps (git backup):"
echo "  git add realm/${REALM}-realm.json"
echo "  git commit -m \"Export Keycloak realm ${REALM}\""
echo ""
echo "To restore from this file on a fresh machine:"
echo "  ./scripts/stop.sh"
echo "  docker volume rm raksappsso_keycloak_db_data"
echo "  ./scripts/start.sh"
