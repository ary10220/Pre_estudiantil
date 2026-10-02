# Base de datos · Presupuesto Estudiantil

PostgreSQL. Cada flujo agrega sus tablas en una migración numerada dentro de `migraciones/`.
Se corren **en orden** y **una sola vez** cada una.

| Orden | Archivo | Qué crea |
|---|---|---|
| 1 | `001_acceso.sql` | `usuarios`, `sesiones`, `recuperaciones` (Tarea 1) |
| 2 | `002_movimientos.sql` | `movimientos` (Flujo 1 · Guardar movimiento) |

## Base nueva

Desde la carpeta del proyecto:

```
createdb -U postgres presupuesto_estudiantil
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/001_acceso.sql
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/002_movimientos.sql
```

## Base que ya tenía la Tarea 1

Solo falta la migración nueva:

```
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/002_movimientos.sql
```

Si `psql` no se reconoce en Windows, usar la ruta completa: `"C:\Program Files\PostgreSQL\16\bin\psql.exe"`.
