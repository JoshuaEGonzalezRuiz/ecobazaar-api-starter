# Configuración Local de PostgreSQL

## Requisitos

- PostgreSQL 15 o superior.
- Cliente `psql`.
- Una base de datos local desechable.
- Un rol de desarrollo sin privilegios administrativos globales.

## Preparación

Primero crea el rol con un prompt de contraseña y asigna la base de desarrollo a
ese rol:

```bash
createuser --login --pwprompt ecobazaar_app
createdb --owner ecobazaar_app ecobazaar_api_dev
```

Después configura la conexión. El siguiente ejemplo usa un valor deliberadamente
ficticio. Sustituye `CHANGE_ME` solo en tu entorno local y nunca guardes la
contraseña real en Git.

```bash
export API_PACKAGE_DATABASE_URL='postgresql://ecobazaar_app:CHANGE_ME@localhost:5432/ecobazaar_api_dev'
psql "$API_PACKAGE_DATABASE_URL" -f database/run_all.psql
```

## Resultado Esperado

La ejecución crea los siete conjuntos de datos heredados, las vistas, los
índices y los fixtures neutrales. Después muestra:

```text
EcoBazaar API baseline verification completed successfully.
```

## Protección de Datos Existentes

No apuntes esta variable a una base personal o productiva. Una segunda ejecución
del bootstrap debe fallar antes de modificar datos; usa otra base desechable para
repetir el proceso desde cero.
