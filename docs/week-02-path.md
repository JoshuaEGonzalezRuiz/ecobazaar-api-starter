# Week 2 Path — HTTP Contracts, Services, Validation, and Problem Details

## Overview

Week 2 converts the initial health-check starter into a structured catalog API.
The goal is to expose the inherited EcoBazaar products through stable HTTP
contracts without leaking scaffolded EF Core entities as public JSON.

This week introduces controllers, DTOs, manual mapping, validation, service
boundaries, pagination, filtering, sorting, and Problem Details.

## Starting Point

Before starting this checkpoint, the repository should already contain:

- A working ASP.NET Core project.
- The sanitized PostgreSQL baseline in `database/`.
- The Database-First scaffold script in `scripts/scaffold_database.sh`.
- A liveness endpoint at `/health/live`.

The public starter does not include the completed catalog implementation. Use
the templates in `exercises/week-02/` as guided starting points.

## Target Contract

The completed catalog should support:

```http
GET /api/productos?page=1&pageSize=10&search=texto&categoriaId=1&sortBy=nombre&sortDirection=asc
GET /api/productos/1
```

The list response should be paged:

```json
{
  "items": [],
  "page": 1,
  "pageSize": 10,
  "totalItems": 0,
  "totalPages": 0
}
```

Each item should be a DTO with public fields only:

```json
{
  "id": 1,
  "nombre": "Producto Eco 01",
  "descripcion": "Fixture de catalogo 01",
  "precio": 10.00,
  "stock": 100,
  "categoria": "Limpieza",
  "activo": true
}
```

## Suggested Implementation Order

1. Scaffold the inherited database into `src/EcoBazaar.Api/Data/`.
2. Create catalog DTOs under `Features/Catalog/`.
3. Create a query-parameter type with validation attributes.
4. Add a service interface and implementation for catalog reads.
5. Add a controller under `Controllers/`.
6. Register controllers and the catalog service in `Program.cs`.
7. Add centralized Problem Details handling.
8. Verify valid list/detail requests and invalid query parameters.

## Expected Behavior

- `GET /api/productos` returns page `1`, page size `10`, and only active products with stock.
- `GET /api/productos?page=2&pageSize=5` returns the second page.
- `categoriaId` filters by category ID.
- `search` matches product name or description.
- `sortBy` accepts `id`, `nombre`, and `precio`.
- `sortDirection` accepts `asc` and `desc`.
- Invalid query parameters return `400` Problem Details.
- Missing or non-public products return `404` Problem Details.

## Common Mistakes and Troubleshooting

- **Symptom:** JSON includes EF navigation properties.  
  **Likely cause:** Returning scaffolded entities directly.  
  **Fix:** Return DTOs created through an explicit projection.

- **Symptom:** Filtering works in memory but fails against PostgreSQL.  
  **Likely cause:** Calling a C# method inside a LINQ query that EF cannot translate.  
  **Fix:** Use expression projections and EF-supported operators.

- **Symptom:** Invalid query values reach the service.  
  **Likely cause:** Missing `[ApiController]`, validation attributes, or `[FromQuery]`.  
  **Fix:** Use a validated query-parameter object bound from the query string.

- **Symptom:** The public starter exposes the complete answer.  
  **Likely cause:** Copying instructor implementation files into the student package.  
  **Fix:** Keep completed code in `instructor-key/`; keep public examples under `exercises/`.

## Independent Practice

After implementing the catalog, add one additional sort option such as
`stock`, then update validation and tests to prove the behavior.
