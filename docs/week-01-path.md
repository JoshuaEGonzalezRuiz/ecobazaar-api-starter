# Week 1 Path — From PostgreSQL to a Read-Only Catalog API

## Overview

Week 1 connects the PostgreSQL database inherited from the SQL course to a new
ASP.NET Core application. The progression starts by verifying the database,
continues through liveness and Database-First scaffolding, and ends with a
read-only catalog contract that can be verified automatically.

The public repository begins with a small application that compiles and exposes
only process liveness. Database packages, generated entities, catalog behavior,
and integration tests are deliberate learning increments rather than hidden
prerequisites.

## Learning Objectives

After completing this path, the reader should be able to:

- Verify the inherited EcoBazaar schema and deterministic fixture data.
- Explain the difference between process liveness and database readiness.
- Configure EF Core with Npgsql without committing credentials.
- Reverse-engineer a PostgreSQL schema using a repository-local tool.
- Execute asynchronous read-only queries with cancellation.
- Project persistence entities and relationships into a stable public DTO.
- Verify API behavior against a real disposable PostgreSQL database.

## Required Previous Knowledge

- Basic C# syntax and asynchronous methods.
- Relational tables, primary keys, foreign keys, views, and indexes.
- Terminal navigation and environment variables.
- Basic HTTP methods and status codes.
- A PostgreSQL 15+ server or disposable container.
- A stable .NET 10 SDK compatible with `global.json`.

## Project Context

Before this week, the repository contains a sanitized PostgreSQL baseline based
on the EcoBazaar database developed in the SQL course. It includes customers,
categories, products, sales, sale details, couriers, shipments, views, indexes,
constraints, and deterministic fixtures.

This week adds the first executable API boundary. The result is intentionally
read-only: it proves database connectivity and public catalog projection before
controllers, services, validation, authentication, writes, pagination, Docker,
or deployment increase the architectural surface.

## Day 1 — Verify the inherited database

### Goal

Create the sanitized schema in an empty disposable database and prove that its
objects, constraints, relationships, and fixture counts match the course
contract.

### Steps

Set a local database URL and run the provided bootstrap plus verification entry
point:

```bash
export API_PACKAGE_DATABASE_URL='postgresql://postgres:postgres@localhost:5432/ecobazaar_api'
psql "$API_PACKAGE_DATABASE_URL" -f database/run_all.psql
```

Use an empty database. The bootstrap refuses to overwrite an existing
EcoBazaar schema.

### Why it matters

Database-First code generation is only trustworthy when the source database is
known and repeatable. Verifying the contract first separates schema problems
from application problems.

### Verification

The final `psql` output contains:

```text
EcoBazaar API baseline verification passed.
```

## Day 2 — Start ASP.NET Core and verify liveness

### Goal

Restore and build the initial application, then verify that the process can
answer HTTP requests without PostgreSQL configuration.

### Steps

```bash
dotnet --version
dotnet restore EcoBazaar.Api.slnx
dotnet build EcoBazaar.Api.slnx --no-restore -warnaserror
scripts/smoke_liveness.sh
```

### Why it matters

Liveness answers whether the application process is running. It must not depend
on PostgreSQL, because a database outage should not falsely report that the
process itself has stopped.

### Verification

The build completes with zero warnings and the smoke script prints:

```text
liveness-smoke=PASS
```

## Day 3 — Configure EF Core and Npgsql

### Goal

Add the approved EF Core design package, Npgsql provider, and database health
check package, then supply the connection string outside source control.

### Steps

Use the exact package versions documented by the course checkpoint. Define the
runtime connection string in the current shell:

```bash
export ConnectionStrings__EcoBazaar='Host=localhost;Port=5432;Database=ecobazaar_api;Username=postgres;Password=<local-password>'
```

Replace `<local-password>` with the local disposable database password. Never
write that value into `appsettings.json`, generated C# files, screenshots, or
commits.

### Why it matters

The Npgsql provider translates EF Core queries into PostgreSQL SQL. Named
configuration keeps credentials outside the generated model and supports the
same application structure in local development, tests, and deployment.

### Verification

`dotnet restore EcoBazaar.Api.slnx` succeeds, and `git diff` contains package
metadata but no password or usable connection string.

## Day 4 — Reverse-engineer the Database-First model

### Goal

Generate the EF Core context and entity classes from the verified PostgreSQL
schema using a reproducible repository command.

### Steps

```bash
dotnet tool restore
scripts/scaffold_database.sh
```

The script reads `ConnectionStrings__EcoBazaar`, uses
`Name=ConnectionStrings:EcoBazaar`, and writes the context and entity classes
under `src/EcoBazaar.Api/Data/`.

### Why it matters

Database-First treats the inherited relational schema as the source of truth.
Checking in generated output makes the current mapping reviewable, while the
script makes future drift detectable.

