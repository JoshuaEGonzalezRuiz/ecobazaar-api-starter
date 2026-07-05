#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
project="$repo_root/src/EcoBazaar.Api/EcoBazaar.Api.csproj"

command -v dotnet >/dev/null || {
  echo "The .NET 10 SDK is required. Install it before scaffolding." >&2
  exit 1
}
test -f "$repo_root/.config/dotnet-tools.json" || {
  echo "Missing local tool manifest: .config/dotnet-tools.json" >&2
  exit 1
}
test -f "$project" || {
  echo "Missing API project: src/EcoBazaar.Api/EcoBazaar.Api.csproj" >&2
  exit 1
}
test -n "${ConnectionStrings__EcoBazaar:-}" || {
  echo "Set ConnectionStrings__EcoBazaar before scaffolding." >&2
  exit 1
}

scaffold_connection="$ConnectionStrings__EcoBazaar"
if [[ "$scaffold_connection" =~ ^postgres(ql)?:// ]]; then
  url_without_scheme="${scaffold_connection#*://}"
  credentials="${url_without_scheme%%@*}"
  host_and_database="${url_without_scheme#*@}"
  host_and_port="${host_and_database%%/*}"
  database="${host_and_database#*/}"
  username="${credentials%%:*}"
  password="${credentials#*:}"
  host="${host_and_port%%:*}"
  port="${host_and_port#*:}"

  if [[ "$port" == "$host_and_port" ]]; then
    port="5432"
  fi

  scaffold_connection="Host=$host;Port=$port;Database=$database;Username=$username;Password=$password"
fi

cd "$repo_root"
dotnet tool restore
dotnet restore "$project"
dotnet ef dbcontext scaffold \
  "$scaffold_connection" \
  Npgsql.EntityFrameworkCore.PostgreSQL \
  --project "$project" \
  --startup-project "$project" \
  --context EcoBazaarDbContext \
  --context-dir Data \
  --output-dir Data/Models \
  --namespace EcoBazaar.Api.Data.Models \
  --context-namespace EcoBazaar.Api.Data \
  --no-onconfiguring \
  --force

find "$repo_root/src/EcoBazaar.Api/Data" \
  -type f -name '*.cs' -exec sed -i 's/\r$//' {} +
