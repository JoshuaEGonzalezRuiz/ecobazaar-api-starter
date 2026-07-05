#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for path in \
  database/bootstrap.sql \
  database/verify.sql \
  database/run_all.psql \
  docs/database_contract.md \
  docs/local_setup.md \
  docs/provenance.md; do
  test -f "$repo_root/$path" || {
    echo "Missing foundation file: $path" >&2
    exit 1
  }
done

if rg -n -i \
  'BEGIN (RSA|OPENSSH|EC) PRIVATE KEY|passwordhash\s*=\s*['"'"'"][^'"'"'"]+['"'"'"]' \
  "$repo_root" \
  --glob '!scripts/validate_foundation.sh'; then
  echo "Package contains secret-like content" >&2
  exit 1
fi

if find "$repo_root" -mindepth 2 -type d -name .git -print -quit | rg -q .; then
  echo "Nested Git repository detected" >&2
  exit 1
fi

if [[ -n "${API_PACKAGE_DATABASE_URL:-}" ]]; then
  psql "$API_PACKAGE_DATABASE_URL" -f "$repo_root/database/run_all.psql"
  before="$(psql "$API_PACKAGE_DATABASE_URL" -Atc 'SELECT COUNT(*) FROM Producto')"

  if psql "$API_PACKAGE_DATABASE_URL" -f "$repo_root/database/bootstrap.sql"; then
    echo "Second bootstrap unexpectedly succeeded" >&2
    exit 1
  fi

  after="$(psql "$API_PACKAGE_DATABASE_URL" -Atc 'SELECT COUNT(*) FROM Producto')"
  test "$before" = "$after" || {
    echo "Failed bootstrap changed existing data" >&2
    exit 1
  }
  psql "$API_PACKAGE_DATABASE_URL" -f "$repo_root/database/verify.sql"
fi

echo "Package foundation validation passed."
