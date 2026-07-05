#!/usr/bin/env bash

set -euo pipefail

psql \
  --username "$POSTGRES_USER" \
  --dbname "$POSTGRES_DB" \
  --file /ecobazaar/database/run_all.psql
