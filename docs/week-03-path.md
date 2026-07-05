# Week 3 Path — Identity Foundation and JWT Authentication

## Overview

Week 3 begins the transition from a public catalog API into an API with user
identity. This checkpoint adds the foundation for customer accounts, password
hashing, login, JWT tokens, and authenticated profile access.

The second half of Week 3 adds checkout, ownership authorization, stock
decrement, and customer-only sales visibility.

## Starting Point

Before starting this checkpoint, the project should already have:

- PostgreSQL connected through Database-First EF Core.
- Catalog controllers, DTOs, validation, pagination, and Problem Details.
- Integration tests that run against the inherited EcoBazaar database.

## Target Contract

```http
POST /api/auth/register
POST /api/auth/login
GET /api/auth/me
POST /api/checkout
GET /api/ventas/mias
GET /api/ventas/mias/2000
```

Registration binds a new API user to an existing inherited `Cliente` record.
Login returns a bearer token. `/api/auth/me` requires that token and returns the
current user profile.

## Security Requirements

- Do not store plain-text passwords.
- Do not return password hashes in JSON responses.
- Do not commit JWT signing keys.
- Load JWT issuer, audience, and signing key from configuration.
- Return generic invalid-credential errors.
- Keep authorization logic out of controllers when it belongs in services or policies.

## Suggested Implementation Order

1. Create an API-owned `Usuario` table or migration.
2. Add a `Usuario` persistence model.
3. Create request/response DTOs for register, login, and profile.
4. Implement password hashing with PBKDF2 or another approved one-way hash.
5. Implement JWT token creation and validation.
6. Add `/api/auth/register`, `/api/auth/login`, and `/api/auth/me`.
7. Add tests for successful and failed authentication flows.

## Expected Behavior

- Registering a valid inherited customer creates a user with role `Cliente`.
- Registering the same customer or email twice returns `409`.
- Logging in with valid credentials returns a bearer token.
- `/api/auth/me` returns `401` without a token.
- `/api/auth/me` returns the current profile with a valid token.
- Invalid login attempts return `401` without revealing which field was wrong.
- Checkout uses the authenticated customer; it does not accept `clienteId` in the body.
- Checkout creates one sale and one or more sale details transactionally.
- Product stock is decremented only when the entire checkout succeeds.
- Customers can list and view only their own sales.

## Common Mistakes and Troubleshooting

- **Symptom:** Passwords are visible in responses.  
  **Likely cause:** Returning persistence entities directly.  
  **Fix:** Return DTOs that do not include `PasswordHash`.

- **Symptom:** Tokens work locally but fail in tests.  
  **Likely cause:** Issuer, audience, or signing key differ between token creation and validation.  
  **Fix:** Use one configuration source for both.

- **Symptom:** Registration creates users disconnected from customers.  
  **Likely cause:** `Usuario` does not reference `Cliente`.  
  **Fix:** Add a foreign key from `Usuario.ClienteID` to `Cliente.ClienteID`.

- **Symptom:** The signing key is committed in source control.  
  **Likely cause:** Real secrets were placed in `appsettings.json`.  
  **Fix:** Keep `appsettings.json` blank or safe; use environment variables or user secrets.

- **Symptom:** Checkout creates sales for a customer ID sent by the client.  
  **Likely cause:** The API trusts request-body identity.  
  **Fix:** Read the customer from the authenticated token and linked `Usuario`.

- **Symptom:** Stock changes even when sale creation fails.  
  **Likely cause:** Checkout is not wrapped in a transaction.  
  **Fix:** Use a PostgreSQL transaction and commit only after all details are valid.
