# Docker Compose Deployment Guide

## Overview

This guide explains how to run EcoBazaar API and PostgreSQL together with Docker
Compose. The Compose stack is useful when the API must be verified in a
repeatable environment without relying on a locally installed PostgreSQL server.

The database container uses the same `database/run_all.psql` entry point used by
the local setup. This keeps the API course connected to the database contract
created in the SQL course.

## Services

The stack contains two services:

- `db`: PostgreSQL with the EcoBazaar database initialized from `database/`.
- `api`: ASP.NET Core API built from the repository `Dockerfile`.

The API connects to PostgreSQL through the Compose network using the host name
`db`.

## Configuration

Start from the provided example file:

```bash
cp .env.example .env
```

The example values are development-only placeholders. They are safe for local
learning, but they are not production secrets.

Important values:

- `POSTGRES_DB`: database name created inside the container.
- `POSTGRES_USER`: database role used by the API.
- `POSTGRES_PASSWORD`: development password for the local container.
- `API_HTTP_PORT`: host port mapped to the API container.
- `JWT_SIGNING_KEY`: development signing key used once identity endpoints are implemented.
- `CORS_ALLOWED_ORIGIN`: browser client origin allowed by the API.

## Verify Compose Configuration

Run the smoke script without starting containers:

```bash
scripts/smoke_compose.sh
```

Expected result:

```txt
compose-config=PASS
```

## Run the Full Stack

To build and start the stack manually:

```bash
docker compose --env-file .env up --build
```

In another terminal, verify the API:

```bash
curl http://localhost:5180/health/live
```

Expected response:

```json
{"status":"Healthy"}
```

To stop the stack:

```bash
docker compose down --volumes
```

The `--volumes` option removes the disposable database volume so the bootstrap
can run again from a clean state.

## Full Smoke Test

When Docker is available and a full container run is desired:

```bash
COMPOSE_SMOKE_UP=1 scripts/smoke_compose.sh
```

Expected result:

```txt
compose-smoke=PASS
```

## Troubleshooting

- **Symptom:** PostgreSQL exits during initialization.  
  **Likely cause:** The database volume already contains an old or partial
  bootstrap.  
  **Fix:** Run `docker compose down --volumes` and start again.

- **Symptom:** The API cannot connect to PostgreSQL.  
  **Likely cause:** The connection string uses `localhost` inside the container.  
  **Fix:** Use `Host=db` in container configuration.

- **Symptom:** The smoke script says Docker is required.  
  **Likely cause:** Docker Desktop, Docker Engine, or the Compose plugin is not
  installed or not running.  
  **Fix:** Start Docker and verify `docker compose version`.

- **Symptom:** The host port is already in use.  
  **Likely cause:** Another API or PostgreSQL instance is using the same port.  
  **Fix:** Change `API_HTTP_PORT` or `POSTGRES_PORT` in `.env`.
