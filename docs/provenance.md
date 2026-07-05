# Procedencia del Baseline Sanitizado

## Fuente Canónica

El contrato se derivó del resultado completo del curso SQL en el commit de
autoría que contenía los siguientes archivos. Los hashes registran el punto de
derivación y permiten detectar cambios posteriores:

```text
8ba924fce41c42e9b12782b126a8ff4875df3acf113ad9703622991afba2203a  scripts/01_schema.sql
1ac1b2b37b4da8941f53e64ddb1a63d069607d12bb1746221fc8d0f743e2425f  scripts/02_seed_data.sql
3922866048e214167d1bff25d422999fcc8c39bdc4366405e44c7f8a0764e00f  scripts/05_views_indexes.sql
3835d01d686ad811636609c42f88d4b85c011eae1f264220ef6a8aa302be47e4  scripts/06_final_extension.sql
d1cf3978d2381ccec6a126d387141d663c8841d5b5dda28f9e35f8ab2a80544b  scripts/99_verify.sql
```

## Sanitización

El baseline conserva tablas, columnas, relaciones, restricciones, vistas e
índices requeridos por la API. Sustituye nombres, correos, placas y valores de la
evaluación por fixtures neutrales y consolida el estado final en un solo script.

El paquete publicado es autosuficiente. No requiere acceso a la fuente privada
ni contiene los pasos usados para resolver la extensión final del curso SQL.
