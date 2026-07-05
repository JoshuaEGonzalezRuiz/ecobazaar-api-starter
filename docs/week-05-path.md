# Week 5 Path — Shipment Visibility and Logistics Authorization

## Overview

Week 5 extends EcoBazaar API beyond checkout. After a customer places or reviews
orders, the next practical question is shipment visibility: which deliveries
belong to the current customer, and which operations should be reserved for the
logistics team?

This checkpoint introduces two authorization boundaries:

- Customers can read only shipments connected to their own sales.
- Logistics operators can review and update shipment status.

The main skill is not only creating endpoints. The important part is enforcing
ownership and role-based authorization without trusting client-supplied
customer IDs.

## Starting Point

Before starting this checkpoint, the project should already have:

- JWT authentication.
- User accounts linked to inherited `Cliente` records.
- Checkout and customer sales visibility.
- Existing inherited `Venta`, `Envio`, and `Repartidor` tables from the SQL
  course database.

## Target Contract

```http
GET /api/envios/mios
GET /api/logistica/envios
PATCH /api/logistica/envios/{id}/estado
```

`GET /api/envios/mios` requires any authenticated user and returns only
shipments connected to the current user's `ClienteID`.

The logistics endpoints require the privileged `Operador` role.

## Conceptual Foundation

Ownership authorization answers the question: "Does this authenticated user own
or have permission to access this specific record?" Authentication alone is not
enough. A valid token proves identity, but it does not automatically prove that
the user can see every shipment.

Role-based authorization answers a different question: "Does this user perform
a privileged function in the system?" In EcoBazaar, customers can view their own
shipments, while logistics operators can inspect the shipment queue and update
status.

A safe API does not accept `clienteId` in the request body for customer-owned
queries. The API reads the user ID from the JWT, loads the linked `Usuario`, and
uses the stored `ClienteID` to filter records.

## Practical Demonstration

Use the examples in `exercises/week-05/` as implementation references:

```txt
exercises/week-05/
├── Controllers/LogisticsController.cs.example
└── Features/Logistics/
    ├── LogisticsDtos.cs.example
    └── LogisticsService.cs.example
```

Recommended implementation order:

1. Define shipment response and status-update request DTOs.
2. Implement a logistics service that can:
   - list current-customer shipments;
   - list all shipments for operators;
   - update shipment status for operators.
3. Add a controller with `[Authorize]` on customer visibility and
   `[Authorize(Roles = "Operador")]` on privileged endpoints.
4. Configure JWT validation so the API reads the `role` claim correctly.
5. Add integration tests for customer visibility, forbidden access, operator
   access, and invalid status updates.

## Expected Result

A customer token should be able to call:

```bash
curl -H "Authorization: Bearer <cliente-token>" \
  http://localhost:5180/api/envios/mios
```

Expected behavior:

- The response is `200`.
- Every shipment belongs to the current customer.
- Shipments from other customers are not included.

A regular customer token should not be able to call:

```bash
curl -H "Authorization: Bearer <cliente-token>" \
  http://localhost:5180/api/logistica/envios
```

Expected behavior:

```txt
403 Forbidden
```

An operator token should be able to update status:

```bash
curl -X PATCH \
  -H "Authorization: Bearer <operador-token>" \
  -H "Content-Type: application/json" \
  -d '{"estatus":"Entregado"}' \
  http://localhost:5180/api/logistica/envios/3/estado
```

Expected behavior:

- The response is `200`.
- The response body shows `estatus` as `Entregado`.

## Common Mistakes and Troubleshooting

- **Symptom:** A customer can see all shipments.  
  **Likely cause:** The query does not filter by the authenticated user's linked
  `ClienteID`.  
  **Fix:** Load `Usuario` by token user ID, then filter shipments through
  `Envio -> Venta -> ClienteID`.

- **Symptom:** Operator endpoints always return `403`.  
  **Likely cause:** The JWT role claim is not mapped to ASP.NET Core role
  authorization.  
  **Fix:** Configure `RoleClaimType = "role"` in token validation.

- **Symptom:** Invalid statuses are saved.  
  **Likely cause:** The request DTO does not validate allowed status values.  
  **Fix:** Restrict status to the supported lifecycle values.

- **Symptom:** A route returns private persistence fields.  
  **Likely cause:** The controller returns EF entities directly.  
  **Fix:** Return response DTOs.

## Reinforcement and Independent Practice

Add integration tests that verify:

- Missing tokens return `401`.
- Normal customers receive `403` on logistics routes.
- Operators can list shipments.
- Operators can update a shipment status.
- Invalid statuses return `400`.

## Summary

This checkpoint adds a realistic authorization layer to the API. Customers can
see their own shipments, while operators can manage logistics state. The core
habit is to derive permissions from trusted server-side identity data rather
than from request parameters supplied by the client.

## Preparation for the Next Segment

The logistics endpoints prepare the API for final validation, role-aware client
integration, and end-to-end verification across catalog, checkout, shipment
visibility, and operator workflows.
