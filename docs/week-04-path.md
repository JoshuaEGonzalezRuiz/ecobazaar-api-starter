# Week 4 Path — API Integration Surface

## Overview

Week 4 turns the working EcoBazaar API into a service that other clients can
consume more safely and predictably. This checkpoint adds three integration
features:

- OpenAPI JSON so client developers and tools can inspect the HTTP contract.
- CORS configuration so browser-based clients can call the API only from
  approved origins.
- Cache headers for the public catalog so clients and intermediaries know that
  catalog reads can be reused briefly.

These features do not add new business behavior. They make the existing catalog,
identity, and checkout behavior easier to integrate, test, document, and deploy.

## Starting Point

Before starting this checkpoint, the project should already have:

- `GET /api/productos` and `GET /api/productos/{id}` for the public catalog.
- `POST /api/auth/register`, `POST /api/auth/login`, and `GET /api/auth/me`.
- Authenticated checkout and customer sales visibility.
- Problem Details responses for validation, not-found, conflict, and
  authentication errors.

## Target Contract

After this checkpoint, the API should expose:

```http
GET /openapi/v1.json
OPTIONS /api/productos
GET /api/productos
GET /api/productos/{id}
```

`/openapi/v1.json` should describe the existing API endpoints. CORS preflight
requests should allow only configured client origins. Catalog GET responses
should include short public cache headers.

## Conceptual Foundation

OpenAPI is a machine-readable description of the API contract. It helps verify
which paths, methods, request bodies, response types, and status codes are part
of the service. It is especially useful when the mobile or web client is built
by a different team or in a later course.

CORS is a browser security policy. It does not protect the API from non-browser
clients, but it controls which browser origins are allowed to read responses
from the API. A production API should not use `AllowAnyOrigin()` unless the
endpoint is intentionally public and the risk has been reviewed.

Cache headers describe how long a response can be reused. Public catalog reads
are safe to cache briefly because they do not contain private customer data.
Authentication, checkout, and customer sales endpoints should not use public
cache headers because they expose user-specific or state-changing behavior.

## Practical Demonstration

Use the examples in `exercises/week-04/` as implementation references:

```txt
exercises/week-04/
├── Configuration/CorsConfiguration.cs.example
├── Controllers/ProductosCache.cs.example
└── Program.OpenApiCors.cs.example
```

Recommended implementation order:

1. Add the OpenAPI package to the API project.
2. Register OpenAPI services and map `/openapi/v1.json`.
3. Add a named CORS policy that reads allowed origins from configuration.
4. Add the CORS section to `appsettings.json`.
5. Apply short cache headers to catalog GET actions only.
6. Verify the OpenAPI JSON, CORS preflight, and cache headers.

Example verification commands:

```bash
curl http://localhost:5000/openapi/v1.json

curl -i -X OPTIONS http://localhost:5000/api/productos \
  -H "Origin: https://maui-store.example.test" \
  -H "Access-Control-Request-Method: GET"

curl -i http://localhost:5000/api/productos
```

## Expected Result

The OpenAPI document should include paths such as:

```txt
/api/productos
/api/auth/login
/api/checkout
```

A preflight request from an approved origin should include:

```txt
Access-Control-Allow-Origin: https://maui-store.example.test
```

Catalog responses should include a short public cache directive similar to:

```txt
Cache-Control: public,max-age=60
```

Auth, checkout, and customer sales endpoints should not be marked as publicly
cacheable.

## Common Mistakes and Troubleshooting

- **Symptom:** `/openapi/v1.json` returns `404`.  
  **Likely cause:** OpenAPI services or endpoint mapping were not registered.  
  **Fix:** Add `AddOpenApi()` before building the app and `MapOpenApi()` after
  building it.

- **Symptom:** Browser requests fail even though curl works.  
  **Likely cause:** The browser sends an `Origin` header and requires CORS
  approval.  
  **Fix:** Add the exact client origin to `Cors:AllowedOrigins`.

- **Symptom:** Every website can call the API from a browser.  
  **Likely cause:** The policy uses `AllowAnyOrigin()`.  
  **Fix:** Use explicit configured origins for this course project.

- **Symptom:** Customer-specific responses are cached.  
  **Likely cause:** Cache headers were applied globally.  
  **Fix:** Apply public cache headers only to catalog GET endpoints.

## Reinforcement and Independent Practice

Add integration tests that verify:

- The OpenAPI document contains the main API paths.
- Approved CORS origins are allowed.
- Unapproved CORS origins are not allowed.
- Catalog endpoints include cache headers.
- Auth and checkout endpoints do not expose public cache headers.

## Summary

This checkpoint makes the API easier to integrate without changing its business
model. OpenAPI describes the contract, CORS controls browser access from known
clients, and cache headers improve catalog-read behavior without exposing
private data.

## Preparation for the Next Week Segment

These integration features prepare the API for Docker Compose, deployment
configuration, and deployed verification. The next segment can focus on running
the API consistently outside the local development environment.

## Deployment Continuation

The Week 4 deployment continuation uses Docker Compose to run the API and
PostgreSQL together from the repository package.

See: [`docker_compose.md`](docker_compose.md)
