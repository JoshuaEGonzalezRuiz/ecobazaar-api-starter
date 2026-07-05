#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

command -v docker >/dev/null || {
  echo "Docker is required for Compose verification." >&2
  exit 1
}

docker compose version >/dev/null
docker compose --env-file .env.example config --quiet

if [[ "${COMPOSE_SMOKE_UP:-0}" != "1" ]]; then
  echo "compose-config=PASS"
  echo "Set COMPOSE_SMOKE_UP=1 to build and run the full stack smoke test."
  exit 0
fi

cleanup() {
  docker compose --env-file .env.example down --volumes --remove-orphans >/dev/null
}
trap cleanup EXIT

docker compose --env-file .env.example up --build --detach

port="${API_HTTP_PORT:-5180}"
for _ in {1..60}; do
  if curl --fail --silent "http://127.0.0.1:$port/health/live" | rg -q 'Healthy'; then
    echo "compose-smoke=PASS"
    exit 0
  fi
  sleep 2
done

docker compose --env-file .env.example logs api db >&2
echo "Compose stack did not become healthy." >&2
exit 1
