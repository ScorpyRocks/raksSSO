#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed." >&2
  exit 1
fi

docker_cmd=(docker)
if [[ "${DOCKER_SUDO:-}" == "1" ]]; then
  docker_cmd=(sudo docker)
fi

if ! "${docker_cmd[@]}" info >/dev/null 2>&1; then
  if id -nG "$USER" 2>/dev/null | tr ' ' '\n' | grep -qx docker; then
    echo "You are in the docker group, but this terminal session does not have it yet."
    echo ""
    echo "Pick one fix:"
    echo ""
    echo "  1) Open a fresh shell with docker group (recommended):"
    echo "       newgrp docker"
    echo "     then:  ./scripts/start.sh"
    echo ""
    echo "  2) Or log out of Linux and log back in, then run ./scripts/start.sh"
    echo ""
    echo "  3) Or use sudo for this run (will ask for your password):"
    echo "       DOCKER_SUDO=1 ./scripts/start.sh"
    echo ""
    if command -v sg >/dev/null 2>&1; then
      echo "  4) Or:"
      echo "       sg docker -c './scripts/start.sh'"
    fi
    exit 1
  fi

  echo "Cannot access Docker (permission denied on /var/run/docker.sock)." >&2
  echo ""
  echo "Add your user to docker, then log out and back in:"
  echo "  sudo usermod -aG docker \"\$USER\""
  echo ""
  echo "Or use sudo for this run:"
  echo "  DOCKER_SUDO=1 ./scripts/start.sh"
  exit 1
fi

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

# shellcheck disable=SC1091
source .env 2>/dev/null || true

echo "Starting RaksAppSSO (Keycloak)..."
"${docker_cmd[@]}" compose up -d

echo ""
echo "Waiting for Keycloak (first start can take ~60s)..."
for _ in $(seq 1 60); do
  if curl -sf "http://localhost:${KEYCLOAK_PORT:-8080}/realms/myapps/.well-known/openid-configuration" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

PORT="${KEYCLOAK_PORT:-8080}"
echo ""
echo "RaksAppSSO is ready."
echo ""
echo "  Admin console:  http://localhost:${PORT}/admin"
echo "  Admin login:    ${KEYCLOAK_ADMIN:-admin} / (see .env)"
echo ""
echo "  Realm:          myapps"
echo "  OIDC issuer:    http://localhost:${PORT}/realms/myapps"
echo ""
echo "  Clients: splitsek-ui (4200), demo-app (4201), splitsek-api (API)"
echo "  Test users: alice@example.com / bob@example.com  (password123)"
echo ""
echo "  Demo: cd demo-app && python3 -m http.server 4201"