### Verification

Confirm that `Data/EcoBazaarDbContext.cs` and the entity files exist. Search the
generated context and verify that it contains no `OnConfiguring` method with a
connection string.

## Day 5 — Execute asynchronous read-only queries

### Goal

Read public products without tracking changes and without returning an
unbounded or nondeterministically ordered result.

### Steps

Build a query that:

- Starts from the generated product set.
- Uses `AsNoTracking()`.
- Keeps only active products with stock greater than zero.
- Orders by the product primary key.
- Applies a temporary maximum of 50 records.
- Executes asynchronously with the request cancellation token.

### Why it matters

Read-only tracking consumes memory without providing value. Explicit ordering
and a temporary limit make the early catalog predictable while full pagination
remains scheduled for Day 13.

### Verification

Against the provided fixture database, the public query returns 14 products in
ascending product-ID order and excludes inactive product 15.

## Day 6 — Project relationships into public DTOs

### Goal

Expose a stable catalog response without serializing EF Core entities or
navigation collections.

### Steps

Project the product and its related category directly in the database query.
The public response contains only:

- `id`
- `nombre`
- `descripcion`
- `precio`
- `stock`
- `categoria`

Use the same active-and-in-stock rule for list and detail queries. Return `404`
when a requested product is missing, inactive, or out of stock.

### Why it matters

DTO projection separates the HTTP contract from the persistence model, avoids
serialization cycles, reduces transferred data, and prevents accidental
exposure of internal relationships.

### Verification

Inspect the JSON response. Each object has exactly the six public fields, and
the category is a string rather than an EF navigation object.

## Day 7 — Verify health and catalog behavior

### Goal

Prove the checkpoint against real PostgreSQL behavior rather than an in-memory
database substitute.

### Steps

Ensure the baseline exists and both database environment variables reference
the same disposable database. Then run:

```bash
dotnet restore EcoBazaar.Api.slnx
dotnet build EcoBazaar.Api.slnx --no-restore -warnaserror
dotnet test EcoBazaar.Api.slnx --no-restore
```

Verify liveness, readiness, list ordering and count, the exact DTO field set,
product 1, inactive product 15, and an unknown product ID.

### Why it matters

Real-database integration tests exercise Npgsql translation, generated mapping,
relationships, and health checks. EF Core InMemory cannot prove those behaviors.

### Verification

The test run completes with no failed tests. Liveness and readiness return
`200`, the catalog list exposes 14 public fixtures, product 1 is available, and
product 15 plus an unknown ID return `404`.

## Expected Week 1 Result

The public starter remains a buildable liveness-only application. A completed
Week 1 implementation additionally has:

- Credential-free PostgreSQL configuration.
- A reproducible checked-in Database-First model.
- Independent liveness and database readiness endpoints.
- A read-only product list and detail contract.
- DTO projection with category data.
- Real PostgreSQL integration tests.

## Common Mistakes and Troubleshooting

### `dotnet` is not found

- **Likely cause:** The .NET SDK is absent or not on `PATH`.
- **Fix:** Install a stable .NET 10 SDK and run `dotnet --version` from the
  repository root to verify compatibility with `global.json`.

### The scaffold command reports that `dotnet-ef` is unavailable

- **Likely cause:** The repository-local tool has not been restored.
- **Fix:** Run `dotnet tool restore`, then run `scripts/scaffold_database.sh`
  again.

### The named connection string cannot be found

- **Likely cause:** `ConnectionStrings__EcoBazaar` is absent, misspelled, or was
  set in a different shell.
- **Fix:** Export the variable in the current shell before scaffolding or
  starting the database-backed application.

### Readiness reports an unhealthy result

- **Likely cause:** PostgreSQL is unavailable, the database name is incorrect,
  or the baseline was not applied.
- **Fix:** Check PostgreSQL connectivity and run `database/run_all.psql` against
  the same configured disposable database.

### Catalog serialization fails with a cycle

- **Likely cause:** An EF entity or navigation property is being returned
  directly.
- **Fix:** Project the query into the six-field public DTO before execution.

### Catalog order changes between runs

- **Likely cause:** The query has no explicit ordering before the result bound.
- **Fix:** Order by the product primary key before applying the 50-record limit.

## Reinforcement and Independent Practice

- Explain in writing why liveness should not execute a database query.
- Compare tracked and no-tracking queries for a read-only endpoint.
- Add a local out-of-stock product and confirm it is hidden by both catalog
  endpoints.
- Regenerate the model after a disposable schema change and inspect the diff;
  restore the approved baseline afterward.

## Preparation for Week 2

Week 2 refactors the working Minimal API slice into controllers and introduces
HTTP semantics, validation, Problem Details, dependency boundaries, filtering,
sorting, and pagination. Keep the Week 1 tests green: they define behavior that
the refactor must preserve.
