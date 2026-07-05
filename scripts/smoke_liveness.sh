#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
port="${API_SMOKE_PORT:-5180}"
log_file="$(mktemp)"
pid=''

cleanup() {
  if [[ -n "$pid" ]]; then
    kill "$pid" 2>/dev/null || true
    wait "$pid" 2>/dev/null || true
  fi
  rm -f "$log_file"
}
trap cleanup EXIT

cd "$repo_root"
ASPNETCORE_URLS="http://127.0.0.1:$port" \
  dotnet run --no-build --project src/EcoBazaar.Api >"$log_file" 2>&1 &
pid=$!

for _ in {1..30}; do
  if curl --fail --silent "http://127.0.0.1:$port/health/live" | \
    rg -q 'Healthy'; then
    echo 'liveness-smoke=PASS'
    exit 0
  fi
  kill -0 "$pid" 2>/dev/null || {
    cat "$log_file" >&2
    exit 1
  }
  sleep 1
done

cat "$log_file" >&2
echo "The liveness endpoint did not become ready." >&2
exit 1
