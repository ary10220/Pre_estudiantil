# Base de datos · Presupuesto Estudiantil

PostgreSQL. La base se llama `presupuesto_estudiantil` (es la que dice `backend/.env`).
Cada flujo agrega sus cambios en una migración numerada dentro de `migraciones/`.
Se corren **en orden** y **una sola vez** cada una.

| Orden | Archivo | Qué hace |
|---|---|---|
| 1 | `001_acceso.sql` | Crea `usuarios`, `sesiones`, `recuperaciones` (Tarea 1) |
| 2 | `002_movimientos.sql` | Crea `movimientos` (Flujo 1 · Guardar movimiento) |
| 3 | `003_estado_movimiento.sql` | Agrega `estado` (`pendiente`/`pagado`) y `pagado_en` a `movimientos` (Tarea 2) |
| 4 | `004_limite_mensual.sql` | Agrega `limite_mensual` a `usuarios` (HU-01) |

## Base nueva

Desde la carpeta del proyecto:

```
createdb -U postgres presupuesto_estudiantil
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/001_acceso.sql
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/002_movimientos.sql
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/003_estado_movimiento.sql
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/004_limite_mensual.sql
```

## Base que ya tenía las anteriores

Solo se corren las que falten, por ejemplo la 003:

```
psql -U postgres -d presupuesto_estudiantil -f database/migraciones/003_estado_movimiento.sql
```

Si `psql` no se reconoce en Windows, usar la ruta completa: `"C:\Program Files\PostgreSQL\16\bin\psql.exe"`.

## Con pgAdmin

1. En el panel izquierdo: Servers → PostgreSQL 16 → Databases → **presupuesto_estudiantil** (clic derecho → Query Tool).
2. Abrir el archivo de la migración (ícono de carpeta) o pegar su contenido.
3. Ejecutar con F5. Tiene que decir `ALTER TABLE` (o `CREATE TABLE`).
4. Comprobar: `SELECT id, concepto, estado, pagado_en FROM movimientos;` → los que ya existían salen `pendiente`.

Si la migración ya se corrió, PostgreSQL responde `column "estado" of relation "movimientos" already exists`: no hay que hacer nada.
