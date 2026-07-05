# Contrato de Base de Datos Heredada

## Propósito

La API EcoBazaar continúa el proyecto del curso de SQL. La base PostgreSQL
completada es un contrato heredado: se consume con Database-First y no se
reemplaza por un modelo desconectado o por un proveedor en memoria.

## Objetos Heredados

Tablas requeridas:

- `Cliente`
- `Categoria`
- `Producto`
- `Venta`
- `DetalleVenta`
- `Repartidor`
- `Envio`

Vistas requeridas:

- `CatalogoPublico`
- `Vista_AuditoriaClientes`
- `ResumenVentas`
- `ReporteEnviosPorRepartidor`

Índices funcionales requeridos:

- `idx_producto_categoria`
- `idx_venta_cliente_fecha`
- `idx_detalleventa_producto`
- `idx_envio_repartidor`

Las claves primarias, relaciones, restricciones `UNIQUE` y `CHECK`, cantidades
positivas y stock cuantitativo forman parte del contrato.

## Límite de Propiedad

Los objetos anteriores pertenecen al resultado heredado del curso SQL. Los
objetos exclusivos de la API, como `Usuario`, se agregan más adelante mediante
migraciones de la aplicación. El baseline no debe editarse para simular esas
migraciones.

## Datos de Integración

El baseline contiene ventas estables con identificadores `1001` a `1005`. Estos
datos permiten verificar catálogo, propiedad, checkout y logística sin reutilizar
identidades reconocibles de la evaluación SQL.

## Seguridad del Bootstrap

`database/bootstrap.sql` requiere una base desechable vacía. Si detecta cualquier
objeto EcoBazaar, termina con error antes de modificar datos. No incluye comandos
`DROP` ni funciona como herramienta de reset.

## Verification

From an empty disposable PostgreSQL database:

```bash
psql "$API_PACKAGE_DATABASE_URL" -f database/run_all.psql
```

Expected: `EcoBazaar API baseline verification completed successfully.`

Running `bootstrap.sql` again must fail with `EcoBazaar objects already exist` and must leave the existing records unchanged.
