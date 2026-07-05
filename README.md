# EcoBazaar API — Student Template

Este repositorio es el espacio learner-facing del curso de Aplicaciones de Bases
de Datos. Continúa la base EcoBazaar construida en el curso SQL.

## Punto de Partida

`database/` contiene un baseline PostgreSQL sanitizado y verificable. Se puede
usar cuando la base personal del curso SQL no está disponible o no supera el
contrato de prerrequisito.

```bash
psql "$API_PACKAGE_DATABASE_URL" -f database/run_all.psql
```

El bootstrap requiere una base desechable vacía y no borra datos existentes.

## Week 1 checkpoint

The executable progression from the inherited PostgreSQL database to the first
ASP.NET Core liveness endpoint is documented in
[`docs/week-01-path.md`](docs/week-01-path.md). The starter remains compilable
while the Database-First and catalog increments are completed.

## Desarrollo Acumulativo

La solución .NET, los endpoints y las pruebas se incorporan por incrementos a
lo largo de las 28 sesiones. Cada actividad y tarea debe conservar evidencia
ejecutable y commits pequeños.

## Docker Compose

El repositorio incluye una pila local con PostgreSQL y la API:

```bash
cp .env.example .env
scripts/smoke_compose.sh
docker compose --env-file .env up --build
```

Ver: [`docs/docker_compose.md`](docs/docker_compose.md)

## Integridad Académica y Seguridad

- No importar soluciones privadas o claves de evaluación.
- No guardar contraseñas, tokens, cadenas reales ni archivos de credenciales.
- No agregar repositorios docentes como remotos, submódulos o historial previo.
- Ejecutar la validación disponible antes de cada entrega.
